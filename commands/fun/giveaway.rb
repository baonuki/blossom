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
  unless event.user.permission?(:administrator, event.channel) || DEV_IDS.include?(event.user.id)
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Permission Denied" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Lol nope. Admins only, bestie." }
    ]}])
  end

  # 2. Validation: Ensure the target channel exists and is accessible
  target_channel = event.bot.channel(channel_id, event.server)
  unless target_channel
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['error']} Error" },
      { type: 14, spacing: 1 },
      { type: 10, content: "That channel doesn't exist. You good?" }
    ]}])
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
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['error']} Invalid Time Format" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Skill issue. Use `10m`, `5h`, or `2d`." }
    ]}])
  end

  # 4. Preparation: Calculate expiry and generate a unique tracking ID
  expire_time = Time.now + duration
  giveaway_id = "gw_#{expire_time.to_i}_#{rand(10000)}"
  discord_timestamp = "<t:#{expire_time.to_i}:R>"

  # 5. UI: Construct the Giveaway Announcement Embed
  embed = Discordrb::Webhooks::Embed.new(
    title: "#{EMOJI_STRINGS['surprise']} **GIVEAWAY: #{prize}** #{EMOJI_STRINGS['surprise']}",
    description: "Hosted by: #{event.user.mention}\nEnds: **#{discord_timestamp}**\n\nSmash that button to enter. Don't be shy~",
    color: 0xFFD700 # Gold
  )

  # 6. Components: Attach the 'Enter' Button
  view = Discordrb::Components::View.new do |v|
    v.row { |r| r.button(custom_id: giveaway_id, label: 'Enter Giveaway', style: :success, emoji: EMOJI_OBJECTS['surprise']) }
  end

  # 7. Deployment: Send the message to the target channel
  msg = target_channel.send_message(nil, false, embed, nil, nil, nil, view)
  
  # 8. Persistence: Save the giveaway details to the SQLite/PostgreSQL database
  DB.create_giveaway(giveaway_id, target_channel.id, msg.id, event.user.id, prize, expire_time.to_i)
  
  # 9. Feedback: Confirm to the host that the giveaway is live
  response_text = "✅ Giveaway is LIVE in #{target_channel.mention}! Let's goooo~"
  if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
    event.respond(content: response_text, ephemeral: true)
  else
    event.respond(response_text)
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!giveaway)
# ------------------------------------------
$bot.command(:giveaway,
  description: 'Start a giveaway (Admin only)',
  category: 'Admin'
) do |event, channel_mention, time_str, *prize_args|
  if channel_mention.nil? || time_str.nil? || prize_args.empty?
    send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['confused']} How Do Giveaways Work?" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You need to tell me WHERE, HOW LONG, and WHAT, chat.\n\n**Usage:** `#{PREFIX}giveaway #channel <time> <prize>`\n*Example:* `#{PREFIX}giveaway #general 1h Nitro Classic`\n\n*Time formats:* `10m`, `2h`, `1d`" }
    ]}])
    next
  end
  channel_id = channel_mention.gsub(/[^0-9]/, '').to_i
  prize = prize_args.join(' ')
  
  execute_giveaway(event, channel_id, time_str, prize)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/giveaway)
# ------------------------------------------
$bot.application_command(:giveaway) do |event|
  # Fetch options directly from the Slash interaction
  channel_id = event.options['channel'].to_i
  time_str = event.options['time']
  prize = event.options['prize']
  
  execute_giveaway(event, channel_id, time_str, prize)
end