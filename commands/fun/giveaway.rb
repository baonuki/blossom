def execute_giveaway(event, channel_id, time_str, prize)
  unless event.user.permission?(:administrator, event.channel) || event.user.id == DEV_ID
    return send_embed(event, title: "❌ Permission Denied", description: 'You need Administrator permissions to start a giveaway!')
  end

  target_channel = event.bot.channel(channel_id, event.server)
  unless target_channel
    return send_embed(event, title: "⚠️ Error", description: "I couldn't find that channel!")
  end

  duration = 0
  if time_str =~ /^(\d+)(m|h|d)$/i
    amount = $1.to_i
    unit = $2.downcase
    duration = amount * 60 if unit == 'm'
    duration = amount * 3600 if unit == 'h'
    duration = amount * 86400 if unit == 'd'
  else
    return send_embed(event, title: "⚠️ Invalid Time Format", description: "Example: `10m` or `2d`")
  end

  expire_time = Time.now + duration
  giveaway_id = "gw_#{expire_time.to_i}_#{rand(10000)}"
  discord_timestamp = "<t:#{expire_time.to_i}:R>"

  embed = Discordrb::Webhooks::Embed.new(
    title: "🎉 **GIVEAWAY: #{prize}** 🎉",
    description: "Hosted by: #{event.user.mention}\nEnds: **#{discord_timestamp}**\n\nClick the button below to enter!",
    color: 0xFFD700 
  )

  view = Discordrb::Components::View.new do |v|
    v.row { |r| r.button(custom_id: giveaway_id, label: 'Enter Giveaway', style: :success, emoji: '🎉') }
  end

  msg = target_channel.send_message(nil, false, embed, nil, nil, nil, view)
  DB.create_giveaway(giveaway_id, target_channel.id, msg.id, event.user.id, prize, expire_time.to_i)
  
  if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
    event.respond(content: "✅ Giveaway successfully saved to the database and started in #{target_channel.mention}!")
  else
    event.respond("✅ Giveaway successfully saved to the database and started in #{target_channel.mention}!")
  end
end

bot.command(:giveaway, description: 'Start a giveaway (Admin only)', min_args: 3, usage: 'b!giveaway #channel 10m Prize Name', category: 'Admin') do |event, channel_mention, time_str, *prize_args|
  channel_id = channel_mention.gsub(/[^0-9]/, '').to_i
  prize = prize_args.join(' ')
  execute_giveaway(event, channel_id, time_str, prize)
  nil
end

bot.application_command(:giveaway) do |event|
  channel_id = event.options['channel'].to_i
  time_str = event.options['time']
  prize = event.options['prize']
  execute_giveaway(event, channel_id, time_str, prize)
end