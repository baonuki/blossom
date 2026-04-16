# ==========================================
# COMMAND: craft / salvage
# DESCRIPTION: Salvage cards for materials, craft exclusive cosmetics.
# CATEGORY: Gacha
# ==========================================

def execute_craft(event, recipe_id = nil)
  uid = event.user.id

  if recipe_id.nil?
    # Show crafting menu
    mats = DB.get_materials(uid)
    scrap = mats['scrap'] || 0
    essence = mats['essence'] || 0

    recipe_list = CRAFTING_RECIPES.map { |id, r|
      mat_text = r[:materials].map { |m, a| "#{a} #{CRAFTING_MATERIALS[m][:emoji]}" }.join(' + ')
      "**#{r[:name]}** \u2014 #{mat_text} + #{r[:cost]} #{EMOJI_STRINGS['s_coin']}\n  *#{r[:desc]}*"
    }.join("\n")

    return send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
      { type: 10, content: "## \u{2699}\u{FE0F} Crafting Workshop" },
      { type: 14, spacing: 1 },
      { type: 10, content: "**Your Materials:**\n\u{2699}\u{FE0F} Scrap: **#{scrap}** | \u{1F48E} Essence: **#{essence}**\n\n**Recipes:**\n#{recipe_list}\n\nUse `#{PREFIX}craft <name>` to craft an item.\nUse `#{PREFIX}salvage <amount> [rarity]` to break down cards.#{mom_remark(uid, 'general')}" }
    ]}])
  end

  recipe = CRAFTING_RECIPES[recipe_id.downcase]
  unless recipe
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Unknown Recipe" },
      { type: 14, spacing: 1 },
      { type: 10, content: "That recipe doesn't exist. Use `#{PREFIX}craft` to see all recipes." }
    ]}])
  end

  # Check materials
  unless DB.has_materials?(uid, recipe[:materials])
    mats = DB.get_materials(uid)
    needed = recipe[:materials].map { |m, a| "#{a} #{CRAFTING_MATERIALS[m][:name]} (have #{mats[m] || 0})" }.join(', ')
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Not Enough Materials" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Need: #{needed}" }
    ]}])
  end

  # Check coins
  coins = DB.get_coins(uid)
  if coins < recipe[:cost]
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Not Enough Coins" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Crafting costs **#{recipe[:cost]}** #{EMOJI_STRINGS['s_coin']}. You have **#{coins}**." }
    ]}])
  end

  # Deduct and craft
  recipe[:materials].each { |mat, amt| DB.remove_material(uid, mat, amt) }
  DB.add_coins(uid, -recipe[:cost])

  # Grant the cosmetic based on type
  case recipe[:type]
  when 'badge'
    DB.unlock_badge(uid, recipe[:result_id])
  when 'title'
    # Title is unlocked by being in TITLES — just set it
    DB.set_title(uid, recipe[:result_id])
  when 'theme'
    DB.set_collection_theme(uid, recipe[:result_id])
  when 'pet'
    DB.set_pet(uid, recipe[:result_id])
  end

  send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: [
    { type: 10, content: "## \u{2699}\u{FE0F} Crafted: #{recipe[:name]}!" },
    { type: 14, spacing: 1 },
    { type: 10, content: "Successfully crafted **#{recipe[:name]}**!\n\n*#{recipe[:desc]}*\n\nIt's been equipped automatically. Use `/profile` to manage your cosmetics.#{mom_remark(uid, 'general')}" }
  ]}])
end

def execute_salvage(event, amount_str = nil, rarity_filter = nil)
  uid = event.user.id
  amount = (amount_str || '1').to_i
  rarity_filter = rarity_filter&.downcase

  if amount < 1
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Invalid Amount" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Salvage at least 1 card. Usage: `#{PREFIX}salvage <amount> [rarity]`" }
    ]}])
  end

  # Default to common if no rarity specified
  rarity_filter ||= 'common'
  unless SALVAGE_RATES.key?(rarity_filter)
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Invalid Rarity" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Valid rarities: `common`, `rare`, `legendary`, `goddess`" }
    ]}])
  end

  # Find cards of that rarity with duplicates (count > 1)
  collection = DB.get_collection(uid)
  salvageable = collection.select { |_name, data| data['rarity'] == rarity_filter && data['count'] > 1 }

  if salvageable.empty?
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} No Duplicates" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You don't have any #{rarity_filter} duplicates to salvage. (Keeps 1 of each card.)" }
    ]}])
  end

  # Salvage up to the requested amount from duplicates
  total_salvaged = 0
  salvageable.each do |name, data|
    break if total_salvaged >= amount
    available = data['count'] - 1 # Keep at least 1
    to_salvage = [available, amount - total_salvaged].min
    DB.remove_character(uid, name, to_salvage)
    total_salvaged += to_salvage
  end

  # Grant materials
  rates = SALVAGE_RATES[rarity_filter]
  gained = {}
  rates.each do |mat, per_card|
    total = per_card * total_salvaged
    DB.add_material(uid, mat, total)
    gained[mat] = total
  end

  gained_text = gained.map { |mat, amt| "+#{amt} #{CRAFTING_MATERIALS[mat][:emoji]} #{CRAFTING_MATERIALS[mat][:name]}" }.join(', ')
  track_challenge(uid, 'cards_salvaged', total_salvaged)

  send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: [
    { type: 10, content: "## \u{2699}\u{FE0F} Salvaged #{total_salvaged} #{rarity_filter.capitalize} Cards" },
    { type: 14, spacing: 1 },
    { type: 10, content: "**Materials gained:** #{gained_text}\n\nUse `#{PREFIX}craft` to see what you can build!#{mom_remark(uid, 'general')}" }
  ]}])
end

# ------------------------------------------
# TRIGGERS
# ------------------------------------------
$bot.command(:craft,
  description: 'Craft exclusive cosmetics from materials',
  category: 'Gacha'
) do |event, recipe_id|
  execute_craft(event, recipe_id)
  nil
end

$bot.command(:salvage,
  description: 'Break down duplicate cards into crafting materials',
  category: 'Gacha'
) do |event, amount, rarity|
  execute_salvage(event, amount, rarity)
  nil
end

$bot.application_command(:craft) do |event|
  execute_craft(event, event.options['recipe'])
end

$bot.application_command(:salvage) do |event|
  execute_salvage(event, event.options['amount'], event.options['rarity'])
end
