# ==========================================
# COMMAND: bomb (Developer Only)
# DESCRIPTION: Manually plants a timed bomb with a "Defuse" button.
# CATEGORY: Developer / Fun
# ==========================================

# ------------------------------------------
# LOGIC: Bomb Planting Execution
# ------------------------------------------
def execute_bomb(event)
  # 1. Security: Strict Developer-Only Check
  unless event.user.id == DEV_ID
    return send_embed(event, 
      title: "#{EMOJIS['x_']} Permission Denied", 
      description: 'You need developer permissions to plant a bomb!'
    )
  end

  # 2. Initialization: Set a 5-minute (300s) fuse and create a unique ID
  expire_time = Time.now + 300
  discord_timestamp = "<t:#{expire_time.to_i}:R>" # Relative Discord timestamp (e.g., "in 5 minutes")
  bomb_id = "bomb_#{expire_time.to_i}_#{rand(10000)}"
  
  # 3. Tracking: Store the bomb in the global active hash
  ACTIVE_BOMBS[bomb_id] = true

  # 4. UI: Create the "Planted" Embed with a random neon color
  embed = Discordrb::Webhooks::Embed.new(
    title: "#{EMOJIS['bomb']} Bomb Planted!",
    description: "A bomb has been planted! It will explode **#{discord_timestamp}**!\nQuick, press the button to defuse it and earn a reward!",
    color: NEON_COLORS.sample
  )

  # 5. UI: Create the "Defuse" Button
  view = Discordrb::Components::View.new do |v|
    v.row { |r| r.button(custom_id: bomb_id, label: 'Defuse', style: :danger, emoji: '✂️') }
  end

  # 6. Messaging: Handle response based on event type (Slash vs. Prefix)
  if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
    event.respond(content: "Bomb planted!", ephemeral: true)
    msg = event.channel.send_message(nil, false, embed, nil, nil, nil, view)
  else
    msg = event.channel.send_message(nil, false, embed, nil, nil, event.message, view)
  end

  # 7. Threading: Start the 5-minute countdown in the background
  Thread.new do
    sleep 300 # Wait for the fuse to burn
    
    # 8. Result: Check if the bomb is still active (was it defused?)
    if ACTIVE_BOMBS[bomb_id]
      # Remove from tracking and edit message to the "Exploded" state
      ACTIVE_BOMBS.delete(bomb_id)
      
      exploded_embed = Discordrb::Webhooks::Embed.new(
        title: "#{EMOJIS['bomb']} BOOM!", 
        description: 'Nobody defused it in time... The bomb exploded!', 
        color: 0x000000 # Black for the charred remains
      )
      
      # Remove the button view so no one can "defuse" a pile of ash
      msg.edit(nil, exploded_embed, Discordrb::Components::View.new) if msg
    end
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!bomb)
# ------------------------------------------
bot.command(:bomb, 
  description: 'Plant a bomb that explodes in 5 minutes (Developer only)', 
  category: 'Fun'
) do |event|
  execute_bomb(event)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/bomb)
# ------------------------------------------
bot.application_command(:bomb) do |event|
  execute_bomb(event)
end