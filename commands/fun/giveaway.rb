# ==========================================
# COMMAND: giveaway
# DESCRIPTION: Start a giveaway in a specific channel with a custom duration and prize.
# CATEGORY: Admin
# ==========================================

# ------------------------------------------
# LOGIC: Giveaway Execution
# ------------------------------------------
def execute_giveaway(event, channel_id, time_str, prize)
  # 1. Security: Ensure the user is an Admin or the Developer
  unless event.user.permission?(:administrator, event.channel) || event.user.id == DEV_ID
    return send_embed(event, 
      title: "❌ Permission Denied", 
      description: 'You need Administrator permissions to start a giveaway!'
    )
  end

  # 2. Validation: Ensure the target channel exists and is accessible
  target_channel = event.bot.channel(channel_id, event.server)
  unless target_channel
    return send_embed(event, 
      title: "⚠️ Error", 
      description: "I couldn't find that channel!"
    )
  end

  # 3. Time Parsing: Convert strings like "10m", "2h", or "1d" into seconds
  duration = 0
  if time_str =~ /^(\d+)(m|h|d)$/i
    amount = $1.to_i
    unit = $2.downcase
    duration = amount * 60 if unit == 'm'
    duration = amount * 3600 if unit == 'h'
    duration = amount * 86400 if unit == 'd'
  else
    return send_embed(event, 
      title: "⚠️ Invalid Time Format", 
      description: "Please use a format like `10m`, `5h`, or `2d`."
    )
  end

  # 4. Preparation: Calculate expiry and generate a unique tracking ID
  expire_time = Time.now + duration
  giveaway_id = "gw_#{expire_time.to_i}_#{rand(10000)}"
  discord_timestamp = "<t:#{expire_time.to_i}:R>"

  # 5. UI: Construct the Giveaway Announcement Embed
  embed = Discordrb::Webhooks::Embed.new(
    title: "🎉 **GIVEAWAY: #{prize}** 🎉",
    description: "Hosted by: #{event.user.mention}\nEnds: **#{discord_timestamp}**\n\nClick the button below to enter!",
    color: 0xFFD700 # Gold
  )

  # 6. Components: Attach the 'Enter' Button
  view = Discordrb::Components::View.new do |v|
    v.row { |r| r.button(custom_id: giveaway_id, label: 'Enter Giveaway', style: :success, emoji: '🎉') }
  end

  # 7. Deployment: Send the message to the target channel
  msg = target_channel.send_message(nil, false, embed, nil, nil, nil, view)
  
  # 8. Persistence: Save the giveaway details to the SQLite/PostgreSQL database
  DB.create_giveaway(giveaway_id, target_channel.id, msg.id, event.user.id, prize, expire_time.to_i)
  
  # 9. Feedback: Confirm to the host that the giveaway is live
  response_text = "✅ Giveaway successfully started in #{target_channel.mention}!"
  if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
    event.respond(content: response_text, ephemeral: true)
  else
    event.respond(response_text)
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!giveaway)
# ------------------------------------------
bot.command(:giveaway, 
  description: 'Start a giveaway (Admin only)', 
  min_args: 3, 
  usage: 'b!giveaway #channel 10m Prize Name', 
  category: 'Admin'
) do |event, channel_mention, time_str, *prize_args|
  # Strip non-numeric characters from the channel mention to get the ID
  channel_id = channel_mention.gsub(/[^0-9]/, '').to_i
  prize = prize_args.join(' ')
  
  execute_giveaway(event, channel_id, time_str, prize)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/giveaway)
# ------------------------------------------
bot.application_command(:giveaway) do |event|
  # Fetch options directly from the Slash interaction
  channel_id = event.options['channel'].to_i
  time_str = event.options['time']
  prize = event.options['prize']
  
  execute_giveaway(event, channel_id, time_str, prize)
end