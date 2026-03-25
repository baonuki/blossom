# ==========================================
# COMMAND: slots
# DESCRIPTION: A 3-reel slot machine with payouts for matching 2 or 3 symbols.
# CATEGORY: Arcade
# ==========================================

# ------------------------------------------
# LOGIC: Slots Execution
# ------------------------------------------
def execute_slots(event, amount)
  # 1. Initialization: Get the user's unique ID
  uid = event.user.id

  # 2. Validation: Ensure the bet is valid and the user is "good for it"
  if amount <= 0 || DB.get_coins(uid) < amount
    return send_embed(event, 
      title: "#{EMOJIS['error']} Invalid Bet", 
      description: "You don't have enough coins or entered an invalid amount!\nYou currently have **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}."
    )
  end

  # 3. Database & Progression: Deduct the bet and track the spin achievement
  DB.add_coins(uid, -amount)
  check_achievement(event.channel, event.user.id, 'slots_spin')

  # 4. Simulation: Define the reel icons and spin the 3 reels
  slot_icons = ['🍒', '🍋', '🔔', '💎', '7️⃣']
  spin = [slot_icons.sample, slot_icons.sample, slot_icons.sample]

  # 5. Result Branching: Calculate winnings based on symbol uniqueness
  if spin.uniq.size == 1
    # JACKPOT: All three symbols match (5x Payout)
    winnings = amount * 5
    DB.add_coins(uid, winnings)
    
    send_embed(event, 
      title: "🎰 Neon Slots", 
      description: "[ #{spin.join(' | ')} ]\n\n**JACKPOT!** #{EMOJIS['sparkle']}\nYou won **#{winnings}** #{EMOJIS['s_coin']}!\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}"
    )

  elsif spin.uniq.size == 2
    # PARTIAL MATCH: Two symbols match (2x Payout)
    winnings = amount * 2
    DB.add_coins(uid, winnings)
    
    send_embed(event, 
      title: "🎰 Neon Slots", 
      description: "[ #{spin.join(' | ')} ]\n\nNice! You matched two and won **#{winnings}** #{EMOJIS['s_coin']}!\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}"
    )

  else
    # LOSS: No matches found
    send_embed(event, 
      title: "🎰 Neon Slots", 
      description: "[ #{spin.join(' | ')} ]\n\nYou lost your bet... Better luck next spin. #{EMOJIS['worktired']}\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}"
    )
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!slots)
# ------------------------------------------
bot.command(:slots, 
  description: 'Spin the neon slots!', 
  category: 'Arcade'
) do |event, amount_str|
  # Argument Check: Ensure an amount was provided
  if amount_str.nil?
    send_embed(event, 
      title: "#{EMOJIS['confused']} Missing Arguments", 
      description: "You need to drop some coins into the machine first!\n\n**Usage:** `#{PREFIX}slots <amount>`"
    )
    next
  end

  # Execute logic with integer casting
  execute_slots(event, amount_str.to_i)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/slots)
# ------------------------------------------
bot.application_command(:slots) do |event|
  # Slash commands handle integer conversion automatically
  execute_slots(event, event.options['amount'])
end