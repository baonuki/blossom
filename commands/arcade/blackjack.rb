# ==========================================
# COMMAND: blackjack
# DESCRIPTION: Play blackjack against Blossom as dealer. Hit, stand, or double down.
# CATEGORY: Arcade
# ==========================================

# In-memory active blackjack sessions: { "bj_<uid>" => { deck:, player:, dealer:, bet:, doubled: } }
ACTIVE_BLACKJACK = {}

# Card values for blackjack
BJ_SUITS = ['♠️', '♥️', '♦️', '♣️'].freeze
BJ_RANKS = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K'].freeze

def bj_new_deck
  deck = BJ_SUITS.product(BJ_RANKS).map { |s, r| { suit: s, rank: r } }.shuffle
  deck
end

def bj_card_value(card)
  case card[:rank]
  when 'A' then 11
  when 'K', 'Q', 'J' then 10
  else card[:rank].to_i
  end
end

def bj_hand_total(hand)
  total = hand.sum { |c| bj_card_value(c) }
  aces = hand.count { |c| c[:rank] == 'A' }
  while total > 21 && aces > 0
    total -= 10
    aces -= 1
  end
  total
end

def bj_display_hand(hand, hide_second: false)
  if hide_second && hand.size >= 2
    "#{hand[0][:rank]}#{hand[0][:suit]}  ❓"
  else
    hand.map { |c| "#{c[:rank]}#{c[:suit]}" }.join('  ')
  end
end

def bj_display_total(hand, hide_second: false)
  if hide_second
    "?"
  else
    bj_hand_total(hand).to_s
  end
end

# ------------------------------------------
# LOGIC: Blackjack Start
# ------------------------------------------
def execute_blackjack(event, amount)
  uid = event.user.id

  # Validation
  if amount <= 0
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Invalid Bet" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You gotta bet SOMETHING to sit at my table. Minimum 1 #{EMOJI_STRINGS['s_coin']}." }
    ]}])
  end

  if DB.get_coins(uid) < amount
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['nervous']} Insufficient Funds" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You can't afford a seat at this table, bestie. You've got **#{DB.get_coins(uid)}** #{EMOJI_STRINGS['s_coin']}." }
    ]}])
  end

  if ACTIVE_BLACKJACK["bj_#{uid}"]
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Already Playing" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You already have a hand open, chat. Finish that one first!" }
    ]}])
  end

  # Deduct bet and deal
  DB.add_coins(uid, -amount)
  check_achievement(event.channel, uid, 'gamble_10k') if amount >= 10000
  deck = bj_new_deck
  player = [deck.pop, deck.pop]
  dealer = [deck.pop, deck.pop]

  session = { deck: deck, player: player, dealer: dealer, bet: amount, doubled: false }
  ACTIVE_BLACKJACK["bj_#{uid}"] = session

  player_total = bj_hand_total(player)

  # Natural blackjack check (21 on deal)
  if player_total == 21
    return bj_resolve(event, uid, session, :blackjack)
  end

  # Show the table with hit/stand/double buttons
  can_double = DB.get_coins(uid) >= amount
  bj_send_table(event, uid, session, can_double: can_double)
end

def bj_send_table(event, uid, session, can_double: false)
  player_total = bj_hand_total(session[:player])

  buttons = [
    { type: 2, style: 1, label: "Hit", custom_id: "bj_hit_#{uid}", emoji: { name: '🃏' } },
    { type: 2, style: 3, label: "Stand", custom_id: "bj_stand_#{uid}", emoji: { name: '✋' } }
  ]
  buttons << { type: 2, style: 4, label: "Double Down", custom_id: "bj_double_#{uid}", emoji: { name: '💰' } } if can_double && session[:player].size == 2

  send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
    { type: 10, content: "## 🃏 Blackjack — Bet: #{session[:bet]} #{EMOJI_STRINGS['s_coin']}" },
    { type: 14, spacing: 1 },
    { type: 10, content: "**Blossom's Hand:** #{bj_display_hand(session[:dealer], hide_second: true)} (#{bj_display_total(session[:dealer], hide_second: true)})" },
    { type: 10, content: "**Your Hand:** #{bj_display_hand(session[:player])} (**#{player_total}**)" },
    { type: 14, spacing: 1 },
    { type: 1, components: buttons }
  ]}])
end

