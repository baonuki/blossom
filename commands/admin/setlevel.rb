# ==========================================
# COMMAND: setlevel (Admin Only)
# DESCRIPTION: Force-update a user's level while preserving their current XP.
# CATEGORY: Admin / Developer
# ==========================================

# ------------------------------------------
# LOGIC: Set Level Execution
# ------------------------------------------
def execute_setlevel(event, target_user, new_level)
  # 1. Validation: Ensure command is used in a Guild context
  unless event.server
    return event.respond("#{EMOJIS['x_']} This command can only be used inside a server!")
  end

  # 2. Security: Permission Check (Admins or Developer Only)
  unless event.user.permission?(:administrator, event.channel) || event.user.id == DEV_ID
    return event.respond("#{EMOJIS['x_']} You need Administrator permissions to use this command!")
  end

  # 3. Validation: Check for a valid target and a positive level number
  if target_user.nil? || new_level < 1
    return event.respond("Usage: `#{PREFIX}setlevel @user <level>`")
  end

  # 4. Data Retrieval: Fetch current stats to preserve existing XP
  sid = event.server.id
  uid = target_user.id
  user = DB.get_user_xp(sid, uid)

  # 5. Database Update: Apply the new level to the server_xp table
  # We pass user['xp'] back in so their progress toward the next level isn't reset.
  DB.update_user_xp(sid, uid, user['xp'], new_level, user['last_xp_at'])
  
  # 6. UI: Confirm success via Embed
  send_embed(event, 
    title: "#{EMOJIS['developer']} Admin Override", 
    description: "Successfully set #{target_user.mention}'s level to **#{new_level}**."
  )
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!setlevel)
# ------------------------------------------
bot.command(:setlevel, 
  description: 'Set a user\'s server level (Admin Only)', 
  min_args: 2, 
  category: 'Admin'
) do |event, mention, level|
  # Mentions are parsed from the message; level is cast to an integer
  execute_setlevel(event, event.message.mentions.first, level.to_i)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/setlevel)
# ------------------------------------------
bot.application_command(:setlevel) do |event|
  # Fetch target user object from the Slash option ID
  target = event.bot.user(event.options['user'].to_i)
  execute_setlevel(event, target, event.options['level'])
end