def execute_dice(event, amount, bet)
  uid = event.user.id
  bet = bet.downcase

  if amount <= 0 || DB.get_coins(uid) < amount
    return send_embed(event, title: "#{EMOJIS['error']} Invalid Bet", description: "You don't have enough coins or entered an invalid amount!")
  end

  unless ['high', 'low', '7'].include?(bet)
    return send_embed(event, title: "#{EMOJIS['error']} Invalid Bet Type", description: "You can only bet on `high`, `low`, or `7`.")
  end

  DB.add_coins(uid, -amount)
  die1 = rand(1..6)
  die2 = rand(1..6)
  total = die1 + die2

  actual_result = total < 7 ? 'low' : (total > 7 ? 'high' : '7')

  if bet == actual_result
    payout = (bet == '7') ? (amount * 4) : (amount * 2)
    DB.add_coins(uid, payout)
    send_embed(event, title: "🎲 High Roller Dice", description: "The dice roll... **#{die1}** and **#{die2}**! (Total: **#{total}**)\n\nYou correctly bet on **#{bet}** and won **#{payout}** #{EMOJIS['s_coin']}!\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}")
  else
    send_embed(event, title: "🎲 High Roller Dice", description: "The dice roll... **#{die1}** and **#{die2}**! (Total: **#{total}**)\n\nYou bet on **#{bet}** and lost **#{amount}** #{EMOJIS['s_coin']}.\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}")
  end
end

bot.command(:dice, description: 'Roll 2d6! Bet on high (8-12), low (2-6), or 7.', category: 'Arcade') do |event, amount_str, bet|
  if amount_str.nil? || bet.nil?
    send_embed(event, title: "#{EMOJIS['confused']} Missing Arguments", description: "Place your bets on the dice!\n\n**Usage:** `#{PREFIX}dice <amount> <high/low/7>`")
    next
  end
  execute_dice(event, amount_str.to_i, bet)
  nil
end

bot.application_command(:dice) do |event|
  execute_dice(event, event.options['amount'], event.options['bet'])
end