def execute_coinflip(event, amount, choice)
  uid = event.user.id
  choice = choice.downcase

  if amount <= 0
    return send_embed(event, title: "#{EMOJIS['error']} Invalid Bet", description: "You must bet at least 1 #{EMOJIS['s_coin']}.")
  end

  if DB.get_coins(uid) < amount
    return send_embed(event, title: "#{EMOJIS['nervous']} Insufficient Funds", description: "You don't have enough coins to cover that bet!\nYou currently have **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}.")
  end

  unless ['heads', 'tails'].include?(choice)
    return send_embed(event, title: "#{EMOJIS['error']} Invalid Choice", description: "Please pick either `heads` or `tails`.")
  end

  result = ['heads', 'tails'].sample
  DB.add_coins(uid, -amount)
  
  if choice == result
    DB.add_coins(uid, amount * 2)
    send_embed(event, title: "🪙 Coinflip: #{result.capitalize}!", description: "You won! You doubled your bet and earned **#{amount}** #{EMOJIS['s_coin']}.\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}")
    check_achievement(event.channel, event.user.id, 'gamble_win')
  else
    send_embed(event, title: "🪙 Coinflip: #{result.capitalize}!", description: "You lost... **#{amount}** #{EMOJIS['s_coin']} down the drain.\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}")
  end
end

bot.command(:coinflip, description: 'Bet your stream revenue on a coinflip!', category: 'Arcade') do |event, amount_str, choice|
  if amount_str.nil? || choice.nil?
    send_embed(event, title: "#{EMOJIS['confused']} Missing Arguments", description: "You need to tell me how much to bet and what side you want!\n\n**Usage:** `#{PREFIX}coinflip <amount> <heads/tails>`")
    next
  end
  execute_coinflip(event, amount_str.to_i, choice)
  nil
end

bot.application_command(:coinflip) do |event|
  execute_coinflip(event, event.options['amount'], event.options['choice'])
end