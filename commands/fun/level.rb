def execute_level(event, target_user)
  unless event.server
    if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
      return event.respond(content: "#{EMOJIS['x_']} This command can only be used in a server!", ephemeral: true)
    else
      return event.respond("#{EMOJIS['x_']} This command can only be used in a server!")
    end
  end

  sid  = event.server.id
  uid  = target_user.id
  user = DB.get_user_xp(sid, uid)
  needed = user['level'] * 100
  
  daily_info = DB.get_daily_info(uid)
  is_sub = is_premium?(event.bot, uid)

  badges = []
  badges << "#{EMOJIS['developer']} **Verified Bot Developer**" if uid == DEV_ID
  badges << "💎 **Blossom Premium**" if is_sub
  
  desc = badges.empty? ? "" : badges.join("\n") + "\n\n"

  send_embed(
    event,
    title: "#{EMOJIS['crown']} #{target_user.display_name}'s Profile",
    description: desc, 
    fields: [
      { name: 'Level', value: user['level'].to_s, inline: true },
      { name: 'XP', value: "#{user['xp']} / #{needed}", inline: true },
      { name: 'Coins', value: "#{DB.get_coins(uid)} #{EMOJIS['s_coin']}", inline: true },
      { name: 'Daily Streak', value: "🔥 #{daily_info['streak']} Days", inline: true }
    ]
  )
end

bot.command(:level, description: 'Show a user\'s level and XP for this server', category: 'Fun') do |event|
  execute_level(event, event.message.mentions.first || event.user)
  nil
end

bot.application_command(:level) do |event|
  target_id = event.options['user']
  target = target_id ? event.bot.user(target_id.to_i) : event.user
  execute_level(event, target)
end