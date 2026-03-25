def execute_view(event, search_name)
  uid = event.user.id
  search_name = search_name.strip
  user_chars = DB.get_collection(uid)
  
  owned_name = user_chars.keys.find { |k| k.downcase == search_name.downcase }
  
  unless owned_name && (user_chars[owned_name]['count'] > 0 || user_chars[owned_name]['ascended'].to_i > 0)
    return send_embed(event, title: "#{EMOJIS['confused']} Character Not Found", description: "You don't own **#{search_name}** yet!\nUse `/summon` to roll for them, or `/buy` to get them from the shop.")
  end
  
  result = find_character_in_pools(owned_name)
  char_data = result[:char]
  rarity    = result[:rarity]
  count     = user_chars[owned_name]['count']
  ascended  = user_chars[owned_name]['ascended'].to_i
  
  emoji = case rarity
          when 'goddess'   then '💎'
          when 'legendary' then '🌟'
          when 'rare'      then '✨'
          else '⭐'
          end
          
  desc = "You currently own **#{count}** standard copies of this character.\n"
  desc += "#{EMOJIS['neonsparkle']} **You own #{ascended} Shiny Ascended copies!** #{EMOJIS['neonsparkle']}" if ascended > 0

  send_embed(event, title: "#{emoji} #{owned_name} (#{rarity.capitalize})", description: desc, image: char_data[:gif])
end

bot.command(:view, description: 'Look at a specific character you own', min_args: 1, category: 'Gacha') do |event, *name_args|
  execute_view(event, name_args.join(' '))
  nil
end

bot.application_command(:view) do |event|
  execute_view(event, event.options['character'])
end