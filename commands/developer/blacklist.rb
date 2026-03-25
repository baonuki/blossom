# ==========================================
# COMMAND: blacklist (Developer Only)
# DESCRIPTION: Toggles a user's ability to interact with the bot globally.
# CATEGORY: Developer / Security
# ==========================================

# ------------------------------------------
# LOGIC: Blacklist Execution
# ------------------------------------------
def execute_blacklist(event, target_user)
  # 1. Security: Strict Developer-Only Check
  unless event.user.id == DEV_ID
    return event.respond("#{EMOJIS['x_']} Only the bot developer can use this command!")
  end

  # 2. Validation: Ensure a target user was provided
  if target_user.nil?
    return event.respond("Usage: `#{PREFIX}blacklist @user`")
  end

  # 3. Safety Check: Prevent the developer from locking themselves out
  uid = target_user.id
  if uid == DEV_ID
    return event.respond("#{EMOJIS['x_']} You cannot blacklist yourself!")
  end

  # 4. Database: Toggle the blacklist status in the PostgreSQL 'blacklist' table
  # This returns true if they were added, or false if they were removed.
  is_now_blacklisted = DB.toggle_blacklist(uid)

  # 5. System Action & UI: Apply the change to the bot's live "ignore" list
  if is_now_blacklisted
    # Tell the discordrb client to stop processing any events from this user ID
    event.bot.ignore_user(uid)
    
    send_embed(event, 
      title: "🚫 User Blacklisted", 
      description: "#{target_user.mention} has been added to the blacklist. I will now ignore all messages and commands from them."
    )
  else
    # Remove the user ID from the bot's internal ignore list
    event.bot.unignore_user(uid)
    
    send_embed(event, 
      title: "✅ User Forgiven", 
      description: "#{target_user.mention} has been removed from the blacklist. They are free to interact again."
    )
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!blacklist)
# ------------------------------------------
bot.command(:blacklist, 
  description: 'Toggle blacklist for a user (Dev Only)', 
  min_args: 1, 
  category: 'Developer'
) do |event, mention|
  # Pass the first mention from the message to the executor
  execute_blacklist(event, event.message.mentions.first)
  nil # Prevent double-response
end

# ------------------------------------------
# TRIGGER: Slash Command (/blacklist)
# ------------------------------------------
bot.application_command(:blacklist) do |event|
  # Fetch target user object from the provided Slash option ID
  target = event.bot.user(event.options['user'].to_i)
  execute_blacklist(event, target)
end