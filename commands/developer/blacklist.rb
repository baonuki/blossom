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