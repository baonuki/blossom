# ==========================================
# EVENT: Balance & Achievement UI
# DESCRIPTION: Listens for dropdown selections on the /balance 
# command and handles achievement pagination.
# ==========================================

$bot.select_menu(custom_id: /^bal_menu_/) do |event|
  owner_id = event.custom_id.split('_').last

  if event.user.id.to_s != owner_id
    event.respond(content: "🌸 *This isn't your menu! Run your own balance command to see your stats.*", ephemeral: true)
    next
  end

  uid = event.user.id
  username = event.user.display_name
  action = event.values.first 

  new_embed = Discordrb::Webhooks::Embed.new(color: 0xFFB6C1)
  view = balance_select_menu(uid, action) 

  case action
  when 'home'
    coins = DB.get_coins(uid)
    prisma = DB.get_prisma(uid)
    is_sub = is_premium?(event.bot, uid)
    daily_info = DB.get_daily_info(uid)

    cosmetics = DB.get_cosmetics(uid)

    # Title + Badge line
    badge_emoji = ""
    if cosmetics['badge'] && BADGES[cosmetics['badge']]
      badge_emoji = "#{BADGES[cosmetics['badge']][:emoji]} "
    end
    title_badge_line = ""
    if cosmetics['title'] && TITLES[cosmetics['title']]
      title_badge_line = "#{badge_emoji}*#{TITLES[cosmetics['title']][:name]}*\n"
    elsif !badge_emoji.empty?
      title_badge_line = "#{badge_emoji.strip}\n"
    end

    status_line = is_sub ? "#{EMOJI_STRINGS['prisma']} **Premium**\n" : ""
    header = "#{title_badge_line}#{status_line}"

    # Favorite card (premium feature only)
    fav_name = is_sub ? DB.get_favorite_card(uid) : nil
    fav_line = ""
    if fav_name
      fav_result = find_character_in_pools(fav_name)
      if fav_result
        fav_emoji = case fav_result[:rarity]
                    when 'goddess'   then EMOJI_STRINGS['goddess']
                    when 'legendary' then EMOJI_STRINGS['legendary']
                    when 'rare'      then EMOJI_STRINGS['rare']
                    else EMOJI_STRINGS['common']
                    end
        fav_line = "\n#{EMOJI_STRINGS['hearts']} **Favorite:** #{fav_emoji} #{fav_name}"
      end
    end

    new_embed.title = "🌸 #{username}'s Balance"
    new_embed.description = "#{header}**Coins:** #{coins} #{EMOJI_STRINGS['s_coin']}\n**Prisma:** #{prisma} #{EMOJI_STRINGS['prisma']}\n**Daily Streak:** #{daily_info['streak']} Days#{fav_line}\n\n*Use the dropdown below to view your items and VTubers!*#{mom_remark(uid, 'economy')}"

  when 'inv'
    inv = DB.get_inventory(uid)
    new_embed.title = "🎒 #{username}'s Inventory"

    if inv.empty?
      new_embed.description = "*Your inventory is completely empty!*"
    else
      upgrades = []
      consumables = []
      upgrade_keywords = ['headset', 'keyboard', 'mic', 'neon sign', 'gacha pass']

      inv.each do |row|
        item = row['item_id']
        count = row['quantity']
        # Use the custom emoji from BLACK_MARKET_ITEMS name if available
        display_name = BLACK_MARKET_ITEMS[item] ? BLACK_MARKET_ITEMS[item][:name] : item
        is_upgrade = upgrade_keywords.any? { |kw| item.downcase.include?(kw) }
        if is_upgrade
          upgrades << "#{display_name}: **#{count}**"
        else
          consumables << "#{display_name}: **x#{count}**"
        end
      end

      desc = ""
      desc += "🎙️ **Stream Upgrades (Permanent)**\n" + upgrades.join("\n") + "\n\n" unless upgrades.empty?
      desc += "#{EMOJI_STRINGS['stamina_pill']} **Consumables (Auto-Use)**\n" + consumables.join("\n") unless consumables.empty?
      new_embed.description = desc.strip
    end

  when 'vtubers'
    col = DB.get_collection(uid)
    new_embed.title = "#{EMOJI_STRINGS['neonsparkle']} #{username}'s VTuber Collection"

    if col.empty?
      new_embed.description = "*You haven't pulled any VTubers yet!*"
    else
      unique_vtubers = col.keys.size
      unique_ascended = 0
      rarity_counts = Hash.new(0)
      ascended_rarity_counts = Hash.new(0)

      col.each do |name, data|
        r = data['rarity']
        count = data['count']
        ascended = data['ascended']

        rarity_counts[r] += count
        if ascended > 0
          unique_ascended += 1
          ascended_rarity_counts[r] += ascended
        end
      end

      rarity_order = ['common', 'rare', 'legendary', 'goddess']
      sorted_rarity = rarity_counts.sort_by { |r, _| rarity_order.index(r.downcase) || 99 }
      sorted_ascended = ascended_rarity_counts.sort_by { |r, _| rarity_order.index(r.downcase) || 99 }

      rarity_emoji_map = { 'common' => EMOJI_STRINGS['common'], 'rare' => EMOJI_STRINGS['rare'], 'legendary' => EMOJI_STRINGS['legendary'], 'goddess' => EMOJI_STRINGS['goddess'] }

      desc = "#{EMOJI_STRINGS['neonsparkle']} **Unique VTubers:** #{unique_vtubers}\n#{EMOJI_STRINGS['neonsparkle']} **Unique Ascended:** #{unique_ascended}\n\n📊 **Total by Rarity:**\n"
      sorted_rarity.each { |r, c| desc += "#{rarity_emoji_map[r.downcase] || '•'} #{r.capitalize}: **#{c}**\n" }

      if sorted_ascended.any?
        desc += "\n🔥 **Ascended by Rarity:**\n"
        sorted_ascended.each { |r, c| desc += "#{rarity_emoji_map[r.downcase] || '•'} #{r.capitalize}: **#{c}**\n" }
      end
      new_embed.description = desc.strip
    end

  when 'achievements'
    new_embed, total_pages = generate_achievements_page(username, uid, 1)
    view = balance_select_menu(uid, action, 1, total_pages)
  end
  
  event.update_message(embeds: [new_embed], components: view)
end

# Handler for Achievement Pagination Buttons
$bot.button(custom_id: /^achpage_/) do |event|
  parts = event.custom_id.split('_')
  owner_id = parts[1]
  target_page = parts[2].to_i

  if event.user.id.to_s != owner_id
    event.respond(content: "🌸 *This isn't your menu!*", ephemeral: true)
    next
  end

  uid = event.user.id
  username = event.user.display_name

  new_embed, total_pages = generate_achievements_page(username, uid, target_page)
  view = balance_select_menu(uid, 'achievements', target_page, total_pages)

  event.update_message(embeds: [new_embed], components: view)
end