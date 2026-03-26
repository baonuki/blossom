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
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['error']} Interaction Error" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Mention someone to hug!" }
    ]}])
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
    check_achievement(event.channel, uid, 'hug_sent_100') if stats['sent'].to_i >= 100

    target_stats = DB.get_interactions(target_id)['hug']
    check_achievement(event.channel, target_id, 'hug_rec_10') if target_stats['received'].to_i >= 10
    check_achievement(event.channel, target_id, 'hug_rec_50') if target_stats['received'].to_i >= 50
    check_achievement(event.channel, target_id, 'hug_rec_100') if target_stats['received'].to_i >= 100

    # --- STEP C: Fetch Final Stats for UI ---
    actor_stats = DB.get_interactions(event.user.id)['hug']
    bot_stats   = DB.get_interactions(target.id)['hug']

    # --- STEP D: Send Special "Response" CV2 Message ---
    send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
      { type: 10, content: "## 🫂 Hugs for Blossom!" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Aww, thanks for the love, #{event.user.mention}! Chat's been crazy today, I needed that.\n\n*Blossom hugs you back tightly!*" },
      { type: 14, spacing: 1 },
      { type: 10, content: "**#{event.user.name}'s Hugs:** Sent: **#{actor_stats['sent']}** | Received: **#{actor_stats['received']}**" },
      { type: 10, content: "**Blossom's Hugs:** Sent: **#{bot_stats['sent']}** | Received: **#{bot_stats['received']}**" },
      { type: 14, spacing: 1 },
      { type: 12, items: [{ media: { url: HUG_GIFS.sample } }] }
    ]}])
  else
    # 3. Standard Interaction: Use the global interaction helper for other users
    interaction_embed(event, 'hug', HUG_GIFS, target)
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!hug)
# ------------------------------------------
$bot.command(:hug, 
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
$bot.application_command(:hug) do |event|
  # Fetch target user from the Slash option 'user'
  target_id = event.options['user']
  target = event.bot.user(target_id.to_i) if target_id
  
  execute_hug(event, target)
end