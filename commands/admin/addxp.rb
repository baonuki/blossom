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