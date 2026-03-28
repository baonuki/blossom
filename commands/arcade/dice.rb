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
    return send_cv2(event, [{
      type: 17, accent_color: 0xFF0000,
      components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} Invalid Bet" },
        { type: 14, spacing: 1 },
        { type: 10, content: "You're broke or you typed something unhinged. Check your balance and try again." }
      ]
    }])
  end

  # 3. Validation: Ensure the bet type is recognized
  unless ['high', 'low', '7'].include?(bet)
    return send_cv2(event, [{
      type: 17, accent_color: 0xFF0000,
      components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} Invalid Bet Type" },
        { type: 14, spacing: 1 },
        { type: 10, content: "That's not how this works. Pick `high`, `low`, or `7`. Reading is free, chat." }
      ]
    }])
  end

  # 4. Database: Deduct the initial bet amount
  DB.add_coins(uid, -amount)

  # 5. Simulation: Roll two 6-sided dice
  die1 = rand(1..6)
  die2 = rand(1..6)
  total = die1 + die2

  # 6. Logic: Categorize the actual result
  actual_result = total < 7 ? 'low' : (total > 7 ? 'high' : '7')

  # 7. Achievements
  check_achievement(event.channel, uid, 'dice_play')
  check_achievement(event.channel, uid, 'gamble_10k') if amount >= 10000

  # 8. Result: Handle the win/loss branching
  if bet == actual_result
    base_payout = (bet == '7') ? (amount * 4) : (amount * 2)
    payout_result = arcade_payout(event.bot, uid, base_payout)
    DB.add_coins(uid, payout_result[:winnings])
    extras = arcade_win_extras(uid, payout_result)
    check_achievement(event.channel, uid, 'dice_seven') if bet == '7'

    inner = [
      { type: 10, content: "## 🎲 High Roller Dice" },
      { type: 14, spacing: 1 },
      { type: 10, content: "The dice roll... **#{die1}** and **#{die2}**! (Total: **#{total}**)\n\nOkay not bad, chat. You called **#{bet}** and walked away with **#{payout_result[:winnings]}** #{EMOJI_STRINGS['s_coin']}.#{extras[:text]}\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJI_STRINGS['s_coin']}#{mom_remark(uid, 'arcade')}" }
    ]
    inner << extras[:button] if extras[:button]
    send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: inner }])
  else
    check_achievement(event.channel, uid, 'gamble_broke') if amount >= 5000
    send_cv2(event, [{
      type: 17, accent_color: 0xFF0000,
      components: [
        { type: 10, content: "## 🎲 High Roller Dice" },
        { type: 14, spacing: 1 },
        { type: 10, content: "The dice roll... **#{die1}** and **#{die2}**! (Total: **#{total}**)\n\nYou bet **#{bet}** and ate it HARD. **#{amount}** #{EMOJI_STRINGS['s_coin']} gone. Tragic.\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJI_STRINGS['s_coin']}#{mom_remark(uid, 'arcade')}" }
      ]
    }])
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!dice)
# ------------------------------------------
$bot.command(:dice, aliases: [:di],
  description: 'Roll 2d6! Bet on high (8-12), low (2-6), or 7.', 
  category: 'Arcade'
) do |event, amount_str, bet|
  # Argument Check: Ensure both inputs exist
  if amount_str.nil? || bet.nil?
    send_cv2(event, [{
      type: 17, accent_color: 0xFF0000,
      components: [
        { type: 10, content: "## #{EMOJI_STRINGS['confused']} Missing Arguments" },
        { type: 14, spacing: 1 },
        { type: 10, content: "You forgot like... half the command. I need an amount and a call, chat.\n\n**Usage:** `#{PREFIX}dice <amount> <high/low/7>`" }
      ]
    }])
    next
  end

  execute_dice(event, amount_str.to_i, bet)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/dice)
# ------------------------------------------
$bot.application_command(:dice) do |event|
  # Slash commands handle data types automatically
  execute_dice(event, event.options['amount'], event.options['bet'])
end