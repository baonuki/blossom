# ==========================================
# COMMAND: addcoins (Developer Only)
# DESCRIPTION: Manually adjust a user's global coin balance.
# CATEGORY: Developer / Economy Override
# ==========================================

# ------------------------------------------
# LOGIC: Coin Modification Execution
# ------------------------------------------
def execute_addcoins(event, target_user, amount)
  # 1. Security: Strict Developer-Only Check
  unless event.user.id == DEV_ID
    return event.respond("#{EMOJIS['x_']} Only the bot developer can use this command!")
  end

  # 2. Validation: Ensure a target user was provided
  if target_user.nil?
    return event.respond("Usage: `#{PREFIX}addcoins @user <amount>`\n*(Tip: Use a negative number to remove coins!)*")
  end

  # 3. Database: Apply the balance adjustment
  uid = target_user.id
  DB.add_coins(uid, amount)
  
  # 4. UI: Confirm success and display the updated balance via Embed
  send_embed(event, 
    title: "#{EMOJIS['developer']} Developer Override", 
    description: "Successfully added **#{amount}** #{EMOJIS['s_coin']} to #{target_user.mention}.\nTheir new balance is **#{DB.get_coins(uid)}**."
  )
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!addcoins)
# ------------------------------------------
bot.command(:addcoins, 
  description: 'Add or remove coins from a user (Dev Only)', 
  min_args: 2, 
  category: 'Developer'
) do |event, mention, amount|
  # Parse the first mention from the message and cast amount to integer
  execute_addcoins(event, event.message.mentions.first, amount.to_i)
  nil # Prevent double-response
end

# ------------------------------------------
# TRIGGER: Slash Command (/addcoins)
# ------------------------------------------
bot.application_command(:addcoins) do |event|
  # Fetch target user object from the provided Slash option ID
  target = event.bot.user(event.options['user'].to_i)
  execute_addcoins(event, target, event.options['amount'])
end