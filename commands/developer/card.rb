def execute_card(event, action, target_user, name_query)
  unless event.user.id == DEV_ID
    return send_embed(event, title: "❌ Access Denied", description: "This command is restricted to the Bot Developer.")
  end

  unless target_user
    return send_embed(event, title: "⚠️ Error", description: "You must mention a user to modify their collection.")
  end

  found_data = find_character_in_pools(name_query)
  unless found_data
    return send_embed(event, title: "⚠️ Character Not Found", description: "I couldn't find `#{name_query}` in the pools.")
  end

  real_name = found_data[:char][:name]
  rarity = found_data[:rarity]
  uid = target_user.id

  case action.downcase
  when 'add', 'give'
    DB.add_character(uid, real_name, rarity, 1)
    send_embed(event, title: "🎁 Card Added", description: "Added **#{real_name}** to #{target_user.mention}'s collection!")

  when 'remove', 'take'
    DB.remove_character(uid, real_name, 1)
    send_embed(event, title: "🗑️ Card Removed", description: "Removed one copy of **#{real_name}** from #{target_user.mention}.")

  when 'giveascended', 'give✨', 'addascended'
    DB.instance_variable_get(:@db).execute(
      "INSERT INTO collections (user_id, character_name, rarity, count, ascended) 
       VALUES (?, ?, ?, 0, 1) 
       ON CONFLICT(user_id, character_name) 
       DO UPDATE SET ascended = ascended + 1", 
      [uid, real_name, rarity]
    )
    send_embed(event, title: "✨ Ascended Card Granted", description: "Successfully granted an **Ascended #{real_name}** to #{target_user.mention}!")

  when 'takeascended', 'take✨', 'removeascended'
    DB.instance_variable_get(:@db).execute(
      "UPDATE collections SET ascended = MAX(0, ascended - 1) 
       WHERE user_id = ? AND character_name = ?", 
      [uid, real_name]
    )
    send_embed(event, title: "♻️ Ascended Card Removed", description: "Removed one ✨ star from #{target_user.mention}'s **#{real_name}**.")

  else
    send_embed(event, title: "⚠️ Invalid Action", description: "Use `add`, `remove`, `giveascended`, or `takeascended`.")
  end
end

bot.command(:card, min_args: 3, description: 'Manage user cards (Dev Only)', usage: '!card <add/remove/giveascended/takeascended> @user <Character Name>') do |event, action, target, *char_name|
  execute_card(event, action, event.message.mentions.first, char_name.join(' '))
  nil
end

bot.application_command(:card) do |event|
  target = event.bot.user(event.options['user'].to_i)
  execute_card(event, event.options['action'], target, event.options['character'])
end