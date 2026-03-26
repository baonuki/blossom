# ==========================================
# COMMAND: syncachievements (Developer Only)
# DESCRIPTION: Scans all users globally to retroactively grant missing achievements.
# CATEGORY: Developer / Maintenance
# ==========================================

# ------------------------------------------
# LOGIC: Global Achievement Sync Execution
# ------------------------------------------
def execute_global_sync(event)
  # 1. UI Feedback: Provide an immediate response to let the developer know it started
  if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
    event.defer # Slash commands need more time for this heavy task
  else
    resp = send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
      { type: 10, content: "## ⏳ Syncing..." },
      { type: 14, spacing: 1 },
      { type: 10, content: "Starting global achievement sync... Blossom is checking everyone!" }
    ]}])
    @sync_channel_id = event.channel.id
    @sync_msg_id = JSON.parse(resp.body)['id'] rescue nil
  end

  # 2. Threading: Move the logic to a background thread to prevent the bot from freezing
  Thread.new do
    begin
      # 3. Data Gathering: Collect every unique User ID the bot can see across all servers
      all_user_ids = event.bot.servers.values.flat_map { |s| s.members.map(&:id) }.uniq
      
      total_unlocked = 0
      users_affected = 0

      # 4. Processing: Loop through each user to check their achievement status
      all_user_ids.each do |uid|
        count = sync_user_achievements(uid) # Call the helper to check/grant achievements
        
        if count > 0
          total_unlocked += count
          users_affected += 1
        end
        
        # 5. Rate Limiting: Sleep for 100ms between users to avoid slamming the database
        sleep 0.1 
      end

      # 6. UI: Construct the final report summary
      desc = "Successfully scanned the database footprints of **#{all_user_ids.size}** users.\n\n" \
              "#{EMOJI_STRINGS['crown']} **#{users_affected}** users received missing achievements.\n" \
              "#{EMOJI_STRINGS['neonsparkle']} **#{total_unlocked}** total achievements were retroactively unlocked!\n\n" \
              "*(All coin rewards have been automatically deposited into their accounts!)*"

      # 7. Final Response: Edit the initial message/deferral with the results
      if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
        embed = Discordrb::Webhooks::Embed.new(
          title: "🌍 Global Achievement Sync Complete",
          description: desc,
          color: 0x00FF00
        )
        event.edit_response(embeds: [embed])
      else
        if @sync_msg_id
          body = { content: '', flags: CV2_FLAG, components: [{ type: 17, accent_color: 0x00FF00, components: [
            { type: 10, content: "## 🌍 Global Achievement Sync Complete" },
            { type: 14, spacing: 1 },
            { type: 10, content: desc }
          ]}] }.to_json
          Discordrb::API.request(
            :channels_cid_messages_mid,
            @sync_channel_id,
            :patch,
            "#{Discordrb::API.api_base}/channels/#{@sync_channel_id}/messages/#{@sync_msg_id}",
            body,
            Authorization: $bot.token,
            content_type: :json
          )
        end
      end

    rescue => e
      # 8. Error Handling: Log any failures to the console without crashing the bot
      puts "❌ Global Sync Error: #{e.message}"
    end
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!syncachievements)
# ------------------------------------------
$bot.command(:syncachievements, 
  description: 'Retroactively grant achievements to everyone (Dev Only)', 
  category: 'Developer'
) do |event|
  # Security: Only the developer can trigger a global database scan
  return unless DEV_IDS.include?(event.user.id)
  
  execute_global_sync(event)
  nil # Suppress default return
end