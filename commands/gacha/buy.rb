def execute_buy(event, search_name)
  if search_name.nil? || search_name.strip.empty?
    return send_embed(event, title: "⚠️ Missing Name", description: "Who or what do you want to buy?")
  end

  uid = event.user.id
  search_name = search_name.downcase.strip

  if is_event_character?(search_name)
    display_name = search_name.split.map(&:capitalize).join(' ') 
    return send_embed(
      event, 
      title: "🎪 Event Exclusive!", 
      description: "**#{display_name}** is a limited-time event character!\n\nYou can only purchase them from the Event Hub using #{SPRING_CARNIVAL[:emoji]}."
    )
  end

  if BLACK_MARKET_ITEMS.key?(search_name)
    item_data = BLACK_MARKET_ITEMS[search_name]
    price = item_data[:price]

    if DB.get_coins(uid) < price
      return send_embed(event, title: "#{EMOJIS['nervous']} Insufficient Funds", description: "You need **#{price}** #{EMOJIS['s_coin']} to buy the #{item_data[:name]}.\nYou currently have **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}.")
    end

    inv = DB.get_inventory(uid)
    if item_data[:type] == 'upgrade' && inv[search_name] && inv[search_name] >= 1
      return send_embed(event, title: "#{EMOJIS['confused']} Already Owned", description: "You already have the **#{item_data[:name]}** equipped in your setup!")
    end

    DB.add_coins(uid, -price)
    DB.add_inventory(uid, search_name, 1)

  if item_data[:type] == 'upgrade'
    check_achievement(event.channel, uid, 'buy_upgrade')
  elsif item_data[:type] == 'consumable'
    check_achievement(event.channel, uid, 'buy_consumable')
  end

    check_achievement(event.channel, uid, 'use_fuel')
    check_achievement(event.channel, uid, 'use_pill')

    if search_name == 'gamer fuel'
      DB.remove_inventory(uid, search_name, 1)
      DB.set_cooldown(uid, 'stream', nil)
      DB.set_cooldown(uid, 'post', nil)
      DB.set_cooldown(uid, 'collab', nil)
      return send_embed(event, title: "🥫 Gamer Fuel Consumed!", description: "You cracked open a cold one and chugged it.\n**ALL your content creation cooldowns have been reset!** Get back to the grind.")
    elsif search_name == 'stamina pill'
      DB.remove_inventory(uid, search_name, 1)
      DB.set_cooldown(uid, 'summon', nil)
      return send_embed(event, title: "💊 Stamina Pill Swallowed!", description: "You took a highly questionable Stamina Pill...\n**Your !summon cooldown has been instantly reset!** Get back to gambling.")
    end

    return send_embed(event, title: "🛒 Item Purchased!", description: "You successfully bought the **#{item_data[:name]}** for **#{price}** #{EMOJIS['s_coin']}!\nIt has been added to your inventory/setup.")
  end

  result = find_character_in_pools(search_name)
  unless result
    return send_embed(event, title: "#{EMOJIS['error']} Shop Error", description: "I couldn't find a character or item named **#{search_name}**. Check your spelling!")
  end

  char_data = result[:char]
  rarity    = result[:rarity]
  price     = SHOP_PRICES[rarity]

  if price.nil?
    return send_embed(event, title: "#{EMOJIS['x_']} Black Market Locked", description: "You cannot directly purchase **#{char_data[:name]}**. She can only be obtained through the gacha portal.")
  end

  if DB.get_coins(uid) < price
    return send_embed(event, title: "#{EMOJIS['nervous']} Insufficient Funds", description: "You need **#{price}** #{EMOJIS['s_coin']} to buy a #{rarity.capitalize} character.\nYou currently have **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}.")
  end

  DB.add_coins(uid, -price)
  name = char_data[:name]
  gif_url = char_data[:gif]

  DB.add_character(uid, name, rarity.to_s, 1)
  new_count = DB.get_collection(uid)[name]['count']

  emoji = case rarity
          when 'goddess'   then '💎'
          when 'legendary' then '🌟'
          when 'rare'      then '✨'
          else '⭐'
          end

  send_embed(event, title: "#{EMOJIS['coins']} Purchase Successful!", description: "#{emoji} You directly purchased **#{name}** for **#{price}** #{EMOJIS['s_coin']}!\nYou now own **#{new_count}** of them.", fields: [{ name: 'Remaining Balance', value: "#{DB.get_coins(uid)} #{EMOJIS['s_coin']}", inline: true }], image: gif_url)
end

bot.command(:buy, description: 'Buy a character or tech upgrade (Usage: !buy <Name>)', min_args: 1, category: 'Gacha') do |event, *name_args|
  execute_buy(event, name_args.join(' '))
  nil
end

bot.application_command(:buy) do |event|
  execute_buy(event, event.options['item'])
end