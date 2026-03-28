# ==========================================
# COMMAND: rep
# DESCRIPTION: Give reputation to another user. Free: 1/day, Premium: 3/day.
# CATEGORY: Fun
# ==========================================

# ------------------------------------------
# LOGIC: Reputation Execution
# ------------------------------------------
def execute_rep(event, target_user)
  uid = event.user.id
  target_id = target_user.id
  is_sub = is_premium?(event.bot, uid)
  max_reps = is_sub ? 3 : 1

  # Can't rep yourself, chat
  if uid == target_id
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Reputation" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You can't rep yourself, that's just sad. Go make friends." }
    ]}])
  end

  # Can't rep bots
  if target_user.bot_account?
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Reputation" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You can't rep a bot. I mean, I'm flattered if you tried to rep me, but no." }
    ]}])
  end

  # Check daily rep limit
  reps_used = DB.reps_given_today(uid)
  if reps_used >= max_reps
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Reputation" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You've used all **#{max_reps}** of your daily reps already.#{is_sub ? '' : "\n*Premium users get **3** reps per day!*"}" }
    ]}])
  end

  # Check if already repped this specific user today
  unless DB.can_rep?(uid, target_id)
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Reputation" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You already repped **#{target_user.display_name}** today. Spread the love around, bestie." }
    ]}])
  end

  # Give the rep!
  DB.add_reputation(target_id)
  DB.set_rep_cooldown(uid, target_id)
  new_rep = DB.get_reputation(target_id)
  reps_remaining = max_reps - (reps_used + 1)

  send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: [
    { type: 10, content: "## #{EMOJI_STRINGS['rainbowheart']} Reputation" },
    { type: 14, spacing: 1 },
    { type: 10, content: "You gave **+1 rep** to **#{target_user.display_name}**! #{EMOJI_STRINGS['thumbsup']}\nThey now have **#{new_rep}** reputation.\n\n*You have **#{reps_remaining}** rep#{'s' unless reps_remaining == 1} left today.*" }
  ]}])
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!rep)
# ------------------------------------------
$bot.command(:rep,
  description: 'Give reputation to a user!',
  category: 'Fun'
) do |event|
  target = event.message.mentions.first
  unless target
    send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Reputation" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You gotta mention someone! `#{PREFIX}rep @user`" }
    ]}])
    next
  end
  execute_rep(event, target)
  nil
end

# ------------------------------------------
# TRIGGER: Slash Command (/rep)
# ------------------------------------------
$bot.application_command(:rep) do |event|
  target_id = event.options['user']
  unless target_id
    next event.respond(content: "#{EMOJI_STRINGS['x_']} You gotta pick someone to rep!", ephemeral: true)
  end
  target = event.bot.user(target_id.to_i)
  execute_rep(event, target)
end
