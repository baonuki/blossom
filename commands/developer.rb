# =========================
# DEVELOPER & ADMIN COMMANDS 
# =========================

def execute_setlevel(event, target_user, new_level)
  unless event.server
    return event.respond("#{EMOJIS['x_']} This command can only be used inside a server!")
  end

  unless event.user.permission?(:administrator, event.channel) || event.user.id == DEV_ID
    return event.respond("#{EMOJIS['x_']} You need Administrator permissions to use this command!")
  end

  if target_user.nil? || new_level < 1
    return event.respond("Usage: `#{PREFIX}setlevel @user <level>`")
  end

  sid = event.server.id
  uid = target_user.id
  user = DB.get_user_xp(sid, uid)

  DB.update_user_xp(sid, uid, user['xp'], new_level, user['last_xp_at'])
  send_embed(event, title: "#{EMOJIS['developer']} Admin Override", description: "Successfully set #{target_user.mention}'s level to **#{new_level}**.")
end

bot.command(:setlevel, description: 'Set a user\'s server level (Admin Only)', min_args: 2, category: 'Admin') do |event, mention, level|
  execute_setlevel(event, event.message.mentions.first, level.to_i)
  nil
end

bot.application_command(:setlevel) do |event|
  target = event.bot.user(event.options['user'].to_i)
  execute_setlevel(event, target, event.options['level'])
end

def execute_addxp(event, target_user, amount)
  unless event.server
    return event.respond("#{EMOJIS['x_']} This command can only be used inside a server!")
  end

  unless event.user.permission?(:administrator, event.channel) || event.user.id == DEV_ID
    return event.respond("#{EMOJIS['x_']} You need Administrator permissions to use this command!")
  end

  if target_user.nil?
    return event.respond("Usage: `#{PREFIX}addxp @user <amount>`\n*(Tip: Use a negative number to remove XP!)*")
  end

  sid = event.server.id
  uid = target_user.id
  user = DB.get_user_xp(sid, uid)
  
  new_xp = user['xp'] + amount
  new_xp = 0 if new_xp < 0
  new_level = user['level']

  needed = new_level * 100
  while new_xp >= needed
    new_xp -= needed
    new_level += 1
    needed = new_level * 100
  end

  DB.update_user_xp(sid, uid, new_xp, new_level, user['last_xp_at'])
  send_embed(event, title: "#{EMOJIS['developer']} Admin Override", description: "Successfully added **#{amount}** XP to #{target_user.mention}.\nThey are now **Level #{new_level}** with **#{new_xp}** XP.")
end

bot.command(:addxp, description: 'Add or remove server XP from a user (Admin Only)', min_args: 2, category: 'Admin') do |event, mention, amount|
  execute_addxp(event, event.message.mentions.first, amount.to_i)
  nil
end

bot.application_command(:addxp) do |event|
  target = event.bot.user(event.options['user'].to_i)
  execute_addxp(event, target, event.options['amount'])
end

def execute_addcoins(event, target_user, amount)
  unless event.user.id == DEV_ID
    return event.respond("#{EMOJIS['x_']} Only the bot developer can use this command!")
  end

  if target_user.nil?
    return event.respond("Usage: `#{PREFIX}addcoins @user <amount>`\n*(Tip: Use a negative number to remove coins!)*")
  end

  uid = target_user.id
  DB.add_coins(uid, amount)
  send_embed(event, title: "#{EMOJIS['developer']} Developer Override", description: "Successfully added **#{amount}** #{EMOJIS['s_coin']} to #{target_user.mention}.\nTheir new balance is **#{DB.get_coins(uid)}**.")
end

bot.command(:addcoins, description: 'Add or remove coins from a user (Dev Only)', min_args: 2, category: 'Developer') do |event, mention, amount|
  execute_addcoins(event, event.message.mentions.first, amount.to_i)
  nil
end

bot.application_command(:addcoins) do |event|
  target = event.bot.user(event.options['user'].to_i)
  execute_addcoins(event, target, event.options['amount'])
end

def execute_setcoins(event, target_user, amount)
  unless event.user.id == DEV_ID
    return event.respond("#{EMOJIS['x_']} Only the bot developer can use this command!")
  end

  if target_user.nil? || amount < 0
    return event.respond("Usage: `#{PREFIX}setcoins @user <amount>`")
  end

  uid = target_user.id
  DB.set_coins(uid, amount)
  send_embed(event, title: "#{EMOJIS['developer']} Developer Override", description: "#{target_user.mention}'s balance has been forcefully set to **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}.")
end

bot.command(:setcoins, description: 'Set a user\'s balance to an exact amount (Dev Only)', min_args: 2, category: 'Developer') do |event, mention, amount|
  execute_setcoins(event, event.message.mentions.first, amount.to_i)
  nil
end

bot.application_command(:setcoins) do |event|
  target = event.bot.user(event.options['user'].to_i)
  execute_setcoins(event, target, event.options['amount'])
end

def execute_enablebombs(event, channel_id)
  unless event.user.permission?(:administrator, event.channel) || event.user.id == DEV_ID
    return event.respond("#{EMOJIS['x_']} You need Administrator permissions to set this up!")
  end

  target_channel = event.bot.channel(channel_id, event.server)

  if target_channel.nil?
    return event.respond("#{EMOJIS['x_']} Please mention a valid channel! Usage: `#{PREFIX}enablebombs #channel-name`")
  end

  sid = event.server.id
  threshold = rand(BOMB_MIN_MESSAGES..BOMB_MAX_MESSAGES)

  SERVER_BOMB_CONFIGS[sid] = {
    'enabled' => true,
    'channel_id' => channel_id,
    'message_count' => 0,
    'last_user_id' => nil,
    'threshold' => threshold
  }

  DB.save_bomb_config(sid, true, channel_id, threshold, 0)
  send_embed(event, title: "#{EMOJIS['bomb']} Bomb Drops Enabled!", description: "I will now randomly drop bombs in <##{channel_id}> as people chat!")
