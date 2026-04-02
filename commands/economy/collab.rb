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
  used_fuel = false

  if last_used && (now - last_used) < COLLAB_COOLDOWN
    inv_array = DB.get_inventory(uid)
    inv = inv_array.each_with_object({}) { |item, h| h[item['item_id']] = item['quantity'] }
    if inv['gamer fuel'] && inv['gamer fuel'] > 0
      DB.remove_inventory(uid, 'gamer fuel', 1)
      used_fuel = true
      check_achievement(event.channel, uid, 'use_fuel')
    else
      remaining = COLLAB_COOLDOWN - (now - last_used)
      return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['worktired']} Collab Burnout" },
        { type: 14, spacing: 1 },
        { type: 10, content: "You're collab-spamming, chill out. Try again in **#{format_time_delta(remaining)}**." }
      ]}])
    end
  end

  # 3. Database: Update the cooldown timestamp immediately
  DB.set_cooldown(uid, 'collab', now)

  # 4. Preparation: Set expiration (premium gets extended window) and generate a unique ID
  premium = is_premium?(event.bot, uid)
  window = premium ? COLLAB_WINDOW_PREMIUM : COLLAB_WINDOW
  expire_time = Time.now + window
  discord_timestamp = "<t:#{expire_time.to_i}:R>" # Relative Discord timestamp
  collab_id = "collab_#{expire_time.to_i}_#{rand(10000)}"
  
  # 5. Tracking: Store the request in the global active collab hash
  ACTIVE_COLLABS[collab_id] = uid 

  # 6. UI: Build the invitation Embed
  embed = Discordrb::Webhooks::Embed.new(
    title: "#{EMOJI_STRINGS['stream']} Collab Request!",
    description: "#{event.user.mention} wants a collab partner! Any takers?\n\n" \
                 "Smash that button before it expires **#{discord_timestamp}**!#{mom_remark(uid, 'economy')}",
    color: NEON_COLORS.sample
  )

  # 7. UI: Attach the "Accept Collab" Button
  view = Discordrb::Components::View.new do |v|
    v.row { |r| r.button(custom_id: collab_id, label: 'Accept Collab', style: :success, emoji: '🤝') }
  end

  # 8. Messaging: Handle Slash vs. Prefix response logic
  if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
    event.respond(content: "Putting out the collab signal...", ephemeral: true)
    msg = event.channel.send_message(nil, false, embed, nil, nil, nil, view)
  else
    msg = event.channel.send_message(nil, false, embed, nil, nil, event.message, view)
  end

  # 9. Threading: Start a background timer for the collab expiration
  Thread.new do
    sleep window
    
    # 10. Cleanup: If the collab was never accepted, delete it and update the UI
    if ACTIVE_COLLABS.key?(collab_id)
      ACTIVE_COLLABS.delete(collab_id)
      
      failed_embed = Discordrb::Webhooks::Embed.new(
        title: "#{EMOJI_STRINGS['x_']} Collab Cancelled", 
        description: "No one showed up for #{event.user.mention}'s collab #{EMOJI_STRINGS['confused']}... awkward.",
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
$bot.command(:collab, aliases: [:colab],
  description: 'Ask the server to do a collab stream! (30m cooldown)', 
  category: 'Economy'
) do |event|
  execute_collab(event)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/collab)
# ------------------------------------------
$bot.application_command(:collab) do |event|
  execute_collab(event)
end