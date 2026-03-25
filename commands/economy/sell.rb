def execute_sell(event, filter, rarity_opt = nil)
  uid = event.user.id
  filter = filter&.downcase

  valid_filters = ['all', 'over5', 'rarity']
  unless valid_filters.include?(filter)
    return send_embed(event, title: "⚠️ Invalid Filter", description: "Please use a valid filter: `all`, `over5`, or `rarity <type>`.\nExample: `#{PREFIX}sell over5`")
  end

  if filter == 'rarity'
    valid_rarities = ['common', 'rare', 'legendary', 'goddess']
    unless valid_rarities.include?(rarity_opt&.downcase)
      return send_embed(event, title: "⚠️ Missing Rarity", description: "Please specify a rarity: `common`, `rare`, `legendary`, or `goddess`.\nExample: `#{PREFIX}sell rarity common`")
    end
    target_rarity = rarity_opt.downcase
  else
    target_rarity = nil
  end

  col = DB.get_collection(uid)
  coins_earned = 0
  sold_count = 0

  col.each do |char_name, data|
    count = data['count']
    rarity = data['rarity'].downcase

    next if target_rarity && rarity != target_rarity

    keep_amount = (filter == 'over5') ? 5 : 1

    if count > keep_amount
      sell_amount = count - keep_amount
      
      coins_earned += (sell_amount * SELL_PRICES[rarity].to_i)
      sold_count += sell_amount

      DB.set_card_count(uid, char_name, keep_amount)
    end
  end

  if sold_count == 0
    return send_embed(event, title: "♻️ Nothing to Sell", description: "You don't have any cards that match that filter!")
  end

  DB.add_coins(uid, coins_earned)

  send_embed(
    event,
    title: "♻️ Duplicates Sold!",
    description: "You successfully cleared out **#{sold_count}** duplicate cards! 🌸\n\n" \
                 "💰 **Earned:** #{coins_earned} #{EMOJIS['s_coin']}\n" \
                 "💳 **New Balance:** #{DB.get_coins(uid)} #{EMOJIS['s_coin']}"
  )
end

bot.command(:sell, description: 'Mass sell duplicates based on filters', category: 'Economy') do |event, filter, rarity_opt|
  execute_sell(event, filter, rarity_opt)
  nil
end

bot.application_command(:sell) do |event|
  filter = event.options['filter']
  rarity_opt = event.options['rarity']
  execute_sell(event, filter, rarity_opt)
end