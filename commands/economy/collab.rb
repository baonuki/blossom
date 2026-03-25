# ==========================================
# COMMAND: collab
# DESCRIPTION: Starts a public request for another user to collaborate on a stream.
# CATEGORY: Economy
# ==========================================

# ------------------------------------------
# LOGIC: Collab Request Execution
# ------------------------------------------
def execute_collab(event)
  # 1. Initialization: Get user ID and current timestamp
  uid = event.user.id
  now = Time.now
  
  # 2. Cooldown Check: Verify the user isn't on "Collab Burnout"
  last_used = DB.get_cooldown(uid, 'collab')

  if last_used && (now - last_used) < COLLAB_COOLDOWN
    remaining = COLLAB_COOLDOWN - (now - last_used)
    return send_embed(event, 
      title: "#{EMOJIS['worktired']} Collab Burnout", 
      description: "You're collaborating too much! Rest your voice.\nTry again in **#{format_time_delta(remaining)}**."
    )
  end

  # 3. Database: Update the cooldown timestamp immediately
  DB.set_cooldown(uid, 'collab', now)
  
  # 4. Preparation: Set expiration (3 minutes) and generate a unique ID
  expire_time = Time.now + 180 
  discord_timestamp = "<t:#{expire_time.to_i}:R>" # Relative Discord timestamp
  collab_id = "collab_#{expire_time.to_i}_#{rand(10000)}"
  
  # 5. Tracking: Store the request in the global active collab hash
  ACTIVE_COLLABS[collab_id] = uid 

  # 6. UI: Build the invitation Embed
  embed = Discordrb::Webhooks::Embed.new(
    title: "#{EMOJIS['stream']} Collab Request!",
    description: "#{event.user.mention} is looking for someone to do a collab stream with!\n\n" \
                 "Press the button below to join them! Request expires **#{discord_timestamp}**.",
    color: NEON_COLORS.sample
  )

  # 7. UI: Attach the "Accept Collab" Button
  view = Discordrb::Components::View.new do |v|
    v.row { |r| r.button(custom_id: collab_id, label: 'Accept Collab', style: :success, emoji: '🤝') }
  end

  # 8. Messaging: Handle Slash vs. Prefix response logic
  if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
    event.respond(content: "Starting collab request...", ephemeral: true)
    msg = event.channel.send_message(nil, false, embed, nil, nil, nil, view)
  else
    msg = event.channel.send_message(nil, false, embed, nil, nil, event.message, view)
  end

  # 9. Threading: Start a background timer for the 3-minute expiration
  Thread.new do
    sleep 180
    
    # 10. Cleanup: If the collab was never accepted, delete it and update the UI
    if ACTIVE_COLLABS.key?(collab_id)
      ACTIVE_COLLABS.delete(collab_id)
      
      failed_embed = Discordrb::Webhooks::Embed.new(
        title: "#{EMOJIS['x_']} Collab Cancelled", 
        description: "Nobody was available to collab with #{event.user.mention} this time #{EMOJIS['confused']}...", 
        color: 0x808080 # Neutral Gray
      )
      
      # Edit message to remove the button so no one can click it late
      msg.edit(nil, failed_embed, Discordrb::Components::View.new) if msg
    end
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!collab)
# ------------------------------------------
bot.command(:collab, 
  description: 'Ask the server to do a collab stream! (30m cooldown)', 
  category: 'Economy'
) do |event|
  execute_collab(event)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/collab)
# ------------------------------------------
bot.application_command(:collab) do |event|
  execute_collab(event)
end