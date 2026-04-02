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
    components = [
      {
        type: 17,
        accent_color: 0xFF0000,
        components: [
          { type: 10, content: "## #{EMOJI_STRINGS['error']} Invalid Filter" },
          { type: 14, spacing: 1 },
          { type: 10, content: "That's not a filter, chat. Use `all`, `over5`, or `rarity <type>`.\nExample: `#{PREFIX}sell over5`" }
        ]
      }
    ]
    return send_cv2(event, components)
  end

  # 3. Validation: If using the 'rarity' filter, ensure a valid rarity was provided
  if filter == 'rarity'
    valid_rarities = ['common', 'rare', 'legendary', 'goddess']
    unless valid_rarities.include?(rarity_opt&.downcase)
      components = [
        {
          type: 17,
          accent_color: 0xFF0000,
          components: [
            { type: 10, content: "## #{EMOJI_STRINGS['error']} Missing Rarity" },
            { type: 14, spacing: 1 },
            { type: 10, content: "Pick a rarity, bestie: `common`, `rare`, `legendary`, or `goddess`.\nExample: `#{PREFIX}sell rarity common`" }
          ]
        }
      ]
      return send_cv2(event, components)
    end
    target_rarity = rarity_opt.downcase
  else
    target_rarity = nil
  end

  # 4. Data Retrieval: Fetch the user's full character collection
  col = DB.get_collection(uid)
  coins_earned = 0
  sold_count = 0
  sold_cards = {} # Track what was sold for premium undo

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

      # Track for undo
      sold_cards[char_name] = { count: sell_amount, rarity: rarity }

      # Update the database for this specific character
      DB.set_card_count(uid, char_name, keep_amount)
    end
  end

  # 8. Result Check: Exit if no duplicates were found to be sold
  if sold_count == 0
    components = [
      {
        type: 17,
        accent_color: 0xFF0000,
        components: [
          { type: 10, content: "## ♻️ Nothing to Sell" },
          { type: 14, spacing: 1 },
          { type: 10, content: "Nothing to sell here. Your collection is already clean, nerd." }
        ]
      }
    ]
    return send_cv2(event, components)
  end

  # 9. Database: Grant the total profit to the user's balance
  DB.add_coins(uid, coins_earned)

  # 10. Achievements
  check_achievement(event.channel, uid, 'first_sell')
  check_wealth_achievements(event.channel, uid)

  # 11. Premium Undo: Store sell data for potential reversal
  premium = is_premium?(event.bot, uid)
  undo_line = ""

  if premium
    sell_id = "sellundo_#{uid}_#{Time.now.to_i}_#{rand(10000)}"
    expire_time = Time.now + SELL_UNDO_WINDOW

    ACTIVE_SELLS[sell_id] = {
      uid: uid,
      coins: coins_earned,
      cards: sold_cards,
      expires: expire_time
    }

    undo_line = "\n\n#{EMOJI_STRINGS['neonsparkle']} **Premium Perk:** You have **5 minutes** to undo this sell! Expires <t:#{expire_time.to_i}:R>."

    # Background cleanup thread
    Thread.new do
      sleep SELL_UNDO_WINDOW
      ACTIVE_SELLS.delete(sell_id)
    end
  end

  # 12. UI: Send final success report via CV2
  inner = [
    { type: 10, content: "## ♻️ Duplicates Sold!" },
    { type: 14, spacing: 1 },
    { type: 10, content: "Dumped **#{sold_count}** dupes. Declutter arc activated.\n\n" \
                         "💰 **Earned:** #{coins_earned} #{EMOJI_STRINGS['s_coin']}\n" \
                         "💳 **Balance:** #{DB.get_coins(uid)} #{EMOJI_STRINGS['s_coin']}#{undo_line}#{mom_remark(uid, 'economy')}" }
  ]

  if premium
    inner << { type: 14, spacing: 1 }
    inner << { type: 1, components: [
      { type: 2, custom_id: sell_id, label: 'Undo Sell', style: 4, emoji: EMOJI_OBJECTS['x_'] }
    ]}
  end

  components = [{ type: 17, accent_color: 0x00FF00, components: inner }]
  send_cv2(event, components)
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!sell)
# ------------------------------------------
$bot.command(:sell, aliases: [:selldupes],
  description: 'Mass sell duplicates based on filters', 
  category: 'Economy'
) do |event, filter, rarity_opt|
  execute_sell(event, filter, rarity_opt)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/sell)
# ------------------------------------------
$bot.application_command(:sell) do |event|
  # Capture Slash options and pass to executor
  filter = event.options['filter']
  rarity_opt = event.options['rarity']
  execute_sell(event, filter, rarity_opt)
end