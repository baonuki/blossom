# ==========================================
# EVENT: Sell Gacha Duplicates
# DESCRIPTION: Scans a user's inventory, calculates the value
# of all copies beyond the 1st one, removes them, and grants coins.
# ==========================================

bot.button(custom_id: /^shop_sell_(\d+)$/) do |event|
  uid = event.custom_id.match(/^shop_sell_(\d+)$/)[1].to_i
  
  if event.user.id != uid
    event.respond(content: "❌ *You cannot sell someone else's characters!*", ephemeral: true)
    next
  end

  user_collection = DB.get_collection(uid)
  total_earned = 0
  dupes_sold = 0

  # Loop through every character they own
  user_collection.each do |name, data|
    if data['count'] > 1
      # We only sell the EXTRAS, they always keep 1 copy!
      sell_amount = data['count'] - 1
      rarity = data['rarity']
      
      # Multiply the amount of dupes by the base sell price of that rarity
      coins_earned = sell_amount * SELL_PRICES[rarity]
      
      total_earned += coins_earned
      dupes_sold += sell_amount
      
      # Remove the extra copies from the database
      DB.remove_character(uid, name, sell_amount)
    end
  end

  # Build the receipt embed
  embed = Discordrb::Webhooks::Embed.new
  view = Discordrb::Components::View.new do |v|
    # Always offer a quick way back to the main shop!
    v.row { |r| r.button(custom_id: "shop_home_#{uid}", label: 'Back to Shop', style: :secondary, emoji: '🔙') }
  end

  if dupes_sold > 0
    # Add the lump sum to their wallet
    DB.add_coins(uid, total_earned)
    embed.title = "#{EMOJIS['rich']} Duplicates Sold!"
    embed.description = "You converted **#{dupes_sold}** duplicate characters into **#{total_earned}** #{EMOJIS['s_coin']}!\n\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}."
    embed.color = 0x00FF00
  else
    embed.title = "#{EMOJIS['confused']} No Duplicates"
    embed.description = "You don't have any duplicate characters to sell right now! You currently have 1 or 0 copies of everyone."
    embed.color = 0xFF0000 
  end

  # Display the receipt
  event.update_message(content: nil, embeds: [embed], components: view)
end