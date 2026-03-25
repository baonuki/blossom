def execute_bomb(event)
  unless event.user.id == DEV_ID
    return send_embed(event, title: "#{EMOJIS['x_']} Permission Denied", description: 'You need developer permissions to plant a bomb!')
  end

  expire_time = Time.now + 300
  discord_timestamp = "<t:#{expire_time.to_i}:R>"
  bomb_id = "bomb_#{expire_time.to_i}_#{rand(10000)}"
  ACTIVE_BOMBS[bomb_id] = true

  embed = Discordrb::Webhooks::Embed.new(
    title: "#{EMOJIS['bomb']} Bomb Planted!",
    description: "A bomb has been planted! It will explode **#{discord_timestamp}**!\nQuick, press the button to defuse it and earn a reward!",
    color: NEON_COLORS.sample
  )

  view = Discordrb::Components::View.new do |v|
    v.row { |r| r.button(custom_id: bomb_id, label: 'Defuse', style: :danger, emoji: '✂️') }
  end

  if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
    event.respond(content: "Bomb planted!", ephemeral: true)
    msg = event.channel.send_message(nil, false, embed, nil, nil, nil, view)
  else
    msg = event.channel.send_message(nil, false, embed, nil, nil, event.message, view)
  end

  Thread.new do
    sleep 300
    if ACTIVE_BOMBS[bomb_id]
      ACTIVE_BOMBS.delete(bomb_id)
      exploded_embed = Discordrb::Webhooks::Embed.new(title: "#{EMOJIS['bomb']} BOOM!", description: 'Nobody defused it in time... The bomb exploded!', color: 0x000000)
      msg.edit(nil, exploded_embed, Discordrb::Components::View.new) if msg
    end
  end
end

bot.command(:bomb, description: 'Plant a bomb that explodes in 5 minutes (Developer only)', category: 'Fun') { |e| execute_bomb(e); nil }
bot.application_command(:bomb) { |e| execute_bomb(e) }