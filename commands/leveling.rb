# =========================
# LEVELING COMMANDS
# =========================

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

def execute_leaderboard(event)
  unless event.server
    if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
      return event.respond(content: "#{EMOJIS['x_']} This command can only be used in a server!", ephemeral: true)
    else
      return event.respond("#{EMOJIS['x_']} This command can only be used in a server!")
    end
  end

  sid = event.server.id
  raw_top = DB.get_top_users(sid, 50) 
  
  active_humans = []
  raw_top.each do |row|
    user_obj = event.bot.user(row['user_id'])
    if user_obj && !user_obj.bot_account? && event.server.member(user_obj.id)
      active_humans << row
      break if active_humans.size >= 10
    end
  end

  if active_humans.empty?
    send_embed(event, title: "#{EMOJIS['crown']} Level Leaderboard", description: 'No humans have gained XP yet!')
  else
    desc = active_humans.each_with_index.map do |row, index|
      user_obj = event.bot.user(row['user_id'])
      name = user_obj.display_name
      "##{index + 1} — **#{name}**: Level #{row['level']} | #{row['xp']} XP"
    end.join("\n")

    send_embed(event, title: "#{EMOJIS['crown']} Level Leaderboard", description: desc)
  end
end

bot.command(:leaderboard, description: 'Show top users by level for this server', category: 'Fun') do |event|
  execute_leaderboard(event)
  nil
end

bot.application_command(:leaderboard) do |event|
  execute_leaderboard(event)
end

def execute_levelup(event, state, channel_obj = nil)
  unless event.user.id == DEV_ID || event.user.permission?(:administrator, event.channel)
    return send_embed(event, title: "❌ Access Denied", description: "You need administrator permissions to configure this.")
  end

  config = DB.get_levelup_config(event.server.id)
  current_channel = config[:channel]

  if channel_obj
    DB.set_levelup_config(event.server.id, channel_obj.id, true)
    send_embed(event, title: "📣 Level-Up Channel Set", description: "Level-up messages will now be automatically sent to #{channel_obj.mention}!")
  elsif state.nil? || state.downcase == 'on'
    DB.set_levelup_config(event.server.id, current_channel, true)
    send_embed(event, title: "✅ Level-Ups Enabled", description: "Level-up messages are now turned ON.")
  elsif state.downcase == 'off'
    DB.set_levelup_config(event.server.id, current_channel, false)
    send_embed(event, title: "🔇 Level-Ups Disabled", description: "Level-up messages have been completely turned off for this server.")
  else
    send_embed(event, title: "⚠️ Invalid Usage", description: "Usage:\n`#{PREFIX}levelup #channel` - Send to a specific channel\n`#{PREFIX}levelup off` - Turn off completely\n`#{PREFIX}levelup on` - Turn on")
  end
end

bot.command(:levelup, description: 'Configure where level-up messages go (Admin Only)', category: 'Admin') do |event, arg|
  if arg =~ /<#(\d+)>/
    chan = event.bot.channel($1.to_i, event.server)
    if chan
      execute_levelup(event, nil, chan)
    else
      send_embed(event, title: "⚠️ Error", description: "I couldn't find that channel in this server.")
    end
  else
    execute_levelup(event, arg, nil)
  end
  nil
end

bot.application_command(:levelup) do |event|
  chan_id = event.options['channel']
  chan = chan_id ? event.bot.channel(chan_id.to_i, event.server) : nil
  execute_levelup(event, event.options['state'], chan)
end