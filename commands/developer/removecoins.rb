def execute_removecoins(event, target, amount_str)
  unless event.user.id == DEV_ID
    return send_embed(event, title: "❌ Permission Denied", description: "Only the bot developer can use this command.")
  end

  if target.nil?
    return send_embed(event, title: "⚠️ Missing Target", description: "Please mention the user you want to remove coins from.")
  end

  amount = amount_str.to_i
  if amount <= 0
    return send_embed(event, title: "⚠️ Invalid Amount", description: "Please specify a positive number of coins to remove.")
  end

  current_balance = DB.get_coins(target.id)
  
  actual_removal = [amount, current_balance].min 
  
  DB.add_coins(target.id, -actual_removal)

  send_embed(
    event, 
    title: "💸 Coins Removed", 
    description: "Successfully removed **#{actual_removal}** #{EMOJIS['s_coin']} from #{target.mention}.\n\nNew balance: **#{DB.get_coins(target.id)}** #{EMOJIS['s_coin']}"
  )
end

bot.command(:removecoins, description: 'Remove coins from a user (Dev Only)', category: 'Developer') do |event, mention, amount|
  execute_removecoins(event, event.message.mentions.first, amount)
  nil
end

bot.application_command(:removecoins) do |event|
  target = event.bot.user(event.options['user'].to_i)
  execute_removecoins(event, target, event.options['amount'])
end