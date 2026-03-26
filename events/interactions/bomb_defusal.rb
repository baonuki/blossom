# ==========================================
# EVENT: Bomb Defusal Handlers
# DESCRIPTION: Listens for button clicks on both spawned 
# bombs and random drop bombs.
# ==========================================

# Handler for spawned/command bombs
$bot.button(custom_id: /^bomb_/) do |event|
  bomb_id = event.custom_id

  if ACTIVE_BOMBS[bomb_id]
    ACTIVE_BOMBS.delete(bomb_id) # Remove it so nobody else can click it
    reward = rand(50..150)
    final_reward = award_coins(event.bot, event.user.id, reward)

    defused_embed = Discordrb::Webhooks::Embed.new(
      title: "#{EMOJI_STRINGS['surprise']} Bomb Defused!",
      description: "NO WAY — #{event.user.mention} clutched it!\nThey snagged **#{final_reward}** #{EMOJI_STRINGS['s_coin']} for being cracked.",
      color: 0x00FF00 
    )
    event.update_message(content: nil, embeds: [defused_embed], components: [])
  else
    event.respond(content: "#{EMOJI_STRINGS['error']} *Too slow! That bomb is already dealt with.*", ephemeral: true)
  end
end

# Handler for random passive drop bombs
$bot.button(custom_id: /^defuse_drop_(\d+)$/) do |event|
  uid = event.user.id
  reward = rand(100..500) # Random drops give more coins!
  final_reward = award_coins(event.bot, uid, reward)

  embed = Discordrb::Webhooks::Embed.new(
    title: "#{EMOJI_STRINGS['coins']} Bomb Defused!",
    description: "#{event.user.mention} cut the wire like a pro!\nLooted **#{final_reward}** #{EMOJI_STRINGS['s_coin']} from the wreckage. W.",
    color: 0x00FF00
  )
  event.update_message(content: nil, embeds: [embed], components: [])
end