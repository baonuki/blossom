# ==========================================
# EVENT: Spring Carnival Interactive Hub
# DESCRIPTION: Houses all the button and dropdown listeners
# for the seasonal Carnival minigames, shops, and navigation.
# ==========================================

# 1. Main Hub Entrance
bot.select_menu(custom_id: /^event_hub_/) do |event|
  owner_id = event.custom_id.split('_').last
  next event.respond(content: "🌸 *Run your own `#{PREFIX}event` command!*", ephemeral: true) if event.user.id.to_s != owner_id

  selection = event.values.first

  if selection == "spring_carnival"
    if Time.now.month != SPRING_CARNIVAL[:month]
      next event.update_message(content: "❌ The **Spring Carnival** is currently closed! It will return in April.", embeds: [], components: [])
    end

    uid = event.user.id
    tickets = DB.get_tickets(uid)

    embed = Discordrb::Webhooks::Embed.new(
      title: "🎪 Welcome to the Spring Carnival!",
      description: "Step right up! Play minigames to earn **#{SPRING_CARNIVAL[:currency]}** and spend them in the event shops.\n\n🎟️ **Your Balance:** #{tickets} #{SPRING_CARNIVAL[:emoji]}\n\n*Use the buttons below to explore the carnival grounds!*",
      color: 0xFF69B4,
      image: Discordrb::Webhooks::EmbedImage.new(url: "https://media.discordapp.net/attachments/1475890017443516476/1485732167983173713/CityView_ThemePark_01.jpg")
    )

    view = Discordrb::Components::View.new do |v|
      v.row do |r|
        r.button(custom_id: "carnival_shop_#{owner_id}", label: "Item Shop", style: :primary, emoji: "🍿")
        r.button(custom_id: "carnival_chars_#{owner_id}", label: "Character Shop", style: :success, emoji: "🌟")
      end
      v.row do |r|
        r.button(custom_id: "carnival_ringtoss_#{owner_id}", label: "Play: Ring Toss", style: :secondary, emoji: "⭕")
        r.button(custom_id: "carnival_game2_#{owner_id}", label: "Play: Balloon Pop", style: :secondary, emoji: "🎈")
      end
    end

    event.update_message(embeds: [embed], components: view)
  end
end

# 2. Minigame: Ring Toss
bot.button(custom_id: /^carnival_ringtoss_/) do |event|
  owner_id = event.custom_id.split('_').last
  next event.respond(content: "🌸 *Not your menu!*", ephemeral: true) if event.user.id.to_s != owner_id

  uid = event.user.id
  cost = 100

  if DB.get_coins(uid) < cost
    next event.update_message(content: "💸 You need **#{cost}** #{EMOJIS['s_coin']} to play Ring Toss!", embeds: [], components: carnival_back_view(owner_id))
  end

  DB.add_coins(uid, -cost)
  check_achievement(event.channel, event.user.id, 'carnival_ring')
  embed = Discordrb::Webhooks::Embed.new(color: 0xFF69B4)
  
  if rand(100) < 40 
    winnings = rand(15..50)
    DB.add_tickets(uid, winnings)
    embed.title = "⭕ Ring Toss Winner!"
    embed.description = "You toss the ring... and it lands perfectly on a bottle!\n\nYou won **#{winnings}** #{SPRING_CARNIVAL[:emoji]}!\n*Balance: #{DB.get_tickets(uid)} #{SPRING_CARNIVAL[:emoji]}*"
  else
    embed.title = "⭕ Ring Toss Miss"
    embed.description = "You toss the ring... and it bounces right off the bottle.\n\nBetter luck next time! (-#{cost} #{EMOJIS['s_coin']})\n*Balance: #{DB.get_tickets(uid)} #{SPRING_CARNIVAL[:emoji]}*"
  end

  view = Discordrb::Components::View.new do |v|
    v.row do |r|
      r.button(custom_id: "carnival_ringtoss_#{owner_id}", label: "Play Again (100 Coins)", style: :success, emoji: "⭕")
      r.button(custom_id: "carnival_hub_#{owner_id}", label: 'Back to Carnival', style: :secondary, emoji: '🎪')
    end
  end

  event.update_message(content: nil, embeds: [embed], components: view)
end

