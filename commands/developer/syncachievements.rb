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
    @sync_msg = event.respond("⏳ *Starting global achievement sync... Blossom is checking everyone!*")
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
              "🏆 **#{users_affected}** users received missing achievements.\n" \
              "✨ **#{total_unlocked}** total achievements were retroactively unlocked!\n\n" \
              "*(All coin rewards have been automatically deposited into their accounts!)*"

      embed = Discordrb::Webhooks::Embed.new(
        title: "🌍 Global Achievement Sync Complete",
        description: desc,
        color: 0x00FF00 # Success Green
      )

      # 7. Final Response: Edit the initial message/deferral with the results
      if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
        event.edit_response(embeds: [embed])
      else
        @sync_msg.edit(nil, embed)
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
  return unless event.user.id == DEV_ID
  
  execute_global_sync(event)
  nil # Suppress default return
end