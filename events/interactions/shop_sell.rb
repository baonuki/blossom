# ==========================================
# EVENT: Sell Gacha Duplicates
# DESCRIPTION: Scans a user's inventory, calculates the value
# of all copies beyond the 1st one, removes them, and grants coins.
# ==========================================

$bot.button(custom_id: /^shop_sell_(\d+)$/) do |event|
  uid = event.custom_id.match(/^shop_sell_(\d+)$/)[1].to_i
  
  if event.user.id != uid
    event.respond(content: "#{EMOJI_STRINGS['x_']} *Selling someone else's stuff? Bold. But no.*", ephemeral: true)
    next
  end

  user_collection = DB.get_collection(uid)
  total_earned = 0
  dupes_sold = 0
  sold_cards = {} # Track for premium undo

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
      sold_cards[name] = { count: sell_amount, rarity: rarity.downcase }

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
    embed.title = "#{EMOJI_STRINGS['rich']} Dupes Liquidated!"
    embed.description = "Flipped **#{dupes_sold}** dupes for **#{total_earned}** #{EMOJI_STRINGS['s_coin']}. Easy money.\n\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJI_STRINGS['s_coin']}."
    embed.color = 0x00FF00

    # Premium Undo: Store sell data for potential reversal
    if is_premium?(event.bot, uid)
      sell_id = "sellundo_#{uid}_#{Time.now.to_i}_#{rand(10000)}"
      expire_time = Time.now + SELL_UNDO_WINDOW

      ACTIVE_SELLS[sell_id] = {
        uid: uid,
        coins: total_earned,
        cards: sold_cards,
        expires: expire_time
      }

      embed.description += "\n\n#{EMOJI_STRINGS['neonsparkle']} **Premium Perk:** You have **5 minutes** to undo this sell! Expires <t:#{expire_time.to_i}:R>."

      view = Discordrb::Components::View.new do |v|
        v.row do |r|
          r.button(custom_id: sell_id, label: 'Undo Sell', style: :danger, emoji: EMOJI_OBJECTS['x_'])
          r.button(custom_id: "shop_home_#{uid}", label: 'Back to Shop', style: :secondary, emoji: '🔙')
        end
      end

      Thread.new do
        sleep SELL_UNDO_WINDOW
        ACTIVE_SELLS.delete(sell_id)
      end
    end
  else
    embed.title = "#{EMOJI_STRINGS['confused']} No Dupes Found"
    embed.description = "You've got nothing to sell. Zero extras. Go pull more gacha first."
    embed.color = 0xFF0000
  end

  # Display the receipt
  event.update_message(content: nil, embeds: [embed], components: view)
end