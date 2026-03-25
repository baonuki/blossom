# ==========================================
# COMMAND: removecoins (Developer Only)
# DESCRIPTION: Manually deduct coins from a user's global balance.
# CATEGORY: Developer / Economy Management
# ==========================================

# ------------------------------------------
# LOGIC: Remove Coins Execution
# ------------------------------------------
def execute_removecoins(event, target, amount_str)
  # 1. Security: Strict Developer-Only Check
  unless event.user.id == DEV_ID
    return send_embed(event, 
      title: "❌ Permission Denied", 
      description: "Only the bot developer can use this command."
    )
  end

  # 2. Validation: Ensure a target user was provided
  if target.nil?
    return send_embed(event, 
      title: "⚠️ Missing Target", 
      description: "Please mention the user you want to remove coins from."
    )
  end

  # 3. Validation: Convert input to integer and ensure it is a positive value
  amount = amount_str.to_i
  if amount <= 0
    return send_embed(event, 
      title: "⚠️ Invalid Amount", 
      description: "Please specify a positive number of coins to remove."
    )
  end

  # 4. Safety Calculation: Prevent negative balances
  # We find the minimum between the requested amount and the user's actual balance.
  current_balance = DB.get_coins(target.id)
  actual_removal = [amount, current_balance].min 
  
  # 5. Database: Subtract the calculated amount from the user's account
  DB.add_coins(target.id, -actual_removal)

  # 6. UI: Confirm success and display the updated balance via Embed
  send_embed(
    event, 
    title: "💸 Coins Removed", 
    description: "Successfully removed **#{actual_removal}** #{EMOJIS['s_coin']} from #{target.mention}.\n\nNew balance: **#{DB.get_coins(target.id)}** #{EMOJIS['s_coin']}"
  )
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!removecoins)
# ------------------------------------------
bot.command(:removecoins, 
  description: 'Remove coins from a user (Dev Only)', 
  category: 'Developer'
) do |event, mention, amount|
  # Capture the first mention and pass the raw amount string to the executor
  execute_removecoins(event, event.message.mentions.first, amount)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/removecoins)
# ------------------------------------------
bot.application_command(:removecoins) do |event|
  # Fetch target user and pass Slash options to the executor
  target = event.bot.user(event.options['user'].to_i)
  execute_removecoins(event, target, event.options['amount'])
end