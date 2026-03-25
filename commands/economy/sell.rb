# ==========================================
# COMMAND: sell
# DESCRIPTION: Mass-sell duplicate cards based on rarity or count filters.
# CATEGORY: Economy / Collection Management
# ==========================================

# ------------------------------------------
# LOGIC: Mass Sell Execution
# ------------------------------------------
def execute_sell(event, filter, rarity_opt = nil)
  # 1. Initialization: Get user ID and normalize the primary filter
  uid = event.user.id
  filter = filter&.downcase

  # 2. Validation: Ensure the filter type is recognized
  valid_filters = ['all', 'over5', 'rarity']
  unless valid_filters.include?(filter)
    return send_embed(event, 
      title: "⚠️ Invalid Filter", 
      description: "Please use a valid filter: `all`, `over5`, or `rarity <type>`.\nExample: `#{PREFIX}sell over5`"
    )
  end

  # 3. Validation: If using the 'rarity' filter, ensure a valid rarity was provided
  if filter == 'rarity'
    valid_rarities = ['common', 'rare', 'legendary', 'goddess']
    unless valid_rarities.include?(rarity_opt&.downcase)
      return send_embed(event, 
        title: "⚠️ Missing Rarity", 
        description: "Please specify a rarity: `common`, `rare`, `legendary`, or `goddess`.\nExample: `#{PREFIX}sell rarity common`"
      )
    end
    target_rarity = rarity_opt.downcase
  else
    target_rarity = nil
  end

  # 4. Data Retrieval: Fetch the user's full character collection
  col = DB.get_collection(uid)
  coins_earned = 0
  sold_count = 0

  # 5. Iteration: Loop through every card owned by the user
  col.each do |char_name, data|
    count = data['count']
    rarity = data['rarity'].downcase

    # Skip if the card doesn't match the specific rarity filter (if active)
    next if target_rarity && rarity != target_rarity

    # 6. Safety Logic: Determine how many cards to keep
    # 'over5' keeps 5 copies; all other filters keep 1 (the original)
    keep_amount = (filter == 'over5') ? 5 : 1

    # 7. Processing: If user has more than the keep_amount, sell the extras
    if count > keep_amount
      sell_amount = count - keep_amount
      
      # Calculate value using global SELL_PRICES hash
      coins_earned += (sell_amount * SELL_PRICES[rarity].to_i)
      sold_count += sell_amount

      # Update the database for this specific character
      DB.set_card_count(uid, char_name, keep_amount)
    end
  end

  # 8. Result Check: Exit if no duplicates were found to be sold
  if sold_count == 0
    return send_embed(event, 
      title: "♻️ Nothing to Sell", 
      description: "You don't have any cards that match that filter!"
    )
  end

  # 9. Database: Grant the total profit to the user's balance
  DB.add_coins(uid, coins_earned)

  # 10. UI: Send final success report via Embed
  send_embed(
    event,
    title: "♻️ Duplicates Sold!",
    description: "You successfully cleared out **#{sold_count}** duplicate cards! 🌸\n\n" \
                 "💰 **Earned:** #{coins_earned} #{EMOJIS['s_coin']}\n" \
                 "💳 **New Balance:** #{DB.get_coins(uid)} #{EMOJIS['s_coin']}"
  )
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!sell)
# ------------------------------------------
bot.command(:sell, 
  description: 'Mass sell duplicates based on filters', 
  category: 'Economy'
) do |event, filter, rarity_opt|
  execute_sell(event, filter, rarity_opt)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/sell)
# ------------------------------------------
bot.application_command(:sell) do |event|
  # Capture Slash options and pass to executor
  filter = event.options['filter']
  rarity_opt = event.options['rarity']
  execute_sell(event, filter, rarity_opt)
end