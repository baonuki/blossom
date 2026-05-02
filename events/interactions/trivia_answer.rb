# ==========================================
# INTERACTION: Trivia Answer Buttons
# DESCRIPTION: Handles trivia A/B/C/D answer clicks.
#
# IMPORTANT: This handler is intentionally DB-independent for the
# "is this click correct?" decision. Everything we need lives in the
# custom_id baked by commands/arcade/trivia.rb:
#
#     tv2_<uid>_<this_label>_<correct_label>_<reward>_<asked_epoch>
#
# The trivia_sessions DB row is *only* consulted to make the result message
# pretty (so we can show the full text of the correct answer instead of just
# the letter). If that lookup fails for any reason — table missing, row
# evicted, race with another worker, transaction visibility weirdness — we
# fall back to "(answer hidden)" in the result text rather than telling the
# user the trivia "expired". The only thing that can cause an "expired"
# message now is the asked_epoch in the custom_id actually being older than
# TRIVIA_TIME_LIMIT seconds.
# ==========================================

TRIVIA_BUTTON_REGEX = /^tv2_\d+_[ABCD]_[ABCD]_\d+_\d+$/

$bot.button(custom_id: TRIVIA_BUTTON_REGEX) do |event|
  parts = event.custom_id.split('_')
  # parts: ["tv2", uid, this_label, correct_label, reward, asked_epoch]
  owner_id      = parts[1]
  answer        = parts[2]
  correct_label = parts[3]
  reward        = parts[4].to_i
  asked_epoch   = parts[5].to_i

  # Only the question owner can answer.
  if event.user.id.to_s != owner_id
    event.respond(content: "This isn't your trivia question! Use `#{PREFIX}trivia` to start your own.", ephemeral: true)
    next
  end

  uid = event.user.id

  # Pretty display text — best effort. NEVER gate the click on whether this
  # returns a row.
  session_text = begin
    session = DB.get_trivia_session(uid)
    session && session[:correct_text].to_s.empty? == false ? session[:correct_text] : nil
  rescue StandardError
    nil
  end
  display_correct = session_text || '(answer hidden)'

  # Time-limit check — sourced from the custom_id, NOT the database.
  elapsed = Time.now.to_i - asked_epoch
  if elapsed > TRIVIA_TIME_LIMIT
    DB.mark_trivia_answered(uid) rescue nil

    update_cv2(event, [{
      type: 17, accent_color: 0xFF0000,
      components: [
        { type: 10, content: "## #{EMOJI_STRINGS['error']} Time's Up!" },
        { type: 14, spacing: 1 },
        { type: 10, content: "Too slow, chat! The correct answer was **#{correct_label}: #{display_correct}**.\n\nBetter luck next time \u{1F338}" }
      ]
    }])
    next
  end

  # Mark answered in the DB (for cooldown tracking on the next b!trivia).
  # Failure here is non-fatal — worst case the cooldown doesn't apply once.
  DB.mark_trivia_answered(uid) rescue nil

  if answer == correct_label
    final_reward = award_coins(event.bot, uid, reward)
    check_wealth_achievements(nil, uid)
    track_challenge(uid, 'trivia_correct', 1)

    update_cv2(event, [{
      type: 17, accent_color: 0x00FF00,
      components: [
        { type: 10, content: "## #{EMOJI_STRINGS['checkmark']} Correct!" },
        { type: 14, spacing: 1 },
        { type: 10, content: "**#{correct_label}: #{display_correct}** \u2014 Nice brain, chat!\n\nYou earned **#{final_reward}** #{EMOJI_STRINGS['s_coin']}! (answered in #{elapsed}s)\n\nBalance: **#{DB.get_coins(uid)}** #{EMOJI_STRINGS['s_coin']}#{mom_remark(uid, 'arcade')}" }
      ]
    }])
  else
    update_cv2(event, [{
      type: 17, accent_color: 0xFF0000,
      components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} Wrong!" },
        { type: 14, spacing: 1 },
        { type: 10, content: "You picked **#{answer}** but the correct answer was **#{correct_label}: #{display_correct}**.\n\nMassive skill issue. Study up and try again! \u{1F338}" }
      ]
    }])
  end
end
