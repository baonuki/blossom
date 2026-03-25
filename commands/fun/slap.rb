# ==========================================
# COMMAND: slap
# DESCRIPTION: Send a playful slap to a user with a random GIF and track stats.
# CATEGORY: Social / Interaction
# ==========================================

# ------------------------------------------
# LOGIC: Slap Execution
# ------------------------------------------
def execute_slap(event, target)
  # 1. Validation: Ensure a target was actually mentioned
  if target.nil?
    return send_embed(event, 
      title: "#{EMOJIS['error']} Interaction Error", 
      description: "Mention someone to slap!"
    )
  end

  # 2. Branching: Handle the "Slapping Blossom" special case
  if target.id == event.bot.profile.id
    # --- STEP A: Update Database Stats ---
    # Log 'sent' for the user and 'received' for Blossom (she slaps back!)
    DB.add_interaction(event.user.id, 'slap', 'sent')
    DB.add_interaction(target.id, 'slap', 'received')
    DB.add_interaction(target.id, 'slap', 'sent')
    DB.add_interaction(event.user.id, 'slap', 'received')

    uid = event.user.id
    target_id = target.id

    # --- STEP B: Achievement Progression ---
    # Check milestones for the user sending the slap
    check_achievement(event.channel, uid, 'first_slap')
    stats = DB.get_interactions(uid)['slap']
    check_achievement(event.channel, uid, 'slap_sent_10') if stats['sent'].to_i >= 10
    check_achievement(event.channel, uid, 'slap_sent_50') if stats['sent'].to_i >= 50

    # Check milestones for the bot (Blossom) receiving the slap
    target_stats = DB.get_interactions(target_id)['slap']
    check_achievement(event.channel, target_id, 'slap_rec_10') if target_stats['received'].to_i >= 10
    check_achievement(event.channel, target_id, 'slap_rec_50') if target_stats['received'].to_i >= 50

    # --- STEP C: Fetch Final Stats for UI ---
    actor_stats = DB.get_interactions(event.user.id)['slap']
    bot_stats   = DB.get_interactions(target.id)['slap']

    # --- STEP D: Send "Bot Abuse" Response Embed ---
    send_embed(event, 
      title: "💢 Bot Abuse Detected!", 
      description: "Hey! #{event.user.mention} just slapped me?! Chat, clip that! That is literal bot abuse.\n\n*Blossom smacks you right back!*", 
      fields: [
        { name: "#{event.user.name}'s Slaps", value: "Sent: **#{actor_stats['sent']}**\nReceived: **#{actor_stats['received']}**", inline: true },
        { name: "Blossom's Slaps", value: "Sent: **#{bot_stats['sent']}**\nReceived: **#{bot_stats['received']}**", inline: true }
      ], 
      image: SLAP_GIFS.sample
    )
  else
    # 3. Standard Interaction: Use the global interaction helper for other users
    interaction_embed(event, 'slap', SLAP_GIFS, target)
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!slap)
# ------------------------------------------
bot.command(:slap, 
  description: 'Send a playful slap with a random GIF', 
  category: 'Fun'
) do |event|
  execute_slap(event, event.message.mentions.first)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/slap)
# ------------------------------------------
bot.application_command(:slap) do |event|
  target_id = event.options['user']
  target = event.bot.user(target_id.to_i) if target_id
  execute_slap(event, target)
end