# 3. Minigame: Balloon Pop
bot.button(custom_id: /^carnival_game2_/) do |event|
  owner_id = event.custom_id.split('_').last
  next event.respond(content: "🌸 *Not your menu!*", ephemeral: true) if event.user.id.to_s != owner_id

  uid = event.user.id
  cost = 150

  if DB.get_coins(uid) < cost
    next event.update_message(content: "💸 You need **#{cost}** #{EMOJIS['s_coin']} to play Balloon Pop!", embeds: [], components: carnival_back_view(owner_id))
  end

  DB.add_coins(uid, -cost)
  check_achievement(event.channel, event.user.id, 'carnival_pop')
  embed = Discordrb::Webhooks::Embed.new(color: 0xFF69B4)
  
  pops = [rand(100) < 50, rand(100) < 50, rand(100) < 50] 
  successes = pops.count(true)

  if successes > 0
    winnings = successes * rand(10..30)
    DB.add_tickets(uid, winnings)
    embed.title = "🎈 Balloon Pop!"
    embed.description = "You throw your darts and pop **#{successes}** balloons!\n\nYou won **#{winnings}** #{SPRING_CARNIVAL[:emoji]}!\n*Balance: #{DB.get_tickets(uid)} #{SPRING_CARNIVAL[:emoji]}*"
  else
    embed.title = "🎈 Balloon Pop Miss"
    embed.description = "You throw your darts... and miss every single balloon. The carnie laughs at you.\n\nBetter luck next time! (-#{cost} #{EMOJIS['s_coin']})\n*Balance: #{DB.get_tickets(uid)} #{SPRING_CARNIVAL[:emoji]}*"
  end

  view = Discordrb::Components::View.new do |v|
    v.row do |r|
      r.button(custom_id: "carnival_game2_#{owner_id}", label: "Play Again (150 Coins)", style: :success, emoji: "🎈")
      r.button(custom_id: "carnival_hub_#{owner_id}", label: 'Back to Carnival', style: :secondary, emoji: '🎪')
    end
  end

  event.update_message(content: nil, embeds: [embed], components: view)
end

# 4. Item & Character Shops
bot.button(custom_id: /^carnival_shop_/) do |event|
  owner_id = event.custom_id.split('_').last
  next event.respond(content: "🌸 *Not your menu!*", ephemeral: true) if event.user.id.to_s != owner_id

  uid = event.user.id
  tickets = DB.get_tickets(uid)

  embed = Discordrb::Webhooks::Embed.new(
    title: "🍿 Carnival Item Shop",
    description: "Spend your tickets on sweet treats! Use the buttons below to buy.\n\n🎟️ **Your Balance:** #{tickets} #{SPRING_CARNIVAL[:emoji]}\n\n",
    color: 0xFF69B4
  )

  view = Discordrb::Components::View.new do |v|
    v.row do |r|
      SPRING_CARNIVAL[:items].each do |name, data|
        embed.description += "**#{name}** — #{data[:price]} #{SPRING_CARNIVAL[:emoji]}\n> *#{data[:desc]}*\n\n"
        safe_name = name.gsub(' ', '')
        r.button(custom_id: "carnbuy_item_#{safe_name}_#{owner_id}", label: "Buy #{name}", style: :success)
      end
    end
    v.row { |r| r.button(custom_id: "carnival_hub_#{owner_id}", label: 'Back to Carnival Hub', style: :secondary, emoji: '🎪') }
  end

  event.update_message(content: nil, embeds: [embed], components: view)
end

bot.button(custom_id: /^carnival_chars_/) do |event|
  owner_id = event.custom_id.split('_').last
  next event.respond(content: "🌸 *Not your menu!*", ephemeral: true) if event.user.id.to_s != owner_id

  uid = event.user.id
  tickets = DB.get_tickets(uid)

  embed = Discordrb::Webhooks::Embed.new(
    title: "🌟 Carnival Character Shop",
    description: "Guarantee a limited-time VTuber by spending your tickets!\n\n🎟️ **Your Balance:** #{tickets} #{SPRING_CARNIVAL[:emoji]}\n\n",
    color: 0xFF69B4
  )

  view = Discordrb::Components::View.new do |v|
    v.row do |r|
      r.select_menu(custom_id: "carnbuy_char_#{owner_id}", placeholder: "Select a character to buy...", max_values: 1) do |s|
        SPRING_CARNIVAL[:characters].each do |rarity, chars|
          chars.each do |char|
            embed.description += "**#{char[:name]}** (#{rarity.capitalize}) — #{char[:price]} #{SPRING_CARNIVAL[:emoji]}\n"
            s.option(label: char[:name], value: char[:name], description: "#{char[:price]} Tickets (#{rarity.capitalize})", emoji: "🌟")
          end
        end
      end
    end
    v.row { |r| r.button(custom_id: "carnival_hub_#{owner_id}", label: 'Back to Carnival Hub', style: :secondary, emoji: '🎪') }
  end

  event.update_message(content: nil, embeds: [embed], components: view)
