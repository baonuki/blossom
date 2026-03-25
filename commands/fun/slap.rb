def execute_slap(event, target)
  if target.nil?
    return send_embed(event, title: "#{EMOJIS['error']} Interaction Error", description: "Mention someone to slap!")
  end

  if target.id == event.bot.profile.id
    DB.add_interaction(event.user.id, 'slap', 'sent')
    DB.add_interaction(target.id, 'slap', 'received')
    DB.add_interaction(target.id, 'slap', 'sent')
    DB.add_interaction(event.user.id, 'slap', 'received')

    uid = event.user.id
    target_id = target.id

    check_achievement(event.channel, uid, 'first_slap')
  stats = DB.get_interactions(uid)['slap']
    check_achievement(event.channel, uid, 'slap_sent_10') if stats['sent'].to_i >= 10
    check_achievement(event.channel, uid, 'slap_sent_50') if stats['sent'].to_i >= 50

  target_stats = DB.get_interactions(target_id)['slap']
    check_achievement(event.channel, target_id, 'slap_rec_10') if target_stats['received'].to_i >= 10
    check_achievement(event.channel, target_id, 'slap_rec_50') if target_stats['received'].to_i >= 50

    actor_stats = DB.get_interactions(event.user.id)['slap']
    bot_stats   = DB.get_interactions(target.id)['slap']

    send_embed(event, title: "💢 Bot Abuse Detected!", description: "Hey! #{event.user.mention} just slapped me?! Chat, clip that! That is literal bot abuse.\n\n*Blossom smacks you right back!*", fields: [
      { name: "#{event.user.name}'s Slaps", value: "Sent: **#{actor_stats['sent']}**\nReceived: **#{actor_stats['received']}**", inline: true },
      { name: "Blossom's Slaps", value: "Sent: **#{bot_stats['sent']}**\nReceived: **#{bot_stats['received']}**", inline: true }
    ], image: SLAP_GIFS.sample)
  else
    interaction_embed(event, 'slap', SLAP_GIFS, target)
  end
end

bot.command(:slap, description: 'Send a playful slap with a random GIF', category: 'Fun') do |event|
  execute_slap(event, event.message.mentions.first)
  nil
end

bot.application_command(:slap) do |event|
  target_id = event.options['user']
  target = event.bot.user(target_id.to_i) if target_id
  execute_slap(event, target)
end