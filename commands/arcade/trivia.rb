# ==========================================
# COMMAND: trivia
# DESCRIPTION: VTuber-themed trivia questions for coins.
# CATEGORY: Arcade
#
# State model:
#   The button custom_id is the SOURCE OF TRUTH for the answer state. We bake
#   the user id, this option's label, the correct label, the reward, and the
#   asked-at epoch directly into the custom_id. That means the click handler
#   never has to consult the database to decide whether a click is correct or
#   when the question expires — eliminating the entire "expired" failure mode
#   caused by missing/stale DB rows.
#
#   The trivia_sessions DB row is kept around for two things only:
#     1. Per-user cooldown tracking (Was your last trivia answered recently?)
#     2. Pretty display text on the result screen (the full correct-answer
#        text so we can show "B: Hololive" instead of just "B"). If the row
#        is missing for any reason, the click handler degrades gracefully
#        instead of telling the user it expired.
# ==========================================

TRIVIA_LABELS = %w[A B C D].freeze

def execute_trivia(event)
  uid = event.user.id
  is_sub = is_premium?(event.bot, uid)

  # Cooldown check (persistent, so it survives restarts)
  last_trivia = DB.get_trivia_session(uid)
  if last_trivia && last_trivia[:answered] && (Time.now - last_trivia[:asked_at]) < TRIVIA_COOLDOWN
    remaining = TRIVIA_COOLDOWN - (Time.now - last_trivia[:asked_at])
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['confuse']} Trivia Cooldown" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Brain still recovering from the last question? Come back in **#{format_time_delta(remaining)}**." }
    ]}])
  end

  trivia = generate_trivia_question
  reward = is_sub ? rand(TRIVIA_PREMIUM_RANGE) : rand(TRIVIA_REWARD_RANGE)

  correct_idx = trivia[:options].index(trivia[:correct]) || 0
  correct_label = TRIVIA_LABELS[correct_idx]
  asked_epoch = Time.now.to_i

  # Best-effort DB save for cooldown + display text. The buttons remain fully
  # playable even if this fails, because the answer state lives in the
  # custom_id (see comment in events/interactions/trivia_answer.rb).
  DB.save_trivia_session(uid, correct_label, trivia[:correct], trivia[:options], reward)

  # Stateless buttons: every piece of info needed to resolve a click lives in
  # the custom_id itself. Format: tv2_<uid>_<this_label>_<correct>_<reward>_<epoch>
  buttons = trivia[:options].each_with_index.map do |opt, i|
    label = TRIVIA_LABELS[i]
    {
      type: 2, style: 1,
      label: "#{label}: #{opt}",
      custom_id: "tv2_#{uid}_#{label}_#{correct_label}_#{reward}_#{asked_epoch}"
    }
  end

  components = [{
    type: 17, accent_color: NEON_COLORS.sample,
    components: [
      { type: 10, content: "## #{EMOJI_STRINGS['info']} VTuber Trivia" },
      { type: 14, spacing: 1 },
      { type: 10, content: "#{trivia[:question]}\n\nYou have **#{TRIVIA_TIME_LIMIT} seconds** to answer! Prize: **#{reward}** #{EMOJI_STRINGS['s_coin']}" },
      { type: 14, spacing: 1 },
      { type: 1, components: buttons }
    ]
  }]
  send_cv2(event, components)
end

# ------------------------------------------
# TRIGGERS
# ------------------------------------------
$bot.command(:trivia,
  description: 'Answer VTuber trivia for coins!',
  category: 'Arcade'
) do |event|
  execute_trivia(event)
  nil
end

$bot.application_command(:trivia) do |event|
  execute_trivia(event)
end
