# ==========================================
# COMMAND: verifysetup
# DESCRIPTION: Create a button-based verification gate for new members.
# CATEGORY: Moderation / Admin
# ==========================================

# ------------------------------------------
# LOGIC: Verification Configuration Execution
# ------------------------------------------
def execute_verifysetup(event, channel_input, role_input)
  # 1. Security: Ensure only High-Level Admins or Developers can set this up
  unless event.user.permission?(:manage_server) || event.user.id == DEV_ID
    return mod_reply(event, "❌ *You need the Manage Server permission to do this!*", is_ephemeral: true)
  end

  # 2. Parsing: Resolve the Channel object
  # Supports either a raw mention string or a Channel object from Slash options
  channel = nil
  if channel_input.to_s.match(/<#(\d+)>/)
    channel = event.bot.channel($1.to_i)
  elsif channel_input.is_a?(Discordrb::Channel)
    channel = channel_input
  end

  # 3. Parsing: Resolve the Role object using your custom helper
  role = parse_role(event, role_input)

  # 4. Validation: Ensure both target inputs are valid
  if channel.nil? || role.nil?
    return mod_reply(event, "⚠️ *Please mention a valid channel and a role! Example: `#{PREFIX}verifysetup #welcome @Verified`*", is_ephemeral: true)
  end

  # 5. UI: Construct the Verification Embed
  embed = Discordrb::Webhooks::Embed.new(
    title: "🛡️ Server Verification",
    description: "Welcome to **#{event.server.name}**!\n\nPlease press the button below to prove you are human and gain access to the rest of the server.",
    color: 0x98FB98 # Pale Green (Very welcoming!)
  )

  # 6. Components: Build the "Start" Button
  # custom_id 'verify_start' is the key that the Interaction Listener will look for.
  view = Discordrb::Components::View.new do |v|
    v.row do |r|
      r.button(custom_id: 'verify_start', label: 'Start Verification', style: :success, emoji: '✅')
    end
  end

  begin
    # 7. Action: Send the panel to the target channel and save the config to the DB
    channel.send_message(nil, false, embed, nil, nil, nil, view)
    DB.set_verification(event.server.id, channel.id, role.id)
    
    mod_reply(event, "✅ **Verification Set Up!**\nThe verification panel has been sent to #{channel.mention} and will grant the **#{role.name}** role.")
  rescue => e
    # 8. Error Handling: Catch permission issues (e.g., bot can't see the #welcome channel)
    mod_reply(event, "❌ *I couldn't send the message! Error:* `#{e.message}`\n*(Do I have permission to type in that channel?)*", is_ephemeral: true)
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!verifysetup)
# ------------------------------------------
bot.command(:verifysetup, 
  description: 'Set up the verification panel', 
  required_permissions: [:manage_server]
) do |event, channel_mention, role_mention|
  execute_verifysetup(event, channel_mention, role_mention)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/verifysetup)
# ------------------------------------------
bot.application_command(:verifysetup) do |event|
  # Fetch channel and role directly from interaction options
  channel = event.bot.channel(event.options['channel'].to_i)
  execute_verifysetup(event, channel, event.options['role'])
end