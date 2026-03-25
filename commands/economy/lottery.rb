def execute_lottery(event, amount)
  uid = event.user.id
  amount = amount.to_i
  amount = 1 if amount <= 0

  cost = amount * 100
  balance = DB.get_coins(uid)

  if balance < cost
    return send_embed(event, title: "❌ Not Enough Coins", description: "You need **#{cost}** #{EMOJIS['s_coin']} for #{amount} tickets!\nYour Balance: **#{balance}**")
  end

  DB.add_coins(uid, -cost)
  DB.enter_lottery(uid, amount)
  
  stats = DB.get_lottery_stats(uid)
  pool = 100 + (stats[:total_tickets] * 100)

  send_embed(
    event, 
    title: "🎟️ Lottery Entered!", 
    description: "You bought **#{amount}** tickets! 🌸\n\n" \
                 "💰 **Current Prize Pool:** #{pool} #{EMOJIS['s_coin']}\n" \
                 "🎫 **Total Tickets Sold:** #{stats[:total_tickets]}\n" \
                 "👤 **Your Tickets:** #{stats[:user_tickets]}\n\n" \
                 "*Blossom will DM the winner at the top of the hour!*"
  )
end

bot.command(:lottery, description: 'Buy tickets for the hourly global lottery!') do |event, amount|
  execute_lottery(event, amount || 1)
  nil
end

bot.application_command(:lottery) do |event|
  execute_lottery(event, event.options['tickets'] || 1)
end