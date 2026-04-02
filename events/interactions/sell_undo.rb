# ==========================================
# EVENT: Sell Undo (Premium)
# DESCRIPTION: Handles the "Undo Sell" button for premium users.
# Restores sold cards and removes the coins earned.
# ==========================================

$bot.button(custom_id: /^sellundo_/) do |event|
  sell_id = event.custom_id

  # Check if the undo is still active
  unless ACTIVE_SELLS.key?(sell_id)
    event.respond(content: "#{EMOJI_STRINGS['error']} *Too late! That undo window already closed. No take-backsies.*", ephemeral: true)
    next
  end

  sell_data = ACTIVE_SELLS[sell_id]

  # Only the seller can undo their own sell
  if event.user.id != sell_data[:uid]
    event.respond(content: "#{EMOJI_STRINGS['x_']} *That's not YOUR undo button, back off.*", ephemeral: true)
    next
  end

  # Remove from active sells immediately to prevent double-click
  ACTIVE_SELLS.delete(sell_id)

  uid = sell_data[:uid]
  coins = sell_data[:coins]
  cards = sell_data[:cards]

  # Check if the user still has enough coins to reverse the sale
  current_coins = DB.get_coins(uid)
  if current_coins < coins
    event.respond(content: "#{EMOJI_STRINGS['error']} *You already spent the coins from that sell! Can't undo what you've blown through, big spender.*", ephemeral: true)
    next
  end

  # Reverse the sell: remove coins and restore cards
  DB.add_coins(uid, -coins)
  cards.each do |char_name, data|
    DB.add_character(uid, char_name, data[:rarity], data[:count])
  end

  restored_count = cards.values.sum { |d| d[:count] }

  # Update the message to show the undo was successful
  components = [{
    type: 17,
    accent_color: NEON_COLORS.sample,
    components: [
      { type: 10, content: "## #{EMOJI_STRINGS['surprise']} Sell Undone!" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Restored **#{restored_count}** cards back to your collection. " \
                           "**#{coins}** #{EMOJI_STRINGS['s_coin']} has been deducted.\n\n" \
                           "💳 **Balance:** #{DB.get_coins(uid)} #{EMOJI_STRINGS['s_coin']}\n\n" \
                           "*Seller's remorse? In THIS economy? Respect.*" }
    ]
  }]

  # Handle both CV2 (command sell) and embed (shop sell) contexts
  if event.message.embeds.any?
    # Shop sell context — update with embed
    embed = Discordrb::Webhooks::Embed.new(
      title: "#{EMOJI_STRINGS['surprise']} Sell Undone!",
      description: "Restored **#{restored_count}** cards back to your collection. " \
                   "**#{coins}** #{EMOJI_STRINGS['s_coin']} has been deducted.\n\n" \
                   "New Balance: **#{DB.get_coins(uid)}** #{EMOJI_STRINGS['s_coin']}.\n\n" \
                   "*Seller's remorse? In THIS economy? Respect.*",
      color: NEON_COLORS.sample
    )
    view = Discordrb::Components::View.new do |v|
      v.row { |r| r.button(custom_id: "shop_home_#{uid}", label: 'Back to Shop', style: :secondary, emoji: '🔙') }
    end
    event.update_message(content: nil, embeds: [embed], components: view)
  else
    # Command sell context — update with CV2
    event.update_message(content: nil, embeds: [], components: components)
  end
end