end

# 5. Purchasing Routers
bot.button(custom_id: /^carnbuy_item_/) do |event|
  parts = event.custom_id.split('_')
  owner_id = parts.last
  next event.respond(content: "🌸 *Not your menu!*", ephemeral: true) if event.user.id.to_s != owner_id

  safe_name = parts[2]
  uid = event.user.id
  
  real_name, data = SPRING_CARNIVAL[:items].find { |k, v| k.gsub(' ', '') == safe_name }

  if DB.get_tickets(uid) < data[:price]
    next event.respond(content: "🎟️ You need **#{data[:price]}** #{SPRING_CARNIVAL[:emoji]} to buy **#{real_name}**!", ephemeral: true)
  end

  DB.add_tickets(uid, -data[:price])
  DB.add_inventory(uid, real_name, 1)
  check_achievement(event.channel, event.user.id, 'carnival_snack')

  event.respond(content: "✅ You bought **1x #{real_name}** for #{data[:price]} #{SPRING_CARNIVAL[:emoji]}!", ephemeral: true)
end

bot.select_menu(custom_id: /^carnbuy_char_/) do |event|
  owner_id = event.custom_id.split('_').last
  next event.respond(content: "🌸 *Not your menu!*", ephemeral: true) if event.user.id.to_s != owner_id

  char_name = event.values.first
  uid = event.user.id
  
  char_data = nil
  char_rarity = nil
  SPRING_CARNIVAL[:characters].each do |rarity, chars|
    found = chars.find { |c| c[:name] == char_name }
    if found
      char_data = found
      char_rarity = rarity.to_s
    end
  end

  if DB.get_tickets(uid) < char_data[:price]
    next event.respond(content: "🎟️ You need **#{char_data[:price]}** #{SPRING_CARNIVAL[:emoji]} to buy **#{char_name}**!", ephemeral: true)
  end

  DB.add_tickets(uid, -char_data[:price])
  DB.add_character(uid, char_name, char_rarity, 1)
  check_achievement(event.channel, event.user.id, 'carnival_char')

  event.respond(content: "✅ You bought **#{char_name}** (#{char_rarity.capitalize}) for #{char_data[:price]} #{SPRING_CARNIVAL[:emoji]}!", ephemeral: true)
end

# 6. Back to Hub Navigation
bot.button(custom_id: /^carnival_hub_/) do |event|
  owner_id = event.custom_id.split('_').last
  next event.respond(content: "🌸 *Not your menu!*", ephemeral: true) if event.user.id.to_s != owner_id
  
  uid = event.user.id
  tickets = DB.get_tickets(uid)

  embed = Discordrb::Webhooks::Embed.new(
    title: "🎪 Welcome to the Spring Carnival!",
    description: "Step right up! Play minigames to earn **#{SPRING_CARNIVAL[:currency]}** and spend them in the event shops.\n\n🎟️ **Your Balance:** #{tickets} #{SPRING_CARNIVAL[:emoji]}\n\n*Use the buttons below to explore the carnival grounds!*",
    color: 0xFF69B4,
    image: Discordrb::Webhooks::EmbedImage.new(url: "https://media.discordapp.net/attachments/1475890017443516476/1485732167983173713/CityView_ThemePark_01.jpg")
  )

  view = Discordrb::Components::View.new do |v|
    v.row do |r|
      r.button(custom_id: "carnival_shop_#{owner_id}", label: "Item Shop", style: :primary, emoji: "🍿")
      r.button(custom_id: "carnival_chars_#{owner_id}", label: "Character Shop", style: :success, emoji: "🌟")
    end
    v.row do |r|
      r.button(custom_id: "carnival_ringtoss_#{owner_id}", label: "Play: Ring Toss", style: :secondary, emoji: "⭕")
      r.button(custom_id: "carnival_game2_#{owner_id}", label: "Play: Balloon Pop", style: :secondary, emoji: "🎈")
    end
  end

  event.update_message(content: nil, embeds: [embed], components: view)
end