# ==========================================
# COMMAND: rps
# DESCRIPTION: Challenge another user to Rock Paper Scissors with a coin bet.
# CATEGORY: Arcade
# ==========================================

RPS_CHOICES = %w[rock paper scissors].freeze
RPS_EMOJIS = { 'rock' => '🪨', 'paper' => '📄', 'scissors' => '✂️' }.freeze
RPS_WINS = { 'rock' => 'scissors', 'paper' => 'rock', 'scissors' => 'paper' }.freeze

def execute_rps(event, target, bet_str)
  uid = event.user.id

  # 1. Validation: Target
  if target.nil? || target.id == uid
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['error']} Invalid Challenge" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You can't throw hands with yourself. @ someone else.\n`#{PREFIX}rps @user <bet>`" }
    ]}])
  end

  return if target.bot_account?

  # 2. Validation: Bet
  bet = bet_str.to_i
  if bet <= 0
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['error']} Invalid Bet" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Put some coins on the line. Minimum bet is **1** #{EMOJI_STRINGS['s_coin']}.\n`#{PREFIX}rps @user 500`" }
    ]}])
  end

  # 3. Validation: Both players can afford it
  if DB.get_coins(uid) < bet
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Can't Afford It" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You don't have **#{bet}** #{EMOJI_STRINGS['s_coin']} to bet. Go grind." }
    ]}])
  end

  if DB.get_coins(target.id) < bet
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} They're Broke" },
      { type: 14, spacing: 1 },
      { type: 10, content: "#{target.mention} doesn't have **#{bet}** #{EMOJI_STRINGS['s_coin']}. Pick on someone your own size." }
    ]}])
  end

  # 4. Create the challenge
  expire_time = Time.now + 60
  rps_id = "rps_#{uid}_#{Time.now.to_i}_#{rand(10000)}"

  ACTIVE_RPS[rps_id] = {
    challenger: uid,
    opponent: target.id,
    bet: bet,
    expires: expire_time,
    choices: {}
  }

  embed = Discordrb::Webhooks::Embed.new(
    title: "✂️ Rock Paper Scissors!",
    description: "#{event.user.mention} challenges #{target.mention} to RPS for **#{bet}** #{EMOJI_STRINGS['s_coin']}!\n\n" \
                 "#{target.mention}, accept or dodge? Expires <t:#{expire_time.to_i}:R>.",
    color: NEON_COLORS.sample
  )

  view = Discordrb::Components::View.new do |v|
    v.row do |r|
      r.button(custom_id: "#{rps_id}_accept", label: 'Accept', style: :success, emoji: '✂️')
      r.button(custom_id: "#{rps_id}_decline", label: 'Decline', style: :danger, emoji: EMOJI_OBJECTS['x_'])
    end
  end

  if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
    event.respond(content: "RPS challenge sent!", ephemeral: true)
    msg = event.channel.send_message(nil, false, embed, nil, nil, nil, view)
  else
    msg = event.channel.send_message(nil, false, embed, nil, nil, event.message, view)
  end

  # Auto-expire
  Thread.new do
    sleep 60
    if ACTIVE_RPS.key?(rps_id)
      ACTIVE_RPS.delete(rps_id)
      expired_embed = Discordrb::Webhooks::Embed.new(title: '⏳ RPS Expired', description: 'Too scared to throw? Challenge expired.', color: 0x808080)
      msg.edit(nil, expired_embed, Discordrb::Components::View.new) if msg
    end
  end
end

# ------------------------------------------
# TRIGGERS
# ------------------------------------------
$bot.command(:rps, aliases: [:rockpaperscissors],
  description: 'Challenge someone to RPS with a coin bet',
  category: 'Arcade'
) do |event, mention, bet|
  execute_rps(event, event.message.mentions.first, bet)
  nil
end

$bot.application_command(:rps) do |event|
  target = event.bot.user(event.options['user'].to_i)
  execute_rps(event, target, event.options['bet'])
end
