# ==========================================
# COMMAND: buy
# DESCRIPTION: Purchase tech upgrades, consumables, or direct characters from the shop.
# CATEGORY: Economy / Gacha
# ==========================================

# ------------------------------------------
# LOGIC: Shop Execution
# ------------------------------------------
def execute_buy(event, search_name, qty_override = nil)
  # 1. Validation: Ensure an item name was provided
  if search_name.nil? || search_name.strip.empty?
    return send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['error']} Missing Name" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Buy WHAT, chat?? You gotta tell me what you want." }
    ]}])
  end

  # 2. Initialization: Normalize search strings and parse quantity
  uid = event.user.id
  search_name = search_name.downcase.strip

  # Parse quantity from prefix args: "5 gamer fuel" or "gamer fuel 5"
  words = search_name.split
  if qty_override
    qty = qty_override.to_i
  elsif words.last =~ /^\d+$/
    qty = words.pop.to_i
    search_name = words.join(' ')
  elsif words.first =~ /^\d+$/
    qty = words.shift.to_i
    search_name = words.join(' ')
  else
    qty = 1
  end
  qty = 1 if qty < 1

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

    # A. Upgrades can only be bought once, force qty to 1
    if item_data[:type] == 'upgrade'
      qty = 1
      inv_array = DB.get_inventory(uid)
      inv = inv_array.each_with_object({}) { |item, h| h[item['item_id']] = item['quantity'] }
      if inv[search_name] && inv[search_name] >= 1
        return send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
          { type: 10, content: "## #{EMOJI_STRINGS['confused']} Already Owned" },
          { type: 14, spacing: 1 },
          { type: 10, content: "You already have the **#{item_data[:name]}** in your setup, galaxy brain. No dupes." }
        ]}])
      end
    end

    # B. Funds Check (price * quantity)
    total_price = item_data[:price] * qty
    if DB.get_coins(uid) < total_price
      return send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['nervous']} Broke Alert" },
        { type: 14, spacing: 1 },
        { type: 10, content: "#{qty}x #{item_data[:name]} costs **#{total_price}** coins. You've got **#{DB.get_coins(uid)}**. That's not gonna work, chief." }
      ]}])
    end

    # C. Transaction: Deduct coins and add to inventory
    DB.add_coins(uid, -total_price)
    DB.add_inventory(uid, search_name, qty)

    # D. Progression: Achievement Milestones
    if item_data[:type] == 'upgrade'
      check_achievement(event.channel, uid, 'buy_upgrade')
    elsif item_data[:type] == 'consumable'
      check_achievement(event.channel, uid, 'buy_consumable')
    end

    # E. Response
    qty_text = qty > 1 ? "**#{qty}x** " : ""
    return send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
      { type: 10, content: "## 🛒 Sold!" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Cha-ching! You copped #{qty_text}**#{item_data[:name]}** for **#{total_price}** coins.\nStashed in your inventory. They'll kick in automatically when you need 'em.#{mom_remark(uid, 'economy')}" }
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

    blossom_remark = name == 'Blossom' ? "\n\n*You just BOUGHT me?? With Prisma?? I mean... I'm flattered you think I'm worth it. Because I absolutely am. But this is weird, chat.*" : ""
    blossom_remark = "\n\n*You bought my mom's past life with Prisma. She's not a product, she's a PERSON. ...Okay fine she's a card. But STILL.*" if name == 'Envvy'
    blossom_remark = "\n\n*You bought baonuki?? That's my mama's CURRENT VTuber persona. Respect the drip and protect that card at all costs.*" if name.downcase == 'baonuki'

    return send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['prisma']} Goddess Acquired!" },
      { type: 14, spacing: 1 },
      { type: 10, content: "#{EMOJI_STRINGS['prisma']} WHALE ALERT!! You bought **#{name}** for **#{prisma_price}** Prisma!\nYou now own **#{new_count}** of them. Absolute baller move.#{blossom_remark}" },
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

  emoji = { 'goddess' => EMOJI_STRINGS['goddess'], 'legendary' => EMOJI_STRINGS['legendary'], 'rare' => EMOJI_STRINGS['rare'] }.fetch(rarity, EMOJI_STRINGS['common'])

  buy_remark = name == 'Blossom' ? "\n\n*You just bought a card of ME from the shop like I'm merch. I mean... I AM merch, technically. But still. Treat that card right.*" : ""
  buy_remark = "\n\n*You just bought my mom's past life card. Yeah, that's a certified collector move right there.*" if name == 'baonuki'
  buy_remark = "\n\n*You bought baonuki?! That's my mama's current form, so yeah, that's a premium pull even from the shop.*" if name.downcase == 'baonuki'

  send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
    { type: 10, content: "## #{EMOJI_STRINGS['s_coin']} Bag Secured!" },
    { type: 14, spacing: 1 },
    { type: 10, content: "#{emoji} You bought **#{name}** straight up for **#{price}** coins. No RNG needed.\nYou now own **#{new_count}** of them.#{buy_remark}" },
    { type: 14, spacing: 1 },
    { type: 10, content: "**Wallet Damage:** #{DB.get_coins(uid)} coins left#{mom_remark(uid, 'gacha')}" }
  ]}])
end

# ------------------------------------------
# TRIGGERS: Prefix & Slash
# ------------------------------------------
$bot.command(:buy, aliases: [:purchase], description: 'Buy a character or tech upgrade', category: 'Economy') do |event, *name_args|
  execute_buy(event, name_args.join(' '))
  nil
end

$bot.application_command(:buy) do |event|
  execute_buy(event, event.options['item'], event.options['quantity'])
end

# ------------------------------------------
# AUTOCOMPLETE: Item & Character Suggestions
# ------------------------------------------
$bot.autocomplete(:item, command_name: :buy) do |event|
  begin
    query = (event.options['item'] || '').to_s.strip.downcase

    # Build list of all buyable items: shop items + characters
    all_items = []

    # Shop upgrades & consumables — strip custom emoji markdown from display names
    BLACK_MARKET_ITEMS.each do |key, data|
      clean_name = data[:name].gsub(/<a?:\w+:\d+>/, '').strip
      all_items << { display: "#{clean_name} (#{data[:price]} coins)", value: key }
    end

    # All characters from the universal pool
    UNIVERSAL_POOL[:characters].each do |rarity, char_list|
      price = SHOP_PRICES[rarity.to_s]
      char_list.each do |c|
        label = price ? "#{c[:name]} — #{rarity.capitalize} (#{price} coins)" : "#{c[:name]} — #{rarity.capitalize}"
        all_items << { display: label, value: c[:name] }
      end
    end

    # Filter
    matches = if query.empty?
                all_items.first(25)
              else
                all_items.select { |i| i[:display].downcase.include?(query) || i[:value].downcase.include?(query) }.first(25)
              end

    event.respond(choices: matches.map { |i| { name: i[:display][0..99], value: i[:value] } })
  rescue => e
    puts "[AUTOCOMPLETE ERROR - buy] #{e.message}"
    event.respond(choices: [])
  end
end