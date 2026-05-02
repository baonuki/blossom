# ==========================================
# COMMAND: trivia
# DESCRIPTION: VTuber-themed trivia questions for coins.
# CATEGORY: Arcade
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

  # Generate question
  trivia = generate_trivia_question
  reward = is_sub ? rand(TRIVIA_PREMIUM_RANGE) : rand(TRIVIA_REWARD_RANGE)

  # Find correct answer index
  correct_idx = trivia[:options].index(trivia[:correct]) || 0
  correct_label = TRIVIA_LABELS[correct_idx]

  # Persist the active trivia so any worker / restart can resolve the click
  DB.save_trivia_session(uid, correct_label, trivia[:correct], trivia[:options], reward)

  # Build answer buttons
  buttons = trivia[:options].each_with_index.map do |opt, i|
    { type: 2, style: 1, label: "#{TRIVIA_LABELS[i]}: #{opt}", custom_id: "trivia_#{TRIVIA_LABELS[i]}_#{uid}" }
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
