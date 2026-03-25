def execute_logsetup(event, channel)
  unless event.user.permission?(:manage_server) || event.user.id == DEV_ID
    return mod_reply(event, "❌ *You need the Manage Server permission to set up logging!*", is_ephemeral: true)
  end

  if channel.nil?
    return mod_reply(event, "⚠️ *Please tag the channel you want logs sent to. Example: `#{PREFIX}logsetup #logs`*", is_ephemeral: true)
  end

  DB.set_log_channel(event.server.id, channel.id)
  mod_reply(event, "✅ **Logging Configured**\nAll server logs will now be sent to #{channel.mention}.\n\n*Use `#{PREFIX}logtoggle` to choose what gets logged!*")
end

bot.command(:logsetup, description: 'Set the channel for server logs (Admin)') do |event, channel_mention|
  channel = nil
  if channel_mention && channel_mention.match(/<#(\d+)>/)
    channel_id = $1.to_i
    channel = event.bot.channel(channel_id)
  end
  execute_logsetup(event, channel)
  nil
end

bot.application_command(:logsetup) do |event|
  channel_id = event.options['channel'].to_i
  channel = event.bot.channel(channel_id)
  execute_logsetup(event, channel)
end