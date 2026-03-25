def execute_collab(event)
  uid = event.user.id
  now = Time.now
  last_used = DB.get_cooldown(uid, 'collab')

  if last_used && (now - last_used) < COLLAB_COOLDOWN
    remaining = COLLAB_COOLDOWN - (now - last_used)
    return send_embed(event, title: "#{EMOJIS['worktired']} Collab Burnout", description: "You're collaborating too much! Rest your voice.\nTry again in **#{format_time_delta(remaining)}**.")
  end

  DB.set_cooldown(uid, 'collab', now)
  expire_time = Time.now + 180 
  discord_timestamp = "<t:#{expire_time.to_i}:R>"
  
  collab_id = "collab_#{expire_time.to_i}_#{rand(10000)}"
  ACTIVE_COLLABS[collab_id] = uid 

  embed = Discordrb::Webhooks::Embed.new(
    title: "#{EMOJIS['stream']} Collab Request!",
    description: "#{event.user.mention} is looking for someone to do a collab stream with!\n\nPress the button below to join them! Request expires **#{discord_timestamp}**.",
    color: NEON_COLORS.sample
  )

  view = Discordrb::Components::View.new do |v|
    v.row { |r| r.button(custom_id: collab_id, label: 'Accept Collab', style: :success, emoji: '🤝') }
  end

  if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
    event.respond(content: "Starting collab request...", ephemeral: true)
    msg = event.channel.send_message(nil, false, embed, nil, nil, nil, view)
  else
    msg = event.channel.send_message(nil, false, embed, nil, nil, event.message, view)
  end

  Thread.new do
    sleep 180
    if ACTIVE_COLLABS.key?(collab_id)
      ACTIVE_COLLABS.delete(collab_id)
      failed_embed = Discordrb::Webhooks::Embed.new(title: "#{EMOJIS['x_']} Collab Cancelled", description: "Nobody was available to collab with #{event.user.mention} this time #{EMOJIS['confused']}...", color: 0x808080)
      msg.edit(nil, failed_embed, Discordrb::Components::View.new) if msg
    end
  end
end

bot.command(:collab, description: 'Ask the server to do a collab stream! (30m cooldown)', category: 'Economy') { |e| execute_collab(e); nil }
bot.application_command(:collab) { |e| execute_collab(e) }