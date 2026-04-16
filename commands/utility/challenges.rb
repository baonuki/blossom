# ==========================================
# COMMAND: challenges (weekly)
# DESCRIPTION: View and claim weekly challenge progress.
# CATEGORY: Utility
# ==========================================

def execute_challenges(event)
  uid = event.user.id
  is_sub = is_premium?(event.bot, uid)
  week_start = current_week_start

  # Get or generate this week's challenges
  challenges = DB.get_weekly_challenges(week_start)
  unless challenges
    challenges = generate_weekly_challenges
    DB.set_weekly_challenges(week_start, challenges)
  end

  # Determine how many the user sees (3 free, 4 premium)
  visible_count = is_sub ? CHALLENGES_PER_WEEK_PREMIUM : CHALLENGES_PER_WEEK
  visible = challenges.first(visible_count)

  # Get progress
  user_data = DB.get_challenge_progress(uid, week_start)
  progress = user_data['progress']
  claimed = user_data['claimed']

  # Build challenge display
  all_complete = true
  challenge_lines = visible.each_with_index.map { |c, i|
    current = progress[c['type']] || 0
    target = c['target']
    done = current >= target

    all_complete = false unless done

    status = done ? "\u2705" : "\u{1F7E1}"
    bar_pct = [current.to_f / target, 1.0].min
    filled = (bar_pct * 10).round
    bar = "\u2588" * filled + "\u2591" * (10 - filled)

    "#{status} **#{c['desc']}**\n`[#{bar}]` #{current}/#{target} \u2014 Reward: **#{c['reward']}** #{EMOJI_STRINGS['s_coin']}"
  }.join("\n\n")

  # Bonus section
  bonus_text = if all_complete && !claimed
    "\n\n\u{1F381} **ALL COMPLETE!** Claim your bonus below!"
  elsif all_complete && claimed
    "\n\n\u2705 **Bonus claimed!** See you next week."
  else
    "\n\n\u{1F381} Complete all #{visible_count} for a bonus: **#{CHALLENGE_COMPLETE_BONUS_COINS}** #{EMOJI_STRINGS['s_coin']} + **#{CHALLENGE_COMPLETE_BONUS_PRISMA}** #{EMOJI_STRINGS['prisma']}"
  end

  # Premium upsell if they're missing the 4th challenge
  premium_note = ""
  if !is_sub && challenges.size > CHALLENGES_PER_WEEK
    premium_note = "\n\n*#{EMOJI_STRINGS['prisma']} Premium users get a 4th challenge!*"
  end

  # Week info
  week_end = week_start + 6
  week_text = "**Week:** #{week_start.strftime('%b %d')} \u2014 #{week_end.strftime('%b %d')}"

  components_inner = [
    { type: 10, content: "## \u{1F3AF} Weekly Challenges" },
    { type: 14, spacing: 1 },
    { type: 10, content: "#{week_text}\n\n#{challenge_lines}#{bonus_text}#{premium_note}#{mom_remark(uid, 'general')}" }
  ]

  # Add claim button if all complete and not yet claimed
  if all_complete && !claimed
    components_inner << { type: 14, spacing: 1 }
    components_inner << { type: 1, components: [
      { type: 2, style: 3, label: "\u{1F381} Claim Bonus!", custom_id: "challenge_claim_#{uid}" }
    ]}
  end

  send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: components_inner }])
end

# ------------------------------------------
# CLAIM BUTTON HANDLER
# ------------------------------------------
$bot.button(custom_id: /^challenge_claim_\d+$/) do |event|
  owner_id = event.custom_id.split('_').last
  if event.user.id.to_s != owner_id
    event.respond(content: "These aren't your challenges!", ephemeral: true)
    next
  end

  uid = event.user.id
  week_start = current_week_start
  user_data = DB.get_challenge_progress(uid, week_start)

  if user_data['claimed']
    event.respond(content: "You already claimed this week's bonus!", ephemeral: true)
    next
  end

  # Verify all are actually complete
  challenges = DB.get_weekly_challenges(week_start)
  is_sub = is_premium?(event.bot, uid)
  visible_count = is_sub ? CHALLENGES_PER_WEEK_PREMIUM : CHALLENGES_PER_WEEK
  visible = challenges.first(visible_count)
  progress = user_data['progress']

  all_done = visible.all? { |c| (progress[c['type']] || 0) >= c['target'] }
  unless all_done
    event.respond(content: "Not all challenges are complete yet!", ephemeral: true)
    next
  end

  # Grant individual challenge rewards
  total_reward = 0
  visible.each do |c|
    total_reward += c['reward']
  end
  award_coins(event.bot, uid, total_reward)

  # Grant completion bonus
  DB.add_coins(uid, CHALLENGE_COMPLETE_BONUS_COINS)
  DB.add_prisma(uid, CHALLENGE_COMPLETE_BONUS_PRISMA)
  DB.mark_challenges_claimed(uid, week_start)

  grand_total = total_reward + CHALLENGE_COMPLETE_BONUS_COINS

  update_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: [
    { type: 10, content: "## \u{1F389} Weekly Challenges Complete!" },
    { type: 14, spacing: 1 },
    { type: 10, content: "**Challenge Rewards:** #{total_reward} #{EMOJI_STRINGS['s_coin']}\n**Completion Bonus:** #{CHALLENGE_COMPLETE_BONUS_COINS} #{EMOJI_STRINGS['s_coin']} + #{CHALLENGE_COMPLETE_BONUS_PRISMA} #{EMOJI_STRINGS['prisma']}\n\n**Total:** #{grand_total} #{EMOJI_STRINGS['s_coin']} + #{CHALLENGE_COMPLETE_BONUS_PRISMA} #{EMOJI_STRINGS['prisma']}\n\nSee you next week, chat! \u{1F338}" }
  ]}])
end

# ------------------------------------------
# TRIGGERS
# ------------------------------------------
$bot.command(:challenges, aliases: [:weekly, :challenge],
  description: 'View your weekly challenges',
  category: 'Utility'
) do |event|
  execute_challenges(event)
  nil
end

$bot.application_command(:challenges) do |event|
  execute_challenges(event)
end
