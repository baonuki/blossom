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
    return send_cv2(event, [{
      type: 17, accent_color: 0xFF0000,
      components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} Invalid Bet" },
        { type: 14, spacing: 1 },
        { type: 10, content: "You're broke or you can't type. Either way, no spin for you.\nYou've got **#{DB.get_coins(uid)}** #{EMOJI_STRINGS['s_coin']}." }
      ]
    }])
  end

  # 3. Database & Progression: Deduct the bet and track the spin achievement
  DB.add_coins(uid, -amount)
  check_achievement(event.channel, uid, 'slots_spin')
  check_achievement(event.channel, uid, 'gamble_10k') if amount >= 10000

  # 4. Simulation: Define the reel icons and spin the 3 reels
  slot_icons = ['🍒', '🍋', '🔔', '💎', '7️⃣']
  spin = [slot_icons.sample, slot_icons.sample, slot_icons.sample]

  # 5. Result Branching: Calculate winnings based on symbol uniqueness
  if spin.uniq.size == 1
    # JACKPOT: All three symbols match (5x Payout)
    payout_result = arcade_payout(event.bot, uid, amount * 5)
    DB.add_coins(uid, payout_result[:winnings])
    extras = arcade_win_extras(uid, payout_result)
    check_achievement(event.channel, uid, 'slots_jackpot')

    inner = [
      { type: 10, content: "## 🎰 Neon Slots" },
      { type: 14, spacing: 1 },
      { type: 10, content: "[ #{spin.join(' | ')} ]\n\nNO WAY. **JACKPOT!!** #{EMOJI_STRINGS['neonsparkle']}\nYou just pulled **#{payout_result[:winnings]}** #{EMOJI_STRINGS['s_coin']}!! ACTUALLY POG!!#{extras[:text]}\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJI_STRINGS['s_coin']}#{mom_remark(uid, 'arcade')}" }
    ]
    inner << extras[:button] if extras[:button]
    send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: inner }])

  elsif spin.uniq.size == 2
    # PARTIAL MATCH: Two symbols match (2x Payout)
    payout_result = arcade_payout(event.bot, uid, amount * 2)
    DB.add_coins(uid, payout_result[:winnings])
    extras = arcade_win_extras(uid, payout_result)

    inner = [
      { type: 10, content: "## 🎰 Neon Slots" },
      { type: 14, spacing: 1 },
      { type: 10, content: "[ #{spin.join(' | ')} ]\n\nTwo outta three, not bad chat~ You grabbed **#{payout_result[:winnings]}** #{EMOJI_STRINGS['s_coin']}.#{extras[:text]}\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJI_STRINGS['s_coin']}#{mom_remark(uid, 'arcade')}" }
    ]
    inner << extras[:button] if extras[:button]
    send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: inner }])

  else
    # LOSS: No matches found
    send_cv2(event, [{
      type: 17, accent_color: 0xFF0000,
      components: [
        { type: 10, content: "## 🎰 Neon Slots" },
        { type: 14, spacing: 1 },
        { type: 10, content: "[ #{spin.join(' | ')} ]\n\nLOL nothing. Skill issue, better luck next spin I guess~ 😩\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJI_STRINGS['s_coin']}#{mom_remark(uid, 'arcade')}" }
      ]
    }])
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!slots)
# ------------------------------------------
$bot.command(:slots, aliases: [:slot],
  description: 'Spin the neon slots!', 
  category: 'Arcade'
) do |event, amount_str|
  # Argument Check: Ensure an amount was provided
  if amount_str.nil?
    send_cv2(event, [{
      type: 17, accent_color: 0xFF0000,
      components: [
        { type: 10, content: "## #{EMOJI_STRINGS['confused']} Missing Arguments" },
        { type: 14, spacing: 1 },
        { type: 10, content: "The machine doesn't spin itself, chat. Tell me how much to bet.\n\n**Usage:** `#{PREFIX}slots <amount>`" }
      ]
    }])
    next
  end

  # Execute logic with integer casting
  execute_slots(event, amount_str.to_i)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/slots)
# ------------------------------------------
$bot.application_command(:slots) do |event|
  # Slash commands handle integer conversion automatically
  execute_slots(event, event.options['amount'])
end