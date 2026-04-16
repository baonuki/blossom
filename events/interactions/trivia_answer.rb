# ==========================================
# INTERACTION: Trivia Answer Buttons
# DESCRIPTION: Handles trivia A/B/C/D answer clicks.
# ==========================================

$bot.button(custom_id: /^trivia_[ABCD]_\d+$/) do |event|
  parts = event.custom_id.split('_')
  answer = parts[1]
  owner_id = parts[2]

  # Only the question owner can answer
  if event.user.id.to_s != owner_id
    event.respond(content: "This isn't your trivia question! Use `#{PREFIX}trivia` to start your own.", ephemeral: true)
    next
  end

  uid = event.user.id
  trivia = ACTIVE_TRIVIA[uid]

  unless trivia
    event.respond(content: "This trivia has expired!", ephemeral: true)
    next
  end

  if trivia[:answered]
    event.respond(content: "You already answered this question!", ephemeral: true)
    next
  end

  # Check time limit
  elapsed = Time.now - trivia[:asked_at]
  if elapsed > TRIVIA_TIME_LIMIT
    ACTIVE_TRIVIA[uid][:answered] = true
    ACTIVE_TRIVIA[uid][:asked_at] = Time.now # Reset for cooldown

    update_cv2(event, [{
      type: 17, accent_color: 0xFF0000,
      components: [
        { type: 10, content: "## #{EMOJI_STRINGS['error']} Time's Up!" },
        { type: 14, spacing: 1 },
        { type: 10, content: "Too slow, chat! The correct answer was **#{trivia[:correct]}: #{trivia[:correct_text]}**.\n\nBetter luck next time \u{1F338}" }
      ]
    }])
    next
  end

  ACTIVE_TRIVIA[uid][:answered] = true
  ACTIVE_TRIVIA[uid][:asked_at] = Time.now # Reset for cooldown

  if answer == trivia[:correct]
    # Correct!
    final_reward = award_coins(event.bot, uid, trivia[:reward])
    check_wealth_achievements(nil, uid)
    track_challenge(uid, 'trivia_correct', 1)

    update_cv2(event, [{
      type: 17, accent_color: 0x00FF00,
      components: [
        { type: 10, content: "## #{EMOJI_STRINGS['checkmark']} Correct!" },
        { type: 14, spacing: 1 },
        { type: 10, content: "**#{trivia[:correct]}: #{trivia[:correct_text]}** \u2014 Nice brain, chat!\n\nYou earned **#{final_reward}** #{EMOJI_STRINGS['s_coin']}! (answered in #{elapsed.round(1)}s)\n\nBalance: **#{DB.get_coins(uid)}** #{EMOJI_STRINGS['s_coin']}#{mom_remark(uid, 'arcade')}" }
      ]
    }])
  else
    # Wrong!
    update_cv2(event, [{
      type: 17, accent_color: 0xFF0000,
      components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} Wrong!" },
        { type: 14, spacing: 1 },
        { type: 10, content: "You picked **#{answer}** but the correct answer was **#{trivia[:correct]}: #{trivia[:correct_text]}**.\n\nMassive skill issue. Study up and try again! \u{1F338}" }
      ]
    }])
  end
end
