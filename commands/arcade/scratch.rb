def execute_scratch(event)
  uid = event.user.id
  ticket_price = 500

  if DB.get_coins(uid) < ticket_price
    return send_embed(event, title: "#{EMOJIS['nervous']} Insufficient Funds", description: "You need **#{ticket_price}** #{EMOJIS['s_coin']} to buy a scratch-off ticket.")
  end

  DB.add_coins(uid, -ticket_price)

  pool = ['💀', '💀', '💀', '🍒', '🍒', '🍋', '🍋', '💎', '🌟']
  result = [pool.sample, pool.sample, pool.sample]

  if result.uniq.size == 1
    payout = case result[0]
             when '🌟' then 10000 
             when '💎' then 5000  
             when '🍋' then 2500  
             when '🍒' then 1000  
             when '💀' then 500   
             else 0
             end

    DB.add_coins(uid, payout)
    send_embed(event, title: "🎫 Scratch-Off Ticket", description: "**[ #{result.join(' | ')} ]**\n\n**WINNER!** You matched three **#{result[0]}** and won **#{payout}** #{EMOJIS['s_coin']}!\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}")
  else
    send_embed(event, title: "🎫 Scratch-Off Ticket", description: "**[ #{result.join(' | ')} ]**\n\nNo match... Better luck next ticket. #{EMOJIS['worktired']}\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}")
  end
end

bot.command(:scratch, description: 'Buy a neon scratch-off ticket for 500 coins!', category: 'Arcade') do |event|
  execute_scratch(event)
  nil
end

bot.application_command(:scratch) do |event|
  execute_scratch(event)
end