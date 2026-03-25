# ==========================================
# COMMAND: setcoins (Developer Only)
# DESCRIPTION: Forcefully overwrites a user's balance to a specific value.
# CATEGORY: Developer / Economy Management
# ==========================================

# ------------------------------------------
# LOGIC: Set Coins Execution
# ------------------------------------------
def execute_setcoins(event, target_user, amount)
  # 1. Security: Strict Developer-Only Check
  unless event.user.id == DEV_ID
    return event.respond("#{EMOJIS['x_']} Only the bot developer can use this command!")
  end

  # 2. Validation: Ensure a target user was identified and the amount is non-negative
  if target_user.nil? || amount < 0
    return event.respond("Usage: `#{PREFIX}setcoins @user <amount>`")
  end

  # 3. Database: Capture the target ID and apply the absolute balance change
  uid = target_user.id
  DB.set_coins(uid, amount)
  
  # 4. UI: Confirm success and display the finalized balance via Embed
  send_embed(event, 
    title: "#{EMOJIS['developer']} Developer Override", 
    description: "#{target_user.mention}'s balance has been forcefully set to **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}."
  )
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!setcoins)
# ------------------------------------------
$bot.command(:setcoins, 
  description: 'Set a user\'s balance to an exact amount (Dev Only)', 
  min_args: 2, 
  category: 'Developer'
) do |event, mention, amount|
  # Identify the mentioned user and cast the input amount to an integer
  execute_setcoins(event, event.message.mentions.first, amount.to_i)
  nil # Suppress default return
end