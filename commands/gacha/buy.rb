# ==========================================
# COMMAND: buy
# DESCRIPTION: Purchase tech upgrades, consumables, or direct characters from the shop.
# CATEGORY: Economy / Gacha
# ==========================================

# ------------------------------------------
# LOGIC: Shop Execution
# ------------------------------------------
def execute_buy(event, search_name)
  # 1. Validation: Ensure an item name was provided
  if search_name.nil? || search_name.strip.empty?
    return send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['error']} Missing Name" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Buy WHAT, chat?? You gotta tell me what you want." }
    ]}])
  end

  # 2. Initialization: Normalize search strings
  uid = event.user.id
  search_name = search_name.downcase.strip

  # 3. Branch: Event Exclusive Characters
  # Prevents users from bypassing the Event Hub during seasonal events.
  if is_event_character?(search_name)
    display_name = search_name.split.map(&:capitalize).join(' ') 
    return send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
      { type: 10, content: "## 🎪 Event Exclusive!" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Nice try, but **#{display_name}** is event-locked, bestie.\n\nYou can only snag them from the Event Hub using #{SPRING_CARNIVAL[:emoji]}." }
    ]}])
  end

  # 4. Branch: Black Market Items (Upgrades & Consumables)
  if BLACK_MARKET_ITEMS.key?(search_name)
    item_data = BLACK_MARKET_ITEMS[search_name]
    price = item_data[:price]

    # A. Funds Check
    if DB.get_coins(uid) < price
      return send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['nervous']} Broke Alert" },
        { type: 14, spacing: 1 },
        { type: 10, content: "The #{item_data[:name]} costs **#{price}** coins. You've got **#{DB.get_coins(uid)}**. That's not gonna work, chief." }
      ]}])
    end

    # B. Ownership Check: Prevent duplicate upgrades (Mic, Keyboard, etc.)
    inv_array = DB.get_inventory(uid)
    inv = inv_array.each_with_object({}) { |item, h| h[item['item_id']] = item['quantity'] }
    if item_data[:type] == 'upgrade' && inv[search_name] && inv[search_name] >= 1
      return send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['confused']} Already Owned" },
        { type: 14, spacing: 1 },
        { type: 10, content: "You already have the **#{item_data[:name]}** in your setup, galaxy brain. No dupes." }
      ]}])
    end

    # C. Transaction: Deduct coins and add to inventory
    DB.add_coins(uid, -price)
    DB.add_inventory(uid, search_name, 1)

    # D. Progression: Achievement Milestones
    if item_data[:type] == 'upgrade'
      check_achievement(event.channel, uid, 'buy_upgrade')
    elsif item_data[:type] == 'consumable'
      check_achievement(event.channel, uid, 'buy_consumable')
    end

    # E. Effect Logic: Immediate use of consumables
    if search_name == 'gamer fuel'
      DB.remove_inventory(uid, search_name, 1)
      ['stream', 'post', 'collab'].each { |cd| DB.set_cooldown(uid, cd, nil) }
      check_achievement(event.channel, uid, 'use_fuel')
      return send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
        { type: 10, content: "## 🥫 Gamer Fuel Consumed!" },
        { type: 14, spacing: 1 },
        { type: 10, content: "You cracked one open and CHUGGED it. Pog.\n**ALL your content cooldowns are reset!** Now get back to grinding, no excuses." }
      ]}])

    elsif search_name == 'stamina pill'
      DB.remove_inventory(uid, search_name, 1)
      DB.set_cooldown(uid, 'summon', nil)
      check_achievement(event.channel, uid, 'use_pill')
      return send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
        { type: 10, content: "## 💊 Stamina Pill Swallowed!" },
        { type: 14, spacing: 1 },
        { type: 10, content: "You popped that sus pill like a champ.\n**Your !summon cooldown is reset!** Back to the gacha mines, degenerate." }
      ]}])

    elsif search_name == 'rng manipulator'
      check_achievement(event.channel, uid, 'use_rng')
    end

    return send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
      { type: 10, content: "## 🛒 Sold!" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Cha-ching! You copped the **#{item_data[:name]}** for **#{price}** coins.\nIt's in your inventory now. Use it wisely~ or don't, I'm not your mom." }
    ]}])
  end

  # 5. Branch: Direct Character Purchase (Pity System)
  result = find_character_in_pools(search_name)
  unless result
    return send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Who??" },
      { type: 14, spacing: 1 },
      { type: 10, content: "I don't have anything called **#{search_name}** in stock. Check your spelling, chat." }
    ]}])
  end

  char_data = result[:char]
  rarity    = result[:rarity]
  price     = SHOP_PRICES[rarity]

  # A. Goddess characters cost Prisma, not coins
  if rarity == 'goddess'
    prisma_price = GODDESS_PRISMA_PRICE
    prisma_bal = DB.get_prisma(uid)

    if prisma_bal < prisma_price
      return send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['prisma']} Not Enough Prisma" },
        { type: 14, spacing: 1 },
        { type: 10, content: "**#{char_data[:name]}** is Goddess-tier and costs **#{prisma_price}** Prisma. You've got **#{prisma_bal}**.\n\nThat's pure copium, bestie. Farm more Prisma from premium rewards and events!" }
      ]}])
    end

    DB.add_prisma(uid, -prisma_price)
    name = char_data[:name]
    DB.add_character(uid, name, rarity.to_s, 1)
    new_count = DB.get_collection(uid)[name]['count']
    check_achievement(event.channel, uid, 'first_goddess_buy')

    return send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['prisma']} Goddess Acquired!" },
      { type: 14, spacing: 1 },
      { type: 10, content: "#{EMOJI_STRINGS['prisma']} WHALE ALERT!! You bought **#{name}** for **#{prisma_price}** Prisma!\nYou now own **#{new_count}** of them. Absolute baller move." },
      { type: 14, spacing: 1 },
      { type: 10, content: "**Prisma Left:** #{DB.get_prisma(uid)} Prisma" }
    ]}])
  end

  # B. Pricing Check: Some rarities may not be directly purchasable
  if price.nil?
    return send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Nah, Portal Only" },
      { type: 14, spacing: 1 },
      { type: 10, content: "**#{char_data[:name]}** isn't for sale. You want her? Hit the gacha portal like everyone else." }
    ]}])
  end

  # C. Funds Check
  if DB.get_coins(uid) < price
    return send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['nervous']} Broke Alert" },
      { type: 14, spacing: 1 },
      { type: 10, content: "A #{rarity.capitalize} character costs **#{price}** coins. You've got **#{DB.get_coins(uid)}**. L." }
    ]}])
  end

  # D. Transaction & UI Response
  DB.add_coins(uid, -price)
  name = char_data[:name]
  DB.add_character(uid, name, rarity.to_s, 1)
  new_count = DB.get_collection(uid)[name]['count']

  emoji = { 'goddess' => '💎', 'legendary' => '🌟', 'rare' => EMOJI_STRINGS['neonsparkle'] }.fetch(rarity, '⭐')

  send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
    { type: 10, content: "## #{EMOJI_STRINGS['s_coin']} Bag Secured!" },
    { type: 14, spacing: 1 },
    { type: 10, content: "#{emoji} You bought **#{name}** straight up for **#{price}** coins. No RNG needed.\nYou now own **#{new_count}** of them." },
    { type: 14, spacing: 1 },
    { type: 10, content: "**Wallet Damage:** #{DB.get_coins(uid)} coins left" }
  ]}])
end

# ------------------------------------------
# TRIGGERS: Prefix & Slash
# ------------------------------------------
$bot.command(:buy, description: 'Buy a character or tech upgrade', category: 'Economy') do |event, *name_args|
  execute_buy(event, name_args.join(' '))
  nil
end

$bot.application_command(:buy) do |event|
  execute_buy(event, event.options['item'])
end