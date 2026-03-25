# ==========================================
# COMMAND: addxp (Admin Only)
# DESCRIPTION: Manually adjust a user's server-specific XP and Level.
# CATEGORY: Admin / Developer
# ==========================================

# ------------------------------------------
# LOGIC: XP Modification Execution
# ------------------------------------------
def execute_addxp(event, target_user, amount)
  # 1. Validation: Ensure command is used in a Guild
  unless event.server
    return event.respond("#{EMOJIS['x_']} This command can only be used inside a server!")
  end

  # 2. Security: Permission Check (Admins or Developer Only)
  unless event.user.permission?(:administrator, event.channel) || event.user.id == DEV_ID
    return event.respond("#{EMOJIS['x_']} You need Administrator permissions to use this command!")
  end

  # 3. Validation: Ensure a target user exists
  if target_user.nil?
    return event.respond("Usage: `#{PREFIX}addxp @user <amount>`\n*(Tip: Use a negative number to remove XP!)*")
  end

  # 4. Data Retrieval: Fetch current stats from Database
  sid = event.server.id
  uid = target_user.id
  user = DB.get_user_xp(sid, uid)
  
  # 5. Calculation: Apply new XP and prevent negative totals
  new_xp = user['xp'] + amount
  new_xp = 0 if new_xp < 0
  new_level = user['level']

  # 6. Logic: Handle Level-Up/Down recursion
  needed = new_level * 100
  while new_xp >= needed
    new_xp -= needed
    new_level += 1
    needed = new_level * 100
  end

  # 7. Database: Update the server_xp table
  DB.update_user_xp(sid, uid, new_xp, new_level, user['last_xp_at'])
  
  # 8. UI: Confirm success via Embed
  send_embed(event, 
    title: "#{EMOJIS['developer']} Admin Override", 
    description: "Successfully added **#{amount}** XP to #{target_user.mention}.\nThey are now **Level #{new_level}** with **#{new_xp}** XP."
  )
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!addxp)
# ------------------------------------------
bot.command(:addxp, 
  description: 'Add or remove server XP from a user (Admin Only)', 
  min_args: 2, 
  category: 'Admin'
) do |event, mention, amount|
  execute_addxp(event, event.message.mentions.first, amount.to_i)
  nil # Prevent double-response
end

# ------------------------------------------
# TRIGGER: Slash Command (/addxp)
# ------------------------------------------
bot.application_command(:addxp) do |event|
  # Fetch target user object from the option ID
  target = event.bot.user(event.options['user'].to_i)
  execute_addxp(event, target, event.options['amount'])
end