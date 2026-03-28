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
    return send_cv2(event, [{
      type: 17, accent_color: 0xFF0000,
      components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} Invalid Bet" },
        { type: 14, spacing: 1 },
        { type: 10, content: "You're either broke or can't type a number. Either way, skill issue." }
      ]
    }])
  end

  # 3. Validation: Ensure the user picked a valid cup (1, 2, or 3)
  unless [1, 2, 3].include?(guess)
    return send_cv2(event, [{
      type: 17, accent_color: 0xFF0000,
      components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} Invalid Cup" },
        { type: 14, spacing: 1 },
        { type: 10, content: "There are THREE cups. Pick `1`, `2`, or `3`. That's not hard, chat." }
      ]
    }])
  end

  # 4. Calculation: Deduct the bet and determine the winning cup
  DB.add_coins(uid, -amount)
  winning_cup = [1, 2, 3].sample
  
  # 5. UI Logic: Create the visual "lifted cups" display string
  cups_display = [1, 2, 3].map { |c| c == winning_cup ? EMOJI_STRINGS['s_coin'] : '🥤' }.join('   ')

  # 6. Achievements
  check_achievement(event.channel, uid, 'cups_play')
  check_achievement(event.channel, uid, 'gamble_10k') if amount >= 10000

  # 7. Result: Handle the win or loss scenarios
  if guess == winning_cup
    # Win: Triple the original bet!
    payout_result = arcade_payout(event.bot, uid, amount * 3)
    DB.add_coins(uid, payout_result[:winnings])
    extras = arcade_win_extras(uid, payout_result)

    inner = [
      { type: 10, content: "## 🥤 The Shell Game" },
      { type: 14, spacing: 1 },
      { type: 10, content: "I lift cup ##{winning_cup}...\n\n**#{cups_display}**\n\nNO WAY you actually found it?! GG, take your **#{payout_result[:winnings]}** #{EMOJI_STRINGS['s_coin']}.#{extras[:text]}\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJI_STRINGS['s_coin']}#{mom_remark(uid, 'arcade')}" }
    ]
    inner << extras[:button] if extras[:button]
    send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: inner }])
  else
    # Loss: The user picked wrong; reveal where it was
    send_cv2(event, [{
      type: 17, accent_color: 0xFF0000,
      components: [
        { type: 10, content: "## 🥤 The Shell Game" },
        { type: 14, spacing: 1 },
        { type: 10, content: "I lift cup ##{guess} and... NOTHING. LOL it was under cup ##{winning_cup} the whole time.\n\n**#{cups_display}**\n\nSkill issue. **#{amount}** #{EMOJI_STRINGS['s_coin']} mine now.\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJI_STRINGS['s_coin']}#{mom_remark(uid, 'arcade')}" }
      ]
    }])
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!cups)
# ------------------------------------------
$bot.command(:cups, aliases: [:cup],
  description: 'Guess which cup hides the coin (1, 2, or 3)!', 
  category: 'Arcade'
) do |event, amount_str, guess_str|
  # Argument Check: Ensure amount and guess are provided
  if amount_str.nil? || guess_str.nil?
    send_cv2(event, [{
      type: 17, accent_color: 0xFF0000,
      components: [
        { type: 10, content: "## #{EMOJI_STRINGS['confused']} Missing Arguments" },
        { type: 14, spacing: 1 },
        { type: 10, content: "Uh, hello?? I need a bet amount AND a cup number, chat.\n\n**Usage:** `#{PREFIX}cups <amount> <1/2/3>`" }
      ]
    }])
    next
  end

  # Execute logic with integer casting
  execute_cups(event, amount_str.to_i, guess_str.to_i)
  nil
end

# ------------------------------------------
# TRIGGER: Slash Command (/cups)
# ------------------------------------------
$bot.application_command(:cups) do |event|
  # Slash commands handle integer casting automatically based on the command definition
  execute_cups(event, event.options['amount'], event.options['guess'])
end