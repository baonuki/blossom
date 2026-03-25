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