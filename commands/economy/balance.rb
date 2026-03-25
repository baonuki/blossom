def execute_balance(event, target_user)
  uid = target_user.id
  coins = DB.get_coins(uid)
  prisma = DB.get_prisma(uid)
  is_sub = is_premium?(event.bot, uid)
  daily_info = DB.get_daily_info(uid)

  badges = []
  badges << "#{EMOJIS['developer']} **Bot Developer**" if uid == DEV_ID
  badges << "<:prisma:1486142162805723196> **Premium**" if is_sub
  
  header = badges.empty? ? "" : badges.join(" | ") + "\n\n"

  embed = Discordrb::Webhooks::Embed.new(
    title: "🌸 #{target_user.display_name}'s Balance",
    description: "#{header}**Coins:** #{coins} #{EMOJIS['s_coin']}\n**Prisma:** #{prisma} <:prisma:1486142162805723196>\n🔥 **Daily Streak:** #{daily_info['streak']} Days\n\n*Use the dropdown below to view your items, VTubers, and Achievements!*",
    color: 0xFFB6C1
  )

  view = balance_select_menu(uid, 'home')

  if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
    event.respond(embeds: [embed], components: view)
  else
    event.channel.send_message(nil, false, embed, nil, nil, nil, view)
  end
end

bot.command(:balance, description: 'Show a user\'s coin balance, gacha stats, and inventory', category: 'Economy') do |event|
  execute_balance(event, event.message.mentions.first || event.user)
  nil
end

bot.application_command(:balance) do |event|
  target_id = event.options['user']
  target = target_id ? event.bot.user(target_id.to_i) : event.user
  execute_balance(event, target)
end