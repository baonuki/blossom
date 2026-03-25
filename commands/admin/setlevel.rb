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