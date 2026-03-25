def execute_cups(event, amount, guess)
  uid = event.user.id

  if amount <= 0 || DB.get_coins(uid) < amount
    return send_embed(event, title: "#{EMOJIS['error']} Invalid Bet", description: "You don't have enough coins or entered an invalid amount!")
  end

  unless [1, 2, 3].include?(guess)
    return send_embed(event, title: "#{EMOJIS['error']} Invalid Cup", description: "You must pick cup `1`, `2`, or `3`.")
  end

  DB.add_coins(uid, -amount)
  winning_cup = [1, 2, 3].sample
  cups_display = [1, 2, 3].map { |c| c == winning_cup ? '🪙' : '🥤' }.join('   ')

  if guess == winning_cup
    payout = amount * 3
    DB.add_coins(uid, payout)
    send_embed(event, title: "🥤 The Shell Game", description: "Blossom lifts cup ##{winning_cup}...\n\n**#{cups_display}**\n\nYou found it! You won **#{payout}** #{EMOJIS['s_coin']}!\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}")
  else
    send_embed(event, title: "🥤 The Shell Game", description: "Blossom lifts cup ##{guess}...\nEmpty! The coin was under cup ##{winning_cup}.\n\n**#{cups_display}**\n\nYou lost **#{amount}** #{EMOJIS['s_coin']}.\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}")
  end
end

bot.command(:cups, description: 'Guess which cup hides the coin (1, 2, or 3)!', category: 'Arcade') do |event, amount_str, guess_str|
  if amount_str.nil? || guess_str.nil?
    send_embed(event, title: "#{EMOJIS['confused']} Missing Arguments", description: "Keep your eye on the cup!\n\n**Usage:** `#{PREFIX}cups <amount> <1/2/3>`")
    next
  end
  execute_cups(event, amount_str.to_i, guess_str.to_i)
  nil
end

bot.application_command(:cups) do |event|
  execute_cups(event, event.options['amount'], event.options['guess'])
end