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
    return send_cv2(event, [{
      type: 17, accent_color: 0xFF0000,
      components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} Invalid Bet" },
        { type: 14, spacing: 1 },
        { type: 10, content: "You gotta put SOMETHING on the line. Bet at least 1 #{EMOJI_STRINGS['s_coin']}, cheapskate." }
      ]
    }])
  end

  # 3. Validation: Check the user's balance in the Database
  if DB.get_coins(uid) < amount
    return send_cv2(event, [{
      type: 17, accent_color: 0xFF0000,
      components: [
        { type: 10, content: "## #{EMOJI_STRINGS['nervous']} Insufficient Funds" },
        { type: 14, spacing: 1 },
        { type: 10, content: "You're broke, chat. You can't afford that.\nYou've got **#{DB.get_coins(uid)}** #{EMOJI_STRINGS['s_coin']}. Work with what you have." }
      ]
    }])
  end

  # 4. Validation: Ensure the choice is valid (Heads or Tails)
  unless ['heads', 'tails'].include?(choice)
    return send_cv2(event, [{
      type: 17, accent_color: 0xFF0000,
      components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} Invalid Choice" },
        { type: 14, spacing: 1 },
        { type: 10, content: "It's heads or tails. That's literally it. Pick one." }
      ]
    }])
  end

  # 5. Calculation: Determine the result and deduct the initial bet
  result = ['heads', 'tails'].sample
  DB.add_coins(uid, -amount)
  check_achievement(event.channel, uid, 'gamble_10k') if amount >= 10000

  # 6. Result: Handle the Win/Loss scenarios
  if choice == result
    track_arcade(uid, true)
    payout_result = arcade_payout(event.bot, uid, amount * 2)
    DB.add_coins(uid, payout_result[:winnings])
    extras = arcade_win_extras(uid, payout_result)

    inner = [
      { type: 10, content: "## #{EMOJI_STRINGS['s_coin']} Coinflip: #{result.capitalize}!" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Okay wait, you actually hit?? GG, you snagged **#{payout_result[:winnings]}** #{EMOJI_STRINGS['s_coin']}!#{extras[:text]}\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJI_STRINGS['s_coin']}#{mom_remark(uid, 'arcade')}" }
    ]
    inner << extras[:button] if extras[:button]
    send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: inner }])
    check_achievement(event.channel, uid, 'gamble_win')
  else
    track_arcade(uid, false)
    check_achievement(event.channel, uid, 'gamble_broke') if amount >= 5000
    send_cv2(event, [{
      type: 17, accent_color: 0xFF0000,
      components: [
        { type: 10, content: "## #{EMOJI_STRINGS['s_coin']} Coinflip: #{result.capitalize}!" },
        { type: 14, spacing: 1 },
        { type: 10, content: "Tragic. Absolutely tragic. **#{amount}** #{EMOJI_STRINGS['s_coin']} gone, just like that.\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJI_STRINGS['s_coin']}#{mom_remark(uid, 'arcade')}" }
      ]
    }])
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!coinflip)
# ------------------------------------------
$bot.command(:coinflip, aliases: [:cf, :flip],
  description: 'Bet your stream revenue on a coinflip!', 
  category: 'Arcade'
) do |event, amount_str, choice|
  # Argument Check: Ensure both amount and choice are present
  if amount_str.nil? || choice.nil?
    send_cv2(event, [{
      type: 17, accent_color: 0xFF0000,
      components: [
        { type: 10, content: "## #{EMOJI_STRINGS['confused']} Missing Arguments" },
        { type: 14, spacing: 1 },
        { type: 10, content: "Did you forget how to type? I need an amount AND a side, chat.\n\n**Usage:** `#{PREFIX}coinflip <amount> <heads/tails>`" }
      ]
    }])
    next
  end

  execute_coinflip(event, amount_str.to_i, choice)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/coinflip)
# ------------------------------------------
$bot.application_command(:coinflip) do |event|
  # Options are automatically cast to the correct type by discordrb for Slash
  execute_coinflip(event, event.options['amount'], event.options['choice'])
end