end

bot.command(:enablebombs, description: 'Enable random bomb drops in a specific channel (Admin Only)', min_args: 1, category: 'Admin') do |event, channel_mention|
  execute_enablebombs(event, channel_mention.gsub(/[<#>]/, '').to_i)
  nil
end

bot.application_command(:enablebombs) do |event|
  execute_enablebombs(event, event.options['channel'].to_i)
end

def execute_disablebombs(event)
  sid = event.server.id
  
  if SERVER_BOMB_CONFIGS[sid]
    SERVER_BOMB_CONFIGS[sid]['enabled'] = false
    DB.save_bomb_config(sid, false, SERVER_BOMB_CONFIGS[sid]['channel_id'], 0, 0)
    
    if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
      event.respond(content: "💣 Bomb drops disabled for this server.")
    else
      event.respond("💣 Bomb drops disabled for this server.")
    end
  end
end

bot.command(:disablebombs, category: 'Admin') do |event|
  execute_disablebombs(event)
  nil
end

bot.application_command(:disablebombs) do |event|
  execute_disablebombs(event)
end

def execute_blacklist(event, target_user)
  unless event.user.id == DEV_ID
    return event.respond("#{EMOJIS['x_']} Only the bot developer can use this command!")
  end

  if target_user.nil?
    return event.respond("Usage: `#{PREFIX}blacklist @user`")
  end

  uid = target_user.id
  
  if uid == DEV_ID
    return event.respond("#{EMOJIS['x_']} You cannot blacklist yourself!")
  end

  is_now_blacklisted = DB.toggle_blacklist(uid)

  if is_now_blacklisted
    event.bot.ignore_user(uid)
    send_embed(event, title: "🚫 User Blacklisted", description: "#{target_user.mention} has been added to the blacklist. I will now ignore all messages and commands from them.")
  else
    event.bot.unignore_user(uid)
    send_embed(event, title: "✅ User Forgiven", description: "#{target_user.mention} has been removed from the blacklist. They are free to interact again.")
  end
end

bot.command(:blacklist, description: 'Toggle blacklist for a user (Dev Only)', min_args: 1, category: 'Developer') do |event, mention|
  execute_blacklist(event, event.message.mentions.first)
  nil
end

bot.application_command(:blacklist) do |event|
  target = event.bot.user(event.options['user'].to_i)
  execute_blacklist(event, target)
end

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

def execute_backup(event)
  unless event.user.id == DEV_ID
    return send_embed(event, title: "❌ Access Denied", description: "This command is restricted to the Bot Developer.")
  end

  begin
    db_file = "blossom.db" 

    if File.exist?(db_file)
      event.user.pm("🌸 **Blossom Database Backup**\nGenerated: #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}")
      
      File.open(db_file, 'rb') do |file|
        event.user.send_file(file)
      end
      
      send_embed(event, title: "📂 Backup Successful", description: "I've sent the latest `blossom.db` to your DMs, Eve!")
    else
      current_path = Dir.pwd
      send_embed(event, title: "⚠️ File Not Found", description: "I'm looking in `#{current_path}`, but `blossom.db` isn't there.")
    end
  rescue => e
    send_embed(event, title: "❌ Backup Failed", description: "An error occurred: #{e.message}")
    puts "Backup Error: #{e.message}\n#{e.backtrace.first}"
  end
end

bot.command(:backup, description: 'Developer Only') do |event|
  execute_backup(event)
  nil
end

bot.application_command(:backup) do |event|
  execute_backup(event)
end

def execute_givepremium(event, target)
  unless event.user.id == DEV_ID 
    return send_embed(event, title: "❌ Access Denied", description: "Only the bot developer can grant Lifetime Premium.")
  end

  unless target
    return send_embed(event, title: "❌ Error", description: "Please mention a user to give lifetime premium to!")
  end

  DB.set_lifetime_premium(target.id, true)
  send_embed(event, title: "✨ Lifetime Premium Granted!", description: "**#{target.display_name}** has been permanently upgraded!\nThey will now receive the 10% coin boost, half cooldowns, and boosted gacha luck globally.")
end

bot.command(:givepremium, description: 'Give a user lifetime premium (Dev only)', category: 'Developer') do |event|
  execute_givepremium(event, event.message.mentions.first)
  nil
end

bot.application_command(:givepremium) do |event|
  target = event.bot.user(event.options['user'].to_i)
  execute_givepremium(event, target)
end

def execute_removepremium(event, target)
  unless event.user.id == DEV_ID
    return send_embed(event, title: "❌ Access Denied", description: "Only the bot developer can revoke Lifetime Premium.")
  end

  unless target
    return send_embed(event, title: "❌ Error", description: "Please mention a user to remove lifetime premium from!")
  end

  DB.set_lifetime_premium(target.id, false)
  send_embed(event, title: "🥀 Premium Revoked", description: "Lifetime Premium has been removed from **#{target.display_name}**.")
end

bot.command(:removepremium, description: 'Remove lifetime premium (Dev only)', category: 'Developer') do |event|
  execute_removepremium(event, event.message.mentions.first)
  nil
end

bot.application_command(:removepremium) do |event|
  target = event.bot.user(event.options['user'].to_i)
  execute_removepremium(event, target)
end