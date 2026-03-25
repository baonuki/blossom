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