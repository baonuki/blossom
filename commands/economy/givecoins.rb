# ==========================================
# COMMAND: givecoins
# DESCRIPTION: Transfer coins from your balance to another user.
# CATEGORY: Economy
# ==========================================

# ------------------------------------------
# LOGIC: Give Coins Execution
# ------------------------------------------
def execute_givecoins(event, target, amount_str)
  # 1. Initialization: Get the sender's ID and convert input to integer
  uid = event.user.id
  amount = amount_str.to_i

  # 2. Validation: Prevent self-gifting or gifting to nobody
  if target.nil? || target.id == uid
    return send_embed(event, 
      title: "⚠️ Invalid Target", 
      description: "You need to mention another user to give coins to!"
    )
  end

  # 3. Validation: Ensure the amount is a positive number
  if amount <= 0
    return send_embed(event, 
      title: "⚠️ Invalid Amount", 
      description: "You must give at least 1 #{EMOJIS['s_coin']}."
    )
  end

  # 4. Validation: Check if the sender has enough funds in the Database
  if DB.get_coins(uid) < amount
    return send_embed(event, 
      title: "#{EMOJIS['nervous']} Insufficient Funds", 
      description: "You don't have **#{amount}** #{EMOJIS['s_coin']} to give!"
    )
  end

  # 5. Transaction: Deduct from sender and add to recipient
  # Note: Since these are two separate calls, ensure your DB module handles errors gracefully.
  DB.add_coins(uid, -amount)
  DB.add_coins(target.id, amount)

  # 6. UI: Confirm the successful transfer via Embed
  send_embed(
    event, 
    title: "💸 Coins Transferred!", 
    description: "#{event.user.mention} gave **#{amount}** #{EMOJIS['s_coin']} to #{target.mention}!\n\n" \
                 "Your new balance: **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}"
  )
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!givecoins)
# ------------------------------------------
bot.command(:givecoins, 
  description: 'Give your coins to another user', 
  category: 'Economy'
) do |event, mention, amount|
  # Capture the first user mention in the message
  execute_givecoins(event, event.message.mentions.first, amount)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/givecoins)
# ------------------------------------------
bot.application_command(:givecoins) do |event|
  # Fetch target user from options and pass Slash data to the executor
  target = event.bot.user(event.options['user'].to_i)
  execute_givecoins(event, target, event.options['amount'])
end