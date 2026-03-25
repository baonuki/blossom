# ==========================================
# COMMAND: coinflip
# DESCRIPTION: A high-stakes gamble where users bet coins on a 50/50 flip.
# CATEGORY: Arcade
# ==========================================

# ------------------------------------------
# LOGIC: Coinflip Execution
# ------------------------------------------
def execute_coinflip(event, amount, choice)
  # 1. Initialization: Standardize the user's input
  uid = event.user.id
  choice = choice.downcase

  # 2. Validation: Ensure the bet is a positive number
  if amount <= 0
    return send_embed(event, 
      title: "#{EMOJIS['error']} Invalid Bet", 
      description: "You must bet at least 1 #{EMOJIS['s_coin']}."
    )
  end

  # 3. Validation: Check the user's balance in the Database
  if DB.get_coins(uid) < amount
    return send_embed(event, 
      title: "#{EMOJIS['nervous']} Insufficient Funds", 
      description: "You don't have enough coins to cover that bet!\nYou currently have **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}."
    )
  end

  # 4. Validation: Ensure the choice is valid (Heads or Tails)
  unless ['heads', 'tails'].include?(choice)
    return send_embed(event, 
      title: "#{EMOJIS['error']} Invalid Choice", 
      description: "Please pick either `heads` or `tails`."
    )
  end

  # 5. Calculation: Determine the result and deduct the initial bet
  result = ['heads', 'tails'].sample
  DB.add_coins(uid, -amount)
  
  # 6. Result: Handle the Win/Loss scenarios
  if choice == result
    # Win: Add double the bet (return the original + the prize)
    DB.add_coins(uid, amount * 2)
    send_embed(event, 
      title: "🪙 Coinflip: #{result.capitalize}!", 
      description: "You won! You doubled your bet and earned **#{amount}** #{EMOJIS['s_coin']}.\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}"
    )
    
    # 7. Achievement Check: See if they unlocked 'gamble_win'
    check_achievement(event.channel, event.user.id, 'gamble_win')
  else
    # Loss: Bet was already deducted; just provide feedback
    send_embed(event, 
      title: "🪙 Coinflip: #{result.capitalize}!", 
      description: "You lost... **#{amount}** #{EMOJIS['s_coin']} down the drain.\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}"
    )
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!coinflip)
# ------------------------------------------
bot.command(:coinflip, 
  description: 'Bet your stream revenue on a coinflip!', 
  category: 'Arcade'
) do |event, amount_str, choice|
  # Argument Check: Ensure both amount and choice are present
  if amount_str.nil? || choice.nil?
    send_embed(event, 
      title: "#{EMOJIS['confused']} Missing Arguments", 
      description: "You need to tell me how much to bet and what side you want!\n\n**Usage:** `#{PREFIX}coinflip <amount> <heads/tails>`"
    )
    next
  end

  execute_coinflip(event, amount_str.to_i, choice)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/coinflip)
# ------------------------------------------
bot.application_command(:coinflip) do |event|
  # Options are automatically cast to the correct type by discordrb for Slash
  execute_coinflip(event, event.options['amount'], event.options['choice'])
end