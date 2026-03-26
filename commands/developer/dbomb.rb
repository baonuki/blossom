# ==========================================
# COMMAND: dbomb (Developer Only)
# DESCRIPTION: Manually plants a timed bomb with a "Defuse" button.
# CATEGORY: Developer
# ==========================================

# ------------------------------------------
# LOGIC: Bomb Planting Execution
# ------------------------------------------
def execute_dbomb(event)
  # 1. Security: Strict Developer-Only Check
  unless DEV_IDS.include?(event.user.id)
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Permission Denied" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Nice try, but only my creator can plant manual bombs." }
    ]}])
  end

  # 2. Initialization: Set a 5-minute (300s) fuse and create a unique ID
  expire_time = Time.now + 300
  discord_timestamp = "<t:#{expire_time.to_i}:R>"
  bomb_id = "bomb_#{expire_time.to_i}_#{rand(10000)}"

  # 3. Tracking: Store the bomb in the global active hash
  ACTIVE_BOMBS[bomb_id] = true

  # 4. UI: Create the "Planted" Embed with a random neon color
  embed = Discordrb::Webhooks::Embed.new(
    title: "#{EMOJI_STRINGS['bomb']} Bomb Planted!",
    description: "#{EMOJI_STRINGS['bomb']} EVERYONE SHUT UP — A BOMB JUST DROPPED!\nIt's gonna blow **#{discord_timestamp}**! Cut the wire before it's too late!",
    color: NEON_COLORS.sample
  )

  # 5. UI: Create the "Defuse" Button
  view = Discordrb::Components::View.new do |v|
    v.row { |r| r.button(custom_id: bomb_id, label: 'Cut the Wire!', style: :danger, emoji: '✂️') }
  end

  # 6. Messaging: Handle response based on event type (Slash vs. Prefix)
  if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
    event.respond(content: "Bomb planted! Hehe~", ephemeral: true)
    msg = event.channel.send_message(nil, false, embed, nil, nil, nil, view)
  else
    msg = event.channel.send_message(nil, false, embed, nil, nil, event.message, view)
  end

  # 7. Threading: Start the 5-minute countdown in the background
  Thread.new do
    sleep 300

    if ACTIVE_BOMBS[bomb_id]
      ACTIVE_BOMBS.delete(bomb_id)

      exploded_embed = Discordrb::Webhooks::Embed.new(
        title: "#{EMOJI_STRINGS['bomb']} BOOM!",
        description: "Nobody defused it in time... absolute L for this server.",
        color: 0x000000
      )

      msg.edit(nil, exploded_embed, Discordrb::Components::View.new) if msg
    end
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!dbomb)
# ------------------------------------------
$bot.command(:dbomb,
  description: 'Plant a manual bomb (Developer only)',
  category: 'Developer'
) do |event|
  execute_dbomb(event)
  nil
end
