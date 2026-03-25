# ==========================================
# COMMAND: cups (The Shell Game)
# DESCRIPTION: A 1-in-3 guessing game with a triple payout reward.
# CATEGORY: Arcade
# ==========================================

# ------------------------------------------
# LOGIC: Cups Execution
# ------------------------------------------
def execute_cups(event, amount, guess)
  # 1. Initialization: Get the player's unique ID
  uid = event.user.id

  # 2. Validation: Check for a positive bet and sufficient funds
  if amount <= 0 || DB.get_coins(uid) < amount
    return send_embed(event, 
      title: "#{EMOJIS['error']} Invalid Bet", 
      description: "You don't have enough coins or entered an invalid amount!"
    )
  end

  # 3. Validation: Ensure the user picked a valid cup (1, 2, or 3)
  unless [1, 2, 3].include?(guess)
    return send_embed(event, 
      title: "#{EMOJIS['error']} Invalid Cup", 
      description: "You must pick cup `1`, `2`, or `3`."
    )
  end

  # 4. Calculation: Deduct the bet and determine the winning cup
  DB.add_coins(uid, -amount)
  winning_cup = [1, 2, 3].sample
  
  # 5. UI Logic: Create the visual "lifted cups" display string
  cups_display = [1, 2, 3].map { |c| c == winning_cup ? '🪙' : '🥤' }.join('   ')

  # 6. Result: Handle the win or loss scenarios
  if guess == winning_cup
    # Win: Triple the original bet!
    payout = amount * 3
    DB.add_coins(uid, payout)
    
    send_embed(event, 
      title: "🥤 The Shell Game", 
      description: "Blossom lifts cup ##{winning_cup}...\n\n**#{cups_display}**\n\nYou found it! You won **#{payout}** #{EMOJIS['s_coin']}!\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}"
    )
  else
    # Loss: The user picked wrong; reveal where it was
    send_embed(event, 
      title: "🥤 The Shell Game", 
      description: "Blossom lifts cup ##{guess}...\nEmpty! The coin was under cup ##{winning_cup}.\n\n**#{cups_display}**\n\nYou lost **#{amount}** #{EMOJIS['s_coin']}.\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}"
    )
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!cups)
# ------------------------------------------
bot.command(:cups, 
  description: 'Guess which cup hides the coin (1, 2, or 3)!', 
  category: 'Arcade'
) do |event, amount_str, guess_str|
  # Argument Check: Ensure amount and guess are provided
  if amount_str.nil? || guess_str.nil?
    send_embed(event, 
      title: "#{EMOJIS['confused']} Missing Arguments", 
      description: "Keep your eye on the cup!\n\n**Usage:** `#{PREFIX}cups <amount> <1/2/3>`"
    )
    next
  end

  # Execute logic with integer casting
  execute_cups(event, amount_str.to_i, guess_str.to_i)
  nil
end

# ------------------------------------------
# TRIGGER: Slash Command (/cups)
# ------------------------------------------
bot.application_command(:cups) do |event|
  # Slash commands handle integer casting automatically based on the command definition
  execute_cups(event, event.options['amount'], event.options['guess'])
end