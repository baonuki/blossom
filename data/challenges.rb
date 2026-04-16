# ==========================================
# DATA: Weekly Challenge System
# DESCRIPTION: Challenge pool, generator, and reward definitions.
# ==========================================

require 'date'

# --- CHALLENGE POOL ---
# Each entry: type (for tracking), description template, possible targets, reward range
CHALLENGE_POOL = [
  { type: 'daily_claims',     desc: "Claim your daily reward %d times",     targets: [3, 5, 7],    reward: (200..500) },
  { type: 'arcade_wins',      desc: "Win %d arcade games",                  targets: [3, 5, 10],   reward: (200..400) },
  { type: 'cards_pulled',     desc: "Pull %d cards from the gacha",         targets: [5, 10, 15],  reward: (200..500) },
  { type: 'coins_earned',     desc: "Earn %d coins from work/stream/post",  targets: [500, 1000],  reward: (200..400) },
  { type: 'coins_given',      desc: "Give %d coins to other players",       targets: [500, 1000],  reward: (200..500) },
  { type: 'trivia_correct',   desc: "Answer %d trivia questions correctly", targets: [3, 5],       reward: (150..300) },
  { type: 'boss_attacks',     desc: "Attack the boss %d times",             targets: [3, 5],       reward: (200..400) },
  { type: 'trades_completed', desc: "Complete %d card trades",              targets: [2, 3],       reward: (200..400) },
  { type: 'social_sent',      desc: "Send %d social interactions",          targets: [5, 10, 15],  reward: (100..300) },
  { type: 'cards_salvaged',   desc: "Salvage %d cards for materials",       targets: [5, 10],      reward: (150..300) },
  { type: 'cards_gifted',     desc: "Gift %d cards to other players",       targets: [2, 3, 5],    reward: (200..500) },
  { type: 'collab_completed', desc: "Complete %d collabs",                  targets: [2, 3],       reward: (200..400) }
].freeze

# Bonus for completing ALL challenges in a week
CHALLENGE_COMPLETE_BONUS_COINS  = 500
CHALLENGE_COMPLETE_BONUS_PRISMA = 5

# Number of challenges per week
CHALLENGES_PER_WEEK         = 3
CHALLENGES_PER_WEEK_PREMIUM = 4

# --- GENERATOR ---
def generate_weekly_challenges(count = CHALLENGES_PER_WEEK_PREMIUM)
  pool = CHALLENGE_POOL.shuffle
  selected = pool.first(count)

  selected.map do |template|
    target = template[:targets].sample
    reward = rand(template[:reward])
    {
      'type' => template[:type],
      'desc' => template[:desc] % target,
      'target' => target,
      'reward' => reward
    }
  end
end

# --- WEEK START HELPER ---
# Returns the Monday of the current week as a Date
def current_week_start
  today = Date.today
  today - (today.cwday - 1) # Monday = cwday 1
end
