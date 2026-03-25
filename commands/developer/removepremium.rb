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