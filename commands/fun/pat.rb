# ==========================================
# COMMAND: pat
# DESCRIPTION: Give someone a gentle head pat with a random GIF and track stats.
# CATEGORY: Social / Interaction
# ==========================================

# ------------------------------------------
# LOGIC: Pat Execution
# ------------------------------------------
def execute_pat(event, target)
  # 1. Validation: Ensure a target was actually mentioned
  if target.nil?
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['error']} Who Are You Patting??" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You're just... patting the air? Mention someone, chat." }
    ]}])
  end

  # 2. Branching: Handle the "Patting Blossom" special case
  if target.id == event.bot.profile.id
    DB.add_interaction(event.user.id, 'pat', 'sent')
    DB.add_interaction(target.id, 'pat', 'received')
    DB.add_interaction(target.id, 'pat', 'sent')
    DB.add_interaction(event.user.id, 'pat', 'received')

    uid = event.user.id
    track_challenge(uid, 'social_sent', 1)
    check_achievement(event.channel, uid, 'first_pat')
    stats = DB.get_interactions(uid)['pat']
    check_achievement(event.channel, uid, 'pat_sent_10') if stats['sent'].to_i >= 10
    check_achievement(event.channel, uid, 'pat_sent_50') if stats['sent'].to_i >= 50
    check_achievement(event.channel, uid, 'pat_sent_100') if stats['sent'].to_i >= 100

    actor_stats = stats
    bot_stats   = DB.get_interactions(target.id)['pat']

    send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['hearts']} Head Pats for Blossom!" },
      { type: 14, spacing: 1 },
      { type: 10, content: "#{event.user.mention} is giving me head pats?? I— okay fine, that's actually really nice. Don't tell anyone I liked it.\n\n*Blossom leans into the pats and purrs... wait no, she doesn't purr. She's not a cat. ...Maybe a little.*" },
      { type: 14, spacing: 1 },
      { type: 10, content: "**#{event.user.name}'s Pats:** Sent: **#{actor_stats['sent']}** | Received: **#{actor_stats['received']}**" },
      { type: 10, content: "**Blossom's Pats:** Sent: **#{bot_stats['sent']}** | Received: **#{bot_stats['received']}**#{mom_remark(event.user.id, 'social')}" },
      { type: 14, spacing: 1 },
      { type: 12, items: [{ media: { url: PAT_GIFS.sample } }] }
    ]}])
  else
    # 3. Standard Interaction: Use the global interaction helper for other users
    interaction_embed(event, 'pat', PAT_GIFS, target)
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!pat)
# ------------------------------------------
$bot.command(:pat, aliases: [:headpat],
  description: 'Give someone a head pat with a random GIF',
  category: 'Fun'
) do |event|
  execute_pat(event, event.message.mentions.first)
  nil
end

# ------------------------------------------
# TRIGGER: Slash Command (/pat)
# ------------------------------------------
$bot.application_command(:pat) do |event|
  target_id = event.options['user']
  target = event.bot.user(target_id.to_i) if target_id
  execute_pat(event, target)
end
