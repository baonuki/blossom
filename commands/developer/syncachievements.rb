def execute_global_sync(event)
  if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
    event.defer
  else
    @sync_msg = event.respond("⏳ *Starting global achievement sync... Blossom is checking everyone!*")
  end

  Thread.new do
    begin
      all_user_ids = event.bot.servers.values.flat_map { |s| s.members.map(&:id) }.uniq
      
      total_unlocked = 0
      users_affected = 0

      all_user_ids.each do |uid|
        count = sync_user_achievements(uid) 
        
        if count > 0
          total_unlocked += count
          users_affected += 1
        end
        
        sleep 0.1 
      end

      desc = "Successfully scanned the database footprints of **#{all_user_ids.size}** users.\n\n" \
             "🏆 **#{users_affected}** users received missing achievements.\n" \
             "✨ **#{total_unlocked}** total achievements were retroactively unlocked!\n\n" \
             "*(All coin rewards have been automatically deposited into their accounts!)*"

      embed = Discordrb::Webhooks::Embed.new(
        title: "🌍 Global Achievement Sync Complete",
        description: desc,
        color: 0x00FF00
      )

      if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
        event.edit_response(embeds: [embed])
      else
        @sync_msg.edit(nil, embed)
      end
    rescue => e
      puts "❌ Global Sync Error: #{e.message}"
    end
  end
end

# PREFIX
bot.command(:syncachievements, description: 'Retroactively grant achievements to everyone (Dev Only)', category: 'Developer') do |event|
  return unless event.user.id == DEV_ID
  execute_global_sync(event)
  nil
end

# SLASH
bot.application_command(:syncachievements) do |event|
  return event.respond(content: "❌ Developer only!", ephemeral: true) unless event.user.id == DEV_ID
  execute_global_sync(event)
end