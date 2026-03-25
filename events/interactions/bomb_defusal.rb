# ==========================================
# EVENT: Bomb Defusal Handlers
# DESCRIPTION: Listens for button clicks on both spawned 
# bombs and random drop bombs.
# ==========================================

# Handler for spawned/command bombs
bot.button(custom_id: /^bomb_/) do |event|
  bomb_id = event.custom_id

  if ACTIVE_BOMBS[bomb_id]
    ACTIVE_BOMBS.delete(bomb_id) # Remove it so nobody else can click it
    reward = rand(50..150)
    final_reward = award_coins(event.bot, event.user.id, reward)

    defused_embed = Discordrb::Webhooks::Embed.new(
      title: "#{EMOJIS['surprise']} Bomb Defused!",
      description: "The bomb was successfully defused by #{event.user.mention}!\nThey earned **#{final_reward}** #{EMOJIS['s_coin']} for their bravery.",
      color: 0x00FF00 
    )
    event.update_message(content: nil, embeds: [defused_embed], components: [])
  else
    event.respond(content: '⚠️ *This bomb has already exploded or been defused!*', ephemeral: true)
  end
end

# Handler for random passive drop bombs
bot.button(custom_id: /^defuse_drop_(\d+)$/) do |event|
  uid = event.user.id
  reward = rand(100..500) # Random drops give more coins!
  final_reward = award_coins(event.bot, uid, reward)

  embed = Discordrb::Webhooks::Embed.new(
    title: "#{EMOJIS['coins']} Bomb Defused!",
    description: "#{event.user.mention} successfully cut the wire!\nThey looted **#{final_reward}** #{EMOJIS['s_coin']} from the casing.",
    color: 0x00FF00
  )
  event.update_message(content: nil, embeds: [embed], components: [])
end