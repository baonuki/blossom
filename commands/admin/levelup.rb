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