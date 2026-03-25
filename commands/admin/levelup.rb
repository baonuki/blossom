# ==========================================
# COMMAND: levelup (Admin Only)
# DESCRIPTION: Configures or toggles level-up notification settings for the server.
# CATEGORY: Admin
# ==========================================

# ------------------------------------------
# LOGIC: Level-Up Configuration Execution
# ------------------------------------------
def execute_levelup(event, state, channel_obj = nil)
  # 1. Security: Permission Check (Admins or Developer Only)
  unless event.user.id == DEV_ID || event.user.permission?(:administrator, event.channel)
    return send_embed(event, 
      title: "❌ Access Denied", 
      description: "You need administrator permissions to configure this."
    )
  end

  # 2. Data Retrieval: Fetch current level-up settings from PostgreSQL
  config = DB.get_levelup_config(event.server.id)
  current_channel = config[:channel]

  # 3. Branching Logic: Handle specific channel assignment
  if channel_obj
    DB.set_levelup_config(event.server.id, channel_obj.id, true)
    send_embed(event, 
      title: "📣 Level-Up Channel Set", 
      description: "Level-up messages will now be automatically sent to #{channel_obj.mention}!"
    )

  # 4. Branching Logic: Enable notifications (ON)
  elsif state.nil? || state.downcase == 'on'
    DB.set_levelup_config(event.server.id, current_channel, true)
    send_embed(event, 
      title: "✅ Level-Ups Enabled", 
      description: "Level-up messages are now turned ON."
    )

  # 5. Branching Logic: Disable notifications (OFF)
  elsif state.downcase == 'off'
    DB.set_levelup_config(event.server.id, current_channel, false)
    send_embed(event, 
      title: "🔇 Level-Ups Disabled", 
      description: "Level-up messages have been completely turned off for this server."
    )

  # 6. Fallback: Provide usage guidance if input is unrecognized
  else
    send_embed(event, 
      title: "⚠️ Invalid Usage", 
      description: "Usage:\n`#{PREFIX}levelup #channel` - Send to a specific channel\n`#{PREFIX}levelup off` - Turn off completely\n`#{PREFIX}levelup on` - Turn on"
    )
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!levelup)
# ------------------------------------------
bot.command(:levelup, 
  description: 'Configure where level-up messages go (Admin Only)', 
  category: 'Admin'
) do |event, arg|
  # Regex check: Did the user mention a channel? (<#ID>)
  if arg =~ /<#(\d+)>/
    chan = event.bot.channel($1.to_i, event.server)
    if chan
      execute_levelup(event, nil, chan)
    else
      send_embed(event, title: "⚠️ Error", description: "I couldn't find that channel in this server.")
    end
  else
    # Treat the argument as a status string (on/off)
    execute_levelup(event, arg, nil)
  end
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/levelup)
# ------------------------------------------
bot.application_command(:levelup) do |event|
  # Resolve the channel object if an option was provided
  chan_id = event.options['channel']
  chan = chan_id ? event.bot.channel(chan_id.to_i, event.server) : nil
  
  execute_levelup(event, event.options['state'], chan)
end