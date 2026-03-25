# ==========================================
# COMMAND: dice (High-Low Dice)
# DESCRIPTION: Roll 2d6 and bet on the outcome (High, Low, or Lucky 7).
# CATEGORY: Arcade
# ==========================================

# ------------------------------------------
# LOGIC: Dice Execution
# ------------------------------------------
def execute_dice(event, amount, bet)
  # 1. Initialization: Get user ID and normalize the bet string
  uid = event.user.id
  bet = bet.downcase

  # 2. Validation: Check for a valid amount and sufficient funds
  if amount <= 0 || DB.get_coins(uid) < amount
    return send_embed(event, 
      title: "#{EMOJIS['error']} Invalid Bet", 
      description: "You don't have enough coins or entered an invalid amount!"
    )
  end

  # 3. Validation: Ensure the bet type is recognized
  unless ['high', 'low', '7'].include?(bet)
    return send_embed(event, 
      title: "#{EMOJIS['error']} Invalid Bet Type", 
      description: "You can only bet on `high`, `low`, or `7`."
    )
  end

  # 4. Database: Deduct the initial bet amount
  DB.add_coins(uid, -amount)

  # 5. Simulation: Roll two 6-sided dice
  die1 = rand(1..6)
  die2 = rand(1..6)
  total = die1 + die2

  # 6. Logic: Categorize the actual result
  actual_result = total < 7 ? 'low' : (total > 7 ? 'high' : '7')

  # 7. Result: Handle the win/loss branching
  if bet == actual_result
    # Win: Apply 4x payout for '7', or 2x for 'high'/'low'
    payout = (bet == '7') ? (amount * 4) : (amount * 2)
    DB.add_coins(uid, payout)
    
    send_embed(event, 
      title: "🎲 High Roller Dice", 
      description: "The dice roll... **#{die1}** and **#{die2}**! (Total: **#{total}**)\n\nYou correctly bet on **#{bet}** and won **#{payout}** #{EMOJIS['s_coin']}!\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}"
    )
  else
    # Loss: Inform the user of their bad luck
    send_embed(event, 
      title: "🎲 High Roller Dice", 
      description: "The dice roll... **#{die1}** and **#{die2}**! (Total: **#{total}**)\n\nYou bet on **#{bet}** and lost **#{amount}** #{EMOJIS['s_coin']}.\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}"
    )
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!dice)
# ------------------------------------------
bot.command(:dice, 
  description: 'Roll 2d6! Bet on high (8-12), low (2-6), or 7.', 
  category: 'Arcade'
) do |event, amount_str, bet|
  # Argument Check: Ensure both inputs exist
  if amount_str.nil? || bet.nil?
    send_embed(event, 
      title: "#{EMOJIS['confused']} Missing Arguments", 
      description: "Place your bets on the dice!\n\n**Usage:** `#{PREFIX}dice <amount> <high/low/7>`"
    )
    next
  end

  execute_dice(event, amount_str.to_i, bet)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/dice)
# ------------------------------------------
bot.application_command(:dice) do |event|
  # Slash commands handle data types automatically
  execute_dice(event, event.options['amount'], event.options['bet'])
end