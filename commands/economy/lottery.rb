# ==========================================
# COMMAND: lottery
# DESCRIPTION: Enter the global hourly lottery for a chance at a massive coin jackpot.
# CATEGORY: Economy / Global Events
# ==========================================

# ------------------------------------------
# LOGIC: Lottery Entry Execution
# ------------------------------------------
def execute_lottery(event, amount)
  # 1. Initialization: Standardize ticket amount (minimum 1)
  uid = event.user.id
  amount = amount.to_i
  amount = 1 if amount <= 0

  # 2. Validation: Calculate cost and check user's global balance
  cost = amount * 100
  balance = DB.get_coins(uid)

  if balance < cost
    return send_embed(event, 
      title: "❌ Not Enough Coins", 
      description: "You need **#{cost}** #{EMOJIS['s_coin']} for #{amount} tickets!\nYour Balance: **#{balance}**"
    )
  end

  # 3. Database: Deduct the cost and record the lottery entry
  DB.add_coins(uid, -cost)
  DB.enter_lottery(uid, amount)
  
  # 4. Data Retrieval: Fetch fresh stats for the prize pool calculation
  stats = DB.get_lottery_stats(uid)
  
  # 5. Calculation: Determine the current prize pool 
  # (Base 100 coins + 100 coins for every ticket sold globally)
  pool = 100 + (stats[:total_tickets] * 100)

  # 6. UI: Construct the entry confirmation Embed
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

# ------------------------------------------
# TRIGGER: Prefix Command (b!lottery)
# ------------------------------------------
bot.command(:lottery, 
  description: 'Buy tickets for the hourly global lottery!',
  category: 'Economy'
) do |event, amount|
  # Default to 1 ticket if no argument is provided
  execute_lottery(event, amount || 1)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/lottery)
# ------------------------------------------
bot.application_command(:lottery) do |event|
  # Capture Slash option for tickets or default to 1
  execute_lottery(event, event.options['tickets'] || 1)
end