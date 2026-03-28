# ==========================================
# HELPER: Arcade Engine
# DESCRIPTION: Premium arcade perks — payout boost,
# jackpot tier, and double-or-nothing system.
# ==========================================

ARCADE_JACKPOT_CHANCE = 2     # 2% chance per win
ARCADE_JACKPOT_MULTIPLIER = 5 # 5x bonus on top of winnings

# Calculates final arcade winnings with premium perks.
# Returns { winnings:, jackpot:, premium: }
def arcade_payout(bot, uid, base_winnings)
  is_sub = is_premium?(bot, uid)
  winnings = base_winnings
  jackpot = false

  if is_sub
    # +10% payout boost
    winnings = (winnings * 1.10).to_i

    # Premium jackpot: 2% chance to 5x the boosted winnings
    if rand(100) < ARCADE_JACKPOT_CHANCE
      jackpot = true
      winnings *= ARCADE_JACKPOT_MULTIPLIER
    end
  end

  { winnings: winnings, jackpot: jackpot, premium: is_sub }
end

# Builds premium buff text and Double or Nothing button for arcade wins.
# Returns { text:, button: } where button is a CV2 action row or nil.
def arcade_win_extras(uid, result)
  text = ""
  button = nil

  if result[:premium]
    text += "\n*(#{EMOJI_STRINGS['prisma']} Premium Boost: +10%)*"
  end

  if result[:jackpot]
    text += "\n\n#{EMOJI_STRINGS['neonsparkle']} **NEON JACKPOT!!** #{EMOJI_STRINGS['neonsparkle']}\n*Your premium luck kicked in — winnings multiplied by #{ARCADE_JACKPOT_MULTIPLIER}x!!*"
  end

  if result[:premium]
    button = { type: 1, components: [
      { type: 2, style: 4, label: "Double or Nothing", custom_id: "don_#{uid}_#{result[:winnings]}", emoji: { name: '🎲' } }
    ]}
  end

  { text: text, button: button }
end
