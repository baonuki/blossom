def execute_ascend(event, search_name)
  uid = event.user.id
  search_name = search_name.downcase.strip
  user_chars = DB.get_collection(uid)
  
  owned_name = user_chars.keys.find { |k| k.downcase == search_name }

  unless owned_name
    return send_embed(event, title: "#{EMOJIS['error']} Ascension Failed", description: "You don't own any copies of **#{search_name}**!")
  end

  if user_chars[owned_name]['count'] < 5
    return send_embed(event, title: "#{EMOJIS['nervous']} Not Enough Copies", description: "You need **5 copies** of #{owned_name} to ascend them. You only have **#{user_chars[owned_name]['count']}**.")
  end

  ascension_cost = 5000
  if DB.get_coins(uid) < ascension_cost
    return send_embed(event, title: "#{EMOJIS['nervous']} Insufficient Funds", description: "The ritual costs **#{ascension_cost}** #{EMOJIS['s_coin']}. You currently have **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}.")
  end

  DB.add_coins(uid, -ascension_cost)
  DB.ascend_character(uid, owned_name)

  check_achievement(event.channel, event.user.id, 'ascension')

  send_embed(event, title: "#{EMOJIS['neonsparkle']} Ascension Complete! #{EMOJIS['neonsparkle']}", description: "You paid **#{ascension_cost}** #{EMOJIS['s_coin']} and fused 5 copies of **#{owned_name}** together!\n\nThey have been reborn as a **Shiny Ascended** character. View them in your `/collection`!")
end

bot.command(:ascend, description: 'Fuse 5 duplicate characters into a Shiny Ascended version!', min_args: 1, category: 'Gacha') do |event, *name_args|
  execute_ascend(event, name_args.join(' '))
  nil
end

bot.application_command(:ascend) do |event|
  execute_ascend(event, event.options['character'])
end