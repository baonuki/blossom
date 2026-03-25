# ==========================================
# COMMAND: logsetup
# DESCRIPTION: Configure the destination for server activity and mod logs.
# CATEGORY: Moderation
# ==========================================

# ------------------------------------------
# LOGIC: Log Configuration Execution
# ------------------------------------------
def execute_logsetup(event, channel)
  # 1. Security: Verify 'Manage Server' permission or Developer status
  # This prevents regular moderators from moving or disabling the log feed.
  unless event.user.permission?(:manage_server) || event.user.id == DEV_ID
    return mod_reply(event, "❌ *You need the Manage Server permission to set up logging!*", is_ephemeral: true)
  end

  # 2. Validation: Ensure a valid channel object was passed through
  if channel.nil?
    return mod_reply(event, "⚠️ *Please tag the channel you want logs sent to. Example: `#{PREFIX}logsetup #logs`*", is_ephemeral: true)
  end

  # 3. Database: Save the server ID and channel ID association
  # This allows the 'log_mod_action' helper to find the right channel later.
  DB.set_log_channel(event.server.id, channel.id)

  # 4. UI: Confirm the setup and nudge the user toward the next step
  mod_reply(event, "✅ **Logging Configured**\nAll server logs will now be sent to #{channel.mention}.\n\n" \
                   "*Use `#{PREFIX}logtoggle` to choose what gets logged!*")
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!logsetup)
# ------------------------------------------
bot.command(:logsetup, 
  description: 'Set the channel for server logs (Admin)', 
  category: 'Moderation'
) do |event, channel_mention|
  channel = nil
  
  # Regex Parsing: Extract the numeric ID from the #channel mention
  if channel_mention && channel_mention.match(/<#(\d+)>/)
    channel_id = $1.to_i
    channel = event.bot.channel(channel_id)
  end

  execute_logsetup(event, channel)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/logsetup)
# ------------------------------------------
bot.application_command(:logsetup) do |event|
  # Fetch the channel object directly from the Slash interaction ID
  channel_id = event.options['channel'].to_i
  channel = event.bot.channel(channel_id)
  
  execute_logsetup(event, channel)
end