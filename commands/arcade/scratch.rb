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
    return send_embed(event, 
      title: "#{EMOJIS['nervous']} Insufficient Funds", 
      description: "You need **#{ticket_price}** #{EMOJIS['s_coin']} to buy a scratch-off ticket."
    )
  end

  # 3. Database: Deduct the price immediately (No refunds on scratchers!)
  DB.add_coins(uid, -ticket_price)

  # 4. Calculation: Define the weighted pool and pull 3 random symbols
  pool = ['💀', '💀', '💀', '🍒', '🍒', '🍋', '🍋', '💎', '🌟']
  result = [pool.sample, pool.sample, pool.sample]

  # 5. Logic: Check for a match (using .uniq.size == 1 confirms all items are identical)
  if result.uniq.size == 1
    # 6. Payout Mapping: Determine the prize based on the winning symbol
    payout = case result[0]
             when '🌟' then 10000 
             when '💎' then 5000  
             when '🍋' then 2500  
             when '🍒' then 1000  
             when '💀' then 500   
             else 0
             end

    # 7. Database: Grant the payout to the user
    DB.add_coins(uid, payout)
    
    # 8. UI: Send the "Winner" response
    send_embed(event, 
      title: "🎫 Scratch-Off Ticket", 
      description: "**[ #{result.join(' | ')} ]**\n\n**WINNER!** You matched three **#{result[0]}** and won **#{payout}** #{EMOJIS['s_coin']}!\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}"
    )
  else
    # 9. UI: Send the "Loss" response
    send_embed(event, 
      title: "🎫 Scratch-Off Ticket", 
      description: "**[ #{result.join(' | ')} ]**\n\nNo match... Better luck next ticket. #{EMOJIS['worktired']}\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}"
    )
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!scratch)
# ------------------------------------------
bot.command(:scratch, 
  description: 'Buy a neon scratch-off ticket for 500 coins!', 
  category: 'Arcade'
) do |event|
  execute_scratch(event)
  nil # Suppress automatic response
end

# ------------------------------------------
# TRIGGER: Slash Command (/scratch)
# ------------------------------------------
bot.application_command(:scratch) do |event|
  execute_scratch(event)
end