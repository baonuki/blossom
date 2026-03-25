# ==========================================
# COMMAND: hug
# DESCRIPTION: Send a warm hug to a user with a random GIF and track stats.
# CATEGORY: Social / Interaction
# ==========================================

# ------------------------------------------
# LOGIC: Hug Execution
# ------------------------------------------
def execute_hug(event, target)
  # 1. Validation: Ensure a target was actually mentioned
  if target.nil?
    return send_embed(event, 
      title: "#{EMOJIS['error']} Interaction Error", 
      description: "Mention someone to hug!"
    )
  end

  # 2. Branching: Handle the "Hugging Blossom" special case
  if target.id == event.bot.profile.id
    # --- STEP A: Update Database Stats ---
    # We track 'sent' for the user and 'received' for the bot (and vice-versa)
    DB.add_interaction(event.user.id, 'hug', 'sent')
    DB.add_interaction(target.id, 'hug', 'received')
    DB.add_interaction(target.id, 'hug', 'sent')
    DB.add_interaction(event.user.id, 'hug', 'received')

    uid = event.user.id
    target_id = target.id 

    # --- STEP B: Achievement Progression ---
    # Check milestones for the user sending the hug
    check_achievement(event.channel, uid, 'first_hug')
    stats = DB.get_interactions(uid)['hug']
    check_achievement(event.channel, uid, 'hug_sent_10') if stats['sent'].to_i >= 10
    check_achievement(event.channel, uid, 'hug_sent_50') if stats['sent'].to_i >= 50

    # Check milestones for the bot (Blossom) receiving the hug
    target_stats = DB.get_interactions(target_id)['hug']
    check_achievement(event.channel, target_id, 'hug_rec_10') if target_stats['received'].to_i >= 10
    check_achievement(event.channel, target_id, 'hug_rec_50') if target_stats['received'].to_i >= 50

    # --- STEP C: Fetch Final Stats for UI ---
    actor_stats = DB.get_interactions(event.user.id)['hug']
    bot_stats   = DB.get_interactions(target.id)['hug']

    # --- STEP D: Send Special "Response" Embed ---
    send_embed(event, 
      title: "🫂 Hugs for Blossom!", 
      description: "Aww, thanks for the love, #{event.user.mention}! Chat's been crazy today, I needed that.\n\n*Blossom hugs you back tightly!*", 
      fields: [
        { name: "#{event.user.name}'s Hugs", value: "Sent: **#{actor_stats['sent']}**\nReceived: **#{actor_stats['received']}**", inline: true },
        { name: "Blossom's Hugs", value: "Sent: **#{bot_stats['sent']}**\nReceived: **#{bot_stats['received']}**", inline: true }
      ], 
      image: HUG_GIFS.sample
    )
  else
    # 3. Standard Interaction: Use the global interaction helper for other users
    interaction_embed(event, 'hug', HUG_GIFS, target)
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!hug)
# ------------------------------------------
bot.command(:hug, 
  description: 'Send a hug with a random GIF', 
  category: 'Fun'
) do |event|
  # Capture the first user mention from the message
  execute_hug(event, event.message.mentions.first)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/hug)
# ------------------------------------------
bot.application_command(:hug) do |event|
  # Fetch target user from the Slash option 'user'
  target_id = event.options['user']
  target = event.bot.user(target_id.to_i) if target_id
  
  execute_hug(event, target)
end