def bj_resolve(event, uid, session, outcome)
  ACTIVE_BLACKJACK.delete("bj_#{uid}")

  player_total = bj_hand_total(session[:player])
  dealer_total = bj_hand_total(session[:dealer])
  bet = session[:bet]

  table_display = "**Blossom's Hand:** #{bj_display_hand(session[:dealer])} (**#{dealer_total}**)\n" \
                  "**Your Hand:** #{bj_display_hand(session[:player])} (**#{player_total}**)"

  case outcome
  when :blackjack
    # Natural 21 pays 2.5x (3:2 payout)
    base_winnings = (bet * 2.5).to_i
    payout_result = arcade_payout(event.bot, uid, base_winnings)
    DB.add_coins(uid, payout_result[:winnings])
    extras = arcade_win_extras(uid, payout_result)

    inner = [
      { type: 10, content: "## 🃏 Blackjack — **BLACKJACK!**" },
      { type: 14, spacing: 1 },
      { type: 10, content: "#{table_display}\n\n**NATURAL 21!!** #{EMOJI_STRINGS['neonsparkle']} Okay you're actually cracked. **#{payout_result[:winnings]}** #{EMOJI_STRINGS['s_coin']} at 3:2 payout!#{extras[:text]}\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJI_STRINGS['s_coin']}#{mom_remark(uid, 'arcade')}" }
    ]
    inner << extras[:button] if extras[:button]
    send_cv2(event, [{ type: 17, accent_color: 0xFFD700, components: inner }])

  when :win
    base_winnings = bet * 2
    payout_result = arcade_payout(event.bot, uid, base_winnings)
    DB.add_coins(uid, payout_result[:winnings])
    extras = arcade_win_extras(uid, payout_result)

    inner = [
      { type: 10, content: "## 🃏 Blackjack — **YOU WIN!**" },
      { type: 14, spacing: 1 },
      { type: 10, content: "#{table_display}\n\nGG, you beat the dealer! **#{payout_result[:winnings]}** #{EMOJI_STRINGS['s_coin']} yours.#{extras[:text]}\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJI_STRINGS['s_coin']}#{mom_remark(uid, 'arcade')}" }
    ]
    inner << extras[:button] if extras[:button]
    send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: inner }])

  when :push
    # Tie — return the bet
    DB.add_coins(uid, bet)
    send_cv2(event, [{ type: 17, accent_color: 0xFFFF00, components: [
      { type: 10, content: "## 🃏 Blackjack — **PUSH**" },
      { type: 14, spacing: 1 },
      { type: 10, content: "#{table_display}\n\nWe tied?? Boring. Take your **#{bet}** #{EMOJI_STRINGS['s_coin']} back I guess.\nBalance: **#{DB.get_coins(uid)}** #{EMOJI_STRINGS['s_coin']}" }
    ]}])

  when :bust
    check_achievement(event.channel, uid, 'gamble_broke') if bet >= 5000
    send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## 🃏 Blackjack — **BUST!**" },
      { type: 14, spacing: 1 },
      { type: 10, content: "#{table_display}\n\nYou went over 21, LMAOOO. **#{bet}** #{EMOJI_STRINGS['s_coin']} gone. Greedy much?\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJI_STRINGS['s_coin']}#{mom_remark(uid, 'arcade')}" }
    ]}])

  when :lose
    check_achievement(event.channel, uid, 'gamble_broke') if bet >= 5000
    send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## 🃏 Blackjack — **YOU LOSE**" },
      { type: 14, spacing: 1 },
      { type: 10, content: "#{table_display}\n\nDealer wins. Get rekt, chat. **#{bet}** #{EMOJI_STRINGS['s_coin']} is mine now~\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJI_STRINGS['s_coin']}#{mom_remark(uid, 'arcade')}" }
    ]}])
  end
end

# Dealer plays out their hand (hit until 17+)
def bj_dealer_play(session)
  while bj_hand_total(session[:dealer]) < 17
    session[:dealer] << session[:deck].pop
  end
end

# Determine outcome after stand
def bj_determine_outcome(session)
  player_total = bj_hand_total(session[:player])
  dealer_total = bj_hand_total(session[:dealer])

  if dealer_total > 21 || player_total > dealer_total
    :win
  elsif player_total == dealer_total
    :push
  else
    :lose
  end
end

# ------------------------------------------
# TRIGGERS: Prefix & Slash Support
# ------------------------------------------
$bot.command(:blackjack, aliases: [:blk],
  description: 'Play blackjack against Blossom!',
  category: 'Arcade'
) do |event, amount_str|
  if amount_str.nil?
    send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['confused']} Missing Arguments" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You wanna play but forgot to bet? Classic.\n\n**Usage:** `#{PREFIX}blackjack <amount>`" }
    ]}])
    next
  end
  execute_blackjack(event, amount_str.to_i)
  nil
end

$bot.application_command(:blackjack) do |event|
  execute_blackjack(event, event.options['amount'])
end
