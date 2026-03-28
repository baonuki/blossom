# ==========================================
# EVENT: Blackjack Button Handlers
# DESCRIPTION: Handles Hit, Stand, and Double Down
# button interactions for active blackjack games.
# ==========================================

# --- HIT ---
$bot.button(custom_id: /^bj_hit_/) do |event|
  uid = event.custom_id.split('_').last.to_i

  if event.user.id != uid
    next event.respond(content: "#{EMOJI_STRINGS['x_']} That's not your hand, chat.", ephemeral: true)
  end

  session = ACTIVE_BLACKJACK["bj_#{uid}"]
  unless session
    next event.respond(content: "#{EMOJI_STRINGS['x_']} No active game found. Start a new one!", ephemeral: true)
  end

  # Draw a card
  session[:player] << session[:deck].pop
  player_total = bj_hand_total(session[:player])

  if player_total > 21
    # BUST
    bj_resolve_button(event, uid, session, :bust)
  elsif player_total == 21
    # Auto-stand on 21
    bj_dealer_play(session)
    outcome = bj_determine_outcome(session)
    bj_resolve_button(event, uid, session, outcome)
  else
    # Show updated table
    bj_update_table(event, uid, session)
  end
end

# --- STAND ---
$bot.button(custom_id: /^bj_stand_/) do |event|
  uid = event.custom_id.split('_').last.to_i

  if event.user.id != uid
    next event.respond(content: "#{EMOJI_STRINGS['x_']} That's not your hand, chat.", ephemeral: true)
  end

  session = ACTIVE_BLACKJACK["bj_#{uid}"]
  unless session
    next event.respond(content: "#{EMOJI_STRINGS['x_']} No active game found. Start a new one!", ephemeral: true)
  end

  bj_dealer_play(session)
  outcome = bj_determine_outcome(session)
  bj_resolve_button(event, uid, session, outcome)
end

# --- DOUBLE DOWN ---
$bot.button(custom_id: /^bj_double_/) do |event|
  uid = event.custom_id.split('_').last.to_i

  if event.user.id != uid
    next event.respond(content: "#{EMOJI_STRINGS['x_']} That's not your hand, chat.", ephemeral: true)
  end

  session = ACTIVE_BLACKJACK["bj_#{uid}"]
  unless session
    next event.respond(content: "#{EMOJI_STRINGS['x_']} No active game found. Start a new one!", ephemeral: true)
  end

  # Double the bet, draw exactly one card, then stand
  if DB.get_coins(uid) < session[:bet]
    next event.respond(content: "#{EMOJI_STRINGS['nervous']} You can't afford to double down anymore!", ephemeral: true)
  end

  DB.add_coins(uid, -session[:bet])
  session[:bet] *= 2
  session[:doubled] = true
  session[:player] << session[:deck].pop

  player_total = bj_hand_total(session[:player])

  if player_total > 21
    bj_resolve_button(event, uid, session, :bust)
  else
    bj_dealer_play(session)
    outcome = bj_determine_outcome(session)
    bj_resolve_button(event, uid, session, outcome)
  end
end

# --- HELPER: Update table via button interaction ---
def bj_update_table(event, uid, session)
  player_total = bj_hand_total(session[:player])

  # No double down after first hit
  buttons = [
    { type: 2, style: 1, label: "Hit", custom_id: "bj_hit_#{uid}", emoji: { name: '🃏' } },
    { type: 2, style: 3, label: "Stand", custom_id: "bj_stand_#{uid}", emoji: { name: '✋' } }
  ]

  event.update_message(
    content: '', flags: CV2_FLAG,
    components: [{ type: 17, accent_color: NEON_COLORS.sample, components: [
      { type: 10, content: "## 🃏 Blackjack — Bet: #{session[:bet]} #{EMOJI_STRINGS['s_coin']}" },
      { type: 14, spacing: 1 },
      { type: 10, content: "**Blossom's Hand:** #{bj_display_hand(session[:dealer], hide_second: true)} (#{bj_display_total(session[:dealer], hide_second: true)})" },
      { type: 10, content: "**Your Hand:** #{bj_display_hand(session[:player])} (**#{player_total}**)" },
      { type: 14, spacing: 1 },
      { type: 1, components: buttons }
    ]}]
  )
end

# --- HELPER: Resolve game via button interaction ---
def bj_resolve_button(event, uid, session, outcome)
  ACTIVE_BLACKJACK.delete("bj_#{uid}")

  player_total = bj_hand_total(session[:player])
  dealer_total = bj_hand_total(session[:dealer])
  bet = session[:bet]

  table_display = "**Blossom's Hand:** #{bj_display_hand(session[:dealer])} (**#{dealer_total}**)\n" \
                  "**Your Hand:** #{bj_display_hand(session[:player])} (**#{player_total}**)"

  doubled_note = session[:doubled] ? "\n*(Double Down — #{bet} #{EMOJI_STRINGS['s_coin']} on the line!)*" : ""

  case outcome
  when :win
    base_winnings = bet * 2
    payout_result = arcade_payout(event.bot, uid, base_winnings)
    DB.add_coins(uid, payout_result[:winnings])
    extras = arcade_win_extras(uid, payout_result)

    inner = [
      { type: 10, content: "## 🃏 Blackjack — **YOU WIN!**" },
      { type: 14, spacing: 1 },
      { type: 10, content: "#{table_display}#{doubled_note}\n\nGG, you beat the dealer! **#{payout_result[:winnings]}** #{EMOJI_STRINGS['s_coin']} yours.#{extras[:text]}\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJI_STRINGS['s_coin']}#{mom_remark(uid, 'arcade')}" }
    ]
    inner << extras[:button] if extras[:button]
    event.update_message(content: '', flags: CV2_FLAG, components: [{ type: 17, accent_color: 0x00FF00, components: inner }])

  when :push
    DB.add_coins(uid, bet)
    event.update_message(
      content: '', flags: CV2_FLAG,
      components: [{ type: 17, accent_color: 0xFFFF00, components: [
        { type: 10, content: "## 🃏 Blackjack — **PUSH**" },
        { type: 14, spacing: 1 },
        { type: 10, content: "#{table_display}#{doubled_note}\n\nWe tied?? Boring. Take your **#{bet}** #{EMOJI_STRINGS['s_coin']} back.\nBalance: **#{DB.get_coins(uid)}** #{EMOJI_STRINGS['s_coin']}" }
      ]}]
    )

  when :bust
    check_achievement(event.channel, uid, 'gamble_broke') if bet >= 5000
    event.update_message(
      content: '', flags: CV2_FLAG,
      components: [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## 🃏 Blackjack — **BUST!**" },
        { type: 14, spacing: 1 },
        { type: 10, content: "#{table_display}#{doubled_note}\n\nOver 21, LMAOOO. **#{bet}** #{EMOJI_STRINGS['s_coin']} gone. Greedy much?\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJI_STRINGS['s_coin']}#{mom_remark(uid, 'arcade')}" }
      ]}]
    )

  when :lose
    check_achievement(event.channel, uid, 'gamble_broke') if bet >= 5000
    event.update_message(
      content: '', flags: CV2_FLAG,
      components: [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## 🃏 Blackjack — **YOU LOSE**" },
        { type: 14, spacing: 1 },
        { type: 10, content: "#{table_display}#{doubled_note}\n\nDealer wins~ **#{bet}** #{EMOJI_STRINGS['s_coin']} is mine now. Better luck next time, chat.\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJI_STRINGS['s_coin']}#{mom_remark(uid, 'arcade')}" }
      ]}]
    )
  end
end
