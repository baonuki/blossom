def execute_givecard(event, target, char_name)
  uid = event.user.id

  if target.nil? || target.id == uid
    return send_embed(event, title: "⚠️ Invalid Target", description: "You need to mention another user to give a card to!")
  end

  if char_name.nil? || char_name.strip.empty?
    return send_embed(event, title: "⚠️ Missing Character", description: "Please specify the character you want to give.")
  end

  pool_data = find_character_in_pools(char_name)
  unless pool_data
    return send_embed(event, title: "⚠️ Unknown Character", description: "I couldn't find a character named **#{char_name}** in the pools.")
  end

  proper_name = pool_data[:char][:name]
  rarity = pool_data[:rarity]

  giver_collection = DB.get_collection(uid)
  if giver_collection[proper_name].nil? || giver_collection[proper_name]['count'] <= 0
    return send_embed(event, title: "❌ Missing Card", description: "You don't own any unascended copies of **#{proper_name}** to give away!")
  end

  DB.give_card(uid, target.id, proper_name, rarity)

  emoji = case rarity
          when 'goddess'   then '💎'
          when 'legendary' then '🌟'
          when 'rare'      then '✨'
          else '⭐'
          end

  send_embed(
    event,
    title: "🎁 Card Transferred!",
    description: "#{event.user.mention} generously gave **#{proper_name}** to #{target.mention}! 🌸\n\n*(Rarity: #{rarity.capitalize} #{emoji})*"
  )
end

bot.command(:givecard, description: 'Give a VTuber card to another user', category: 'Gacha') do |event, mention, *char_parts|
  char_name = char_parts.join(' ')
  execute_givecard(event, event.message.mentions.first, char_name)
  nil
end

bot.application_command(:givecard) do |event|
  target = event.bot.user(event.options['user'].to_i)
  char_name = event.options['character']
  execute_givecard(event, target, char_name)
end