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