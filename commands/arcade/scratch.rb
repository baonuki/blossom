# ==========================================
# COMMAND: scratch
# DESCRIPTION: Purchase a 500-coin scratch ticket for a chance to win up to 10k.
# CATEGORY: Arcade
# ==========================================

# ------------------------------------------
# LOGIC: Scratch-Off Execution
# ------------------------------------------
def execute_scratch(event)
  # 1. Initialization: Set the user ID and fixed ticket price
  uid = event.user.id
  ticket_price = 500

  # 2. Validation: Check if the user can afford the ticket
  if DB.get_coins(uid) < ticket_price
    return send_cv2(event, [{
      type: 17, accent_color: 0xFF0000,
      components: [
        { type: 10, content: "## #{EMOJI_STRINGS['nervous']} Insufficient Funds" },
        { type: 14, spacing: 1 },
        { type: 10, content: "A ticket costs **#{ticket_price}** #{EMOJI_STRINGS['s_coin']} and you don't even have that. Down bad." }
      ]
    }])
  end

  # 3. Database: Deduct the price immediately (No refunds on scratchers!)
  DB.add_coins(uid, -ticket_price)

  # 4. Calculation: Define the weighted pool and pull 3 random symbols
  pool = ['💀', '💀', '💀', '🍒', '🍒', '🍋', '🍋', '💎', '🌟']
  result = [pool.sample, pool.sample, pool.sample]

  # 5. Achievements
  check_achievement(event.channel, uid, 'scratch_play')

  # 6. Logic: Check for a match (using .uniq.size == 1 confirms all items are identical)
  if result.uniq.size == 1
    track_arcade(uid, true)
    # 6. Payout Mapping: Determine the prize based on the winning symbol
    payout = case result[0]
             when '🌟' then 10000 
             when '💎' then 5000  
             when '🍋' then 2500  
             when '🍒' then 1000  
             when '💀' then 500   
             else 0
             end

    # 7. Database: Grant the payout to the user with premium perks
    payout_result = arcade_payout(event.bot, uid, payout)
    DB.add_coins(uid, payout_result[:winnings])
    extras = arcade_win_extras(uid, payout_result)
    check_achievement(event.channel, uid, 'scratch_jackpot') if result[0] == '🌟'

    # 8. UI: Send the "Winner" response
    inner = [
      { type: 10, content: "## 🎫 Scratch-Off Ticket" },
      { type: 14, spacing: 1 },
      { type: 10, content: "**[ #{result.join(' | ')} ]**\n\nACTUALLY POG?! Triple **#{result[0]}**!! You just snagged **#{payout_result[:winnings]}** #{EMOJI_STRINGS['s_coin']}!#{extras[:text]}\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJI_STRINGS['s_coin']}#{mom_remark(uid, 'arcade')}" }
    ]
    inner << extras[:button] if extras[:button]
    send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: inner }])
  else
    track_arcade(uid, false)
    # 9. UI: Send the "Loss" response
    send_cv2(event, [{
      type: 17, accent_color: 0xFF0000,
      components: [
        { type: 10, content: "## 🎫 Scratch-Off Ticket" },
        { type: 14, spacing: 1 },
        { type: 10, content: "**[ #{result.join(' | ')} ]**\n\nNothing. Not even close. Thanks for the donation tho~ 😩\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJI_STRINGS['s_coin']}#{mom_remark(uid, 'arcade')}" }
      ]
    }])
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!scratch)
# ------------------------------------------
$bot.command(:scratch, aliases: [:sc],
  description: 'Buy a neon scratch-off ticket for 500 coins!', 
  category: 'Arcade'
) do |event|
  execute_scratch(event)
  nil # Suppress automatic response
end

# ------------------------------------------
# TRIGGER: Slash Command (/scratch)
# ------------------------------------------
$bot.application_command(:scratch) do |event|
  execute_scratch(event)
end