# ==========================================
# INTERACTION: Trivia Answer Buttons
# DESCRIPTION: Handles trivia A/B/C/D answer clicks.
# ==========================================

$bot.button(custom_id: /^trivia_[ABCD]_\d+$/) do |event|
  parts = event.custom_id.split('_')
  answer = parts[1]
  owner_id = parts[2]
  puts "[TRIVIA CLICK] custom_id=#{event.custom_id.inspect} clicker_uid=#{event.user.id.inspect} owner_id=#{owner_id.inspect}"

  # Only the question owner can answer
  if event.user.id.to_s != owner_id
    event.respond(content: "This isn't your trivia question! Use `#{PREFIX}trivia` to start your own.", ephemeral: true)
    next
  end

  uid = event.user.id
  trivia = DB.get_trivia_session(uid)

  unless trivia
    puts "[TRIVIA CLICK] no session found for uid=#{uid.inspect}"
    event.respond(content: "This trivia has expired! Run `#{PREFIX}trivia` for a fresh one.", ephemeral: true)
    next
  end

  if trivia[:answered]
    event.respond(content: "You already answered this question!", ephemeral: true)
    next
  end

  # Check time limit
  elapsed = Time.now - trivia[:asked_at]
  if elapsed > TRIVIA_TIME_LIMIT
    DB.mark_trivia_answered(uid)

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

  DB.mark_trivia_answered(uid)

  if answer == trivia[:correct]
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
