def execute_verifysetup(event, channel_input, role_input)
  unless event.user.permission?(:manage_server) || event.user.id == DEV_ID
    return mod_reply(event, "❌ *You need the Manage Server permission to do this!*", is_ephemeral: true)
  end

  channel = nil
  if channel_input.to_s.match(/<#(\d+)>/)
    channel = event.bot.channel($1.to_i)
  elsif channel_input.is_a?(Discordrb::Channel)
    channel = channel_input
  end

  role = parse_role(event, role_input)

  return mod_reply(event, "⚠️ *Please mention a valid channel and a role! Example: `#{PREFIX}verifysetup #welcome @Verified`*", is_ephemeral: true) if channel.nil? || role.nil?

  embed = Discordrb::Webhooks::Embed.new(
    title: "🛡️ Server Verification",
    description: "Welcome to **#{event.server.name}**!\n\nPlease press the button below to prove you are human and gain access to the rest of the server.",
    color: 0x98FB98 # Pale Green
  )

  view = Discordrb::Components::View.new do |v|
    v.row do |r|
      r.button(custom_id: 'verify_start', label: 'Start Verification', style: :success, emoji: '✅')
    end
  end

  begin
    channel.send_message(nil, false, embed, nil, nil, nil, view)
    DB.set_verification(event.server.id, channel.id, role.id)
    mod_reply(event, "✅ **Verification Set Up!**\nThe verification panel has been sent to #{channel.mention} and will grant the **#{role.name}** role.")
  rescue => e
    mod_reply(event, "❌ *I couldn't send the message! Do I have permission to type in that channel?*", is_ephemeral: true)
  end
end

bot.command(:verifysetup, description: 'Set up the verification panel', required_permissions: [:manage_server]) do |event, channel_mention, role_mention|
  execute_verifysetup(event, channel_mention, role_mention)
  nil
end

bot.application_command(:verifysetup) do |event|
  channel = event.bot.channel(event.options['channel'].to_i)
  execute_verifysetup(event, channel, event.options['role'])
end