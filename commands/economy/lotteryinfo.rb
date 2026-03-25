bot.command(:lotteryinfo, description: 'View current lottery stats and your tickets', category: 'Economy') do |event|
  execute_lotteryinfo(event)
  nil
end

bot.application_command(:lotteryinfo) do |event|
  execute_lotteryinfo(event)
end

def execute_lotteryinfo(event)
  uid = event.user.id
  stats = DB.get_lottery_stats(uid)
  
  pool = 100 + (stats[:total_tickets] * 100)
  
  now = Time.now
  next_hour = Time.new(now.year, now.month, now.day, now.hour) + 3600
  
  send_embed(
    event,
    title: "🎟️ Global Lottery Status",
    description: "The winning ticket will be drawn **<t:#{next_hour.to_i}:R>**!\n\n" \
                 "💰 **Current Prize Pool:** #{pool} #{EMOJIS['s_coin']}\n" \
                 "🎫 **Total Tickets Sold:** #{stats[:total_tickets]}\n" \
                 "🌸 **Your Tickets:** #{stats[:user_tickets]}\n\n" \
                 "*Want to increase your odds? Use `b!lottery <amount>`!*"
  )
end