def execute_givecoins(event, target, amount_str)
  uid = event.user.id
  amount = amount_str.to_i

  if target.nil? || target.id == uid
    return send_embed(event, title: "⚠️ Invalid Target", description: "You need to mention another user to give coins to!")
  end

  if amount <= 0
    return send_embed(event, title: "⚠️ Invalid Amount", description: "You must give at least 1 #{EMOJIS['s_coin']}.")
  end

  if DB.get_coins(uid) < amount
    return send_embed(event, title: "#{EMOJIS['nervous']} Insufficient Funds", description: "You don't have **#{amount}** #{EMOJIS['s_coin']} to give!")
  end

  DB.add_coins(uid, -amount)
  DB.add_coins(target.id, amount)

  send_embed(
    event, 
    title: "💸 Coins Transferred!", 
    description: "#{event.user.mention} gave **#{amount}** #{EMOJIS['s_coin']} to #{target.mention}!\n\nYour new balance: **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}"
  )
end

bot.command(:givecoins, description: 'Give your coins to another user', category: 'Economy') do |event, mention, amount|
  execute_givecoins(event, event.message.mentions.first, amount)
  nil
end

bot.application_command(:givecoins) do |event|
  target = event.bot.user(event.options['user'].to_i)
  execute_givecoins(event, target, event.options['amount'])
end