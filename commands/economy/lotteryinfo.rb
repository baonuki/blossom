# ==========================================
# COMMAND: lotteryinfo
# DESCRIPTION: View the global lottery prize pool and personal ticket status.
# CATEGORY: Economy / Global Events
# ==========================================

# ------------------------------------------
# LOGIC: Lottery Info Execution
# ------------------------------------------
def execute_lotteryinfo(event)
  # 1. Initialization: Get user ID and fetch global lottery stats
  uid = event.user.id
  stats = DB.get_lottery_stats(uid)
  
  # 2. Calculation: Determine the current prize pool (Base 100 + 100 per ticket)
  pool = 100 + (stats[:total_tickets] * 100)
  
  # 3. Time Math: Calculate the "Top of the Hour" for the next drawing
  now = Time.now
  next_hour = Time.new(now.year, now.month, now.day, now.hour) + 3600
  
  # 4. UI: Send the status summary via Embed
  send_embed(
    event,
    title: "🎟️ Global Lottery Status",
    description: "The winning ticket will be drawn **<t:#{next_hour.to_i}:R>**!\n\n" \
                 "💰 **Current Prize Pool:** #{pool} #{EMOJIS['s_coin']}\n" \
                 "🎫 **Total Tickets Sold:** #{stats[:total_tickets]}\n" \
                 "🌸 **Your Tickets:** #{stats[:user_tickets]}\n\n" \
                 "*Want to increase your odds? Use `#{PREFIX}lottery <amount>`!*"
  )
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!lotteryinfo)
# ------------------------------------------
bot.command(:lotteryinfo, 
  description: 'View current lottery stats and your tickets', 
  category: 'Economy'
) do |event|
  execute_lotteryinfo(event)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/lotteryinfo)
# ------------------------------------------
bot.application_command(:lotteryinfo) do |event|
  execute_lotteryinfo(event)
end