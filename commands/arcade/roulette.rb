# ==========================================
# COMMAND: roulette
# DESCRIPTION: A full-featured roulette game allowing bets on colors, parity, or numbers.
# CATEGORY: Arcade
# ==========================================

# ------------------------------------------
# LOGIC: Roulette Execution
# ------------------------------------------
def execute_roulette(event, amount, bet)
  # 1. Initialization: Get user ID and normalize the bet string
  uid = event.user.id
  bet = bet.to_s.downcase.strip

  # 2. Validation: Check for valid amount and sufficient funds
  if amount <= 0 || DB.get_coins(uid) < amount
    return send_cv2(event, [{
      type: 17, accent_color: 0xFF0000,
      components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} Invalid Bet" },
        { type: 14, spacing: 1 },
        { type: 10, content: "You can't afford to sit at this table, bestie. Check your balance." }
      ]
    }])
  end

  # 3. Data Map: Define the standard European Roulette red numbers
  red_numbers = [1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36]
  
  # 4. Validation: Create a list of all acceptable bet strings
  valid_bets = ['red', 'black', 'even', 'odd'] + (0..36).map(&:to_s)

  unless valid_bets.include?(bet)
    return send_cv2(event, [{
      type: 17, accent_color: 0xFF0000,
      components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} Invalid Bet Type" },
        { type: 14, spacing: 1 },
        { type: 10, content: "That's not a real bet?? Try `red`, `black`, `even`, `odd`, or a number `0`-`36`. Come on, chat." }
      ]
    }])
  end

  # 5. Database: Deduct the initial bet amount
  DB.add_coins(uid, -amount)

  # 6. Simulation: Spin the wheel (0-36)
  spin = rand(0..36)
  
  # 7. Logic: Determine the color of the landed number
  spin_color = 'green' # Default for 0
  if red_numbers.include?(spin)
    spin_color = 'red'
  elsif spin != 0
    spin_color = 'black'
  end

  # 8. Logic: Determine parity (Even/Odd), excluding zero
  is_even = (spin != 0 && spin.even?) ? 'even' : nil
  is_odd = (spin != 0 && spin.odd?) ? 'odd' : nil

  # 9. Calculation: Check for Win and determine Payout
  win = false
  payout = 0

  if bet == spin.to_s
    # Single Number Win: 36x payout
    win = true
    payout = amount * 36
  elsif bet == spin_color || bet == is_even || bet == is_odd
    # Outside Bet Win (Red/Black/Even/Odd): 2x payout
    win = true
    payout = amount * 2 
  end

  # 10. UI Logic: Select the appropriate emoji for the result color
  color_emoji = spin_color == 'red' ? '🔴' : (spin_color == 'black' ? '⚫' : '🟢')

  # 11. Achievements
  check_achievement(event.channel, uid, 'roulette_play')
  check_achievement(event.channel, uid, 'gamble_10k') if amount >= 10000

  # 12. Result: Handle the win/loss feedback
  if win
    track_arcade(uid, true)
    payout_result = arcade_payout(event.bot, uid, payout)
    DB.add_coins(uid, payout_result[:winnings])
    extras = arcade_win_extras(uid, payout_result)
    check_achievement(event.channel, uid, 'roulette_number') if bet == spin.to_s

    inner = [
      { type: 10, content: "## 🎰 Roulette Spin" },
      { type: 14, spacing: 1 },
      { type: 10, content: "I spin the wheel... it lands on **#{color_emoji} #{spin}**!\n\nYou called **#{bet}** and it ACTUALLY hit. Pog. **#{payout_result[:winnings]}** #{EMOJI_STRINGS['s_coin']} yours.#{extras[:text]}\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJI_STRINGS['s_coin']}#{mom_remark(uid, 'arcade')}" }
    ]
    inner << extras[:button] if extras[:button]
    send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: inner }])
  else
    track_arcade(uid, false)
    check_achievement(event.channel, uid, 'gamble_broke') if amount >= 5000
    send_cv2(event, [{
      type: 17, accent_color: 0xFF0000,
      components: [
        { type: 10, content: "## 🎰 Roulette Spin" },
        { type: 14, spacing: 1 },
        { type: 10, content: "I spin the wheel... it lands on **#{color_emoji} #{spin}**.\n\nYou bet **#{bet}**. Not even close. **#{amount}** #{EMOJI_STRINGS['s_coin']} evaporated.\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJI_STRINGS['s_coin']}#{mom_remark(uid, 'arcade')}" }
      ]
    }])
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!roulette)
# ------------------------------------------
$bot.command(:roulette, aliases: [:rl],
  description: 'Bet on the roulette wheel!', 
  category: 'Arcade'
) do |event, amount_str, bet_str|
  # Argument Check: Ensure both inputs are present
  if amount_str.nil? || bet_str.nil?
    send_cv2(event, [{
      type: 17, accent_color: 0xFF0000,
      components: [
        { type: 10, content: "## #{EMOJI_STRINGS['confused']} Missing Arguments" },
        { type: 14, spacing: 1 },
        { type: 10, content: "You literally gave me nothing to work with. Amount AND bet, chat.\n\n**Usage:** `#{PREFIX}roulette <amount> <bet>`\n**Valid Bets:** `red`, `black`, `even`, `odd`, or a number `0-36`." }
      ]
    }])
    next
  end

  execute_roulette(event, amount_str.to_i, bet_str)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/roulette)
# ------------------------------------------
$bot.application_command(:roulette) do |event|
  # Execute logic using Slash Command options
  execute_roulette(event, event.options['amount'], event.options['bet'])
end