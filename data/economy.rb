# ==========================================
# DATA: Economy & Shop Configuration
# DESCRIPTION: Cooldowns, rewards, and item prices.
# ==========================================

# --- REWARDS & COOLDOWNS ---
DAILY_REWARD        = 350
DAILY_STREAK_BONUS  = 30
DAILY_COOLDOWN      = 24 * 60 * 60

WORK_REWARD_RANGE = (35..75)
WORK_COOLDOWN     = 60 * 10

STREAM_REWARD_RANGE = (75..150)
STREAM_COOLDOWN     = 30 * 60
STREAM_GAMES = ['Minecraft', 'Valorant', 'Just Chatting', 'Apex Legends', 'Lethal Company', 'Elden Ring', 'Genshin Impact', 'Phasmophobia', 'Overwatch 2', 'VRChat'].freeze

POST_REWARD_RANGE = (15..35)
POST_COOLDOWN     = 5 * 60
POST_PLATFORMS    = ['Twitter/X', 'TikTok', 'Instagram', 'YouTube Shorts', 'Bluesky', 'Threads', 'Reddit'].freeze

COLLAB_REWARD   = 150
COLLAB_COOLDOWN = 30 * 60
COLLAB_WINDOW         = 180  # 3 minutes for free users
COLLAB_WINDOW_PREMIUM = 300  # 5 minutes for premium users

FISH_COOLDOWN         = 5 * 60  # 5 minutes
FISH_COOLDOWN_PREMIUM = (2.5 * 60).to_i  # 2.5 minutes for premium

TRADE_WINDOW         = 120  # 2 minutes for free users
TRADE_WINDOW_PREMIUM = 600  # 10 minutes for premium users

# --- GACHA & SHOP ---
SUMMON_COST = 150
PITY_THRESHOLD = 30

SHOP_PRICES = { 'common' => 1_000, 'rare' => 5_000, 'legendary' => 25_000 }.freeze
GODDESS_PRISMA_PRICE = 100
CUSTOM_BANNER_COST = 20
SELL_PRICES = { 'common' => 50, 'rare' => 250, 'legendary' => 1_000, 'goddess' => 5_000 }.freeze
SELL_UNDO_WINDOW = 5 * 60 # 5 minutes for premium undo

# --- DAILY CALENDAR MILESTONES ---
CALENDAR_MILESTONE_14       = 14
CALENDAR_MILESTONE_28       = 28
CALENDAR_MILESTONE_14_REWARD = 1_000
CALENDAR_MILESTONE_28_REWARD = 5_000
CALENDAR_MILESTONE_14_PREMIUM = 2_000
CALENDAR_MILESTONE_28_PREMIUM = 10_000
CALENDAR_MILESTONE_28_PRISMA  = 10

# --- PASSIVE INCOME (Premium) ---
INVEST_MIN            = 1_000
INVEST_RATE_PER_HOUR  = 0.005   # 0.5% per hour
INVEST_PROFIT_CAP     = 1.0     # 100% max profit (2x principal)

# --- HAPPY HOUR ---
HAPPY_HOUR_CHANCE     = 10      # % chance per hour to trigger
HAPPY_HOUR_DURATION   = 30 * 60 # 30 minutes
HAPPY_HOUR_MULTIPLIER = 2       # 2x for free, 3x for premium

# Global mutable state for active happy hour
$happy_hour = nil # { multiplier: 2, ends_at: Time }

# --- TRIVIA ---
TRIVIA_COOLDOWN         = 2 * 60  # 2 minutes
TRIVIA_REWARD_RANGE     = (50..100)
TRIVIA_PREMIUM_RANGE    = (100..200)
TRIVIA_TIME_LIMIT       = 15  # seconds to answer

# --- HEIST ---
HEIST_MIN_PLAYERS       = 3
HEIST_JOIN_WINDOW       = 5 * 60  # 5 minutes to join
HEIST_BASE_CHANCE       = 30      # 30% base success
HEIST_PER_PLAYER        = 5       # +5% per player
HEIST_PREMIUM_BONUS     = 3       # +3% per premium player
HEIST_MAX_CHANCE         = 85      # 85% cap
HEIST_BASE_VAULT        = 2000    # base vault coins
HEIST_PER_PLAYER_VAULT  = 500     # extra per player

# --- BOSS BATTLES ---
BOSS_HP                 = 100_000
BOSS_DAMAGE_RANGE       = (50..200)
BOSS_DAMAGE_PREMIUM     = (100..400)
BOSS_ATTACK_COOLDOWN    = 60 * 60  # 1 hour between attacks
BOSS_DEFEAT_PRISMA      = 50       # Prisma reward on defeat
BOSS_NAMES = [
  "Glitch Hydra",
  "The Lag Beast",
  "Corrupted Firewall",
  "Neon Phantom",
  "Data Leviathan",
  "Pixel Wyrm",
  "Void Sentinel",
  "Static Colossus",
  "Binary Behemoth",
  "The Buffering Horror",
  "Malware Titan",
  "Desync Demon"
].freeze

# --- SPAM DETECTION ---
SPAM_MESSAGE_LIMIT = 5     # messages within window
SPAM_TIME_WINDOW   = 5     # seconds
SPAM_MUTE_DURATION = 60    # 1 minute timeout

# --- CREWS ---
CREW_CREATE_COST    = 5_000
CREW_MAX_MEMBERS    = 15
CREW_XP_PER_LEVEL   = 1_000
CREW_COIN_BONUS     = 0.05  # +5% coins for crew members

# --- FRIENDSHIP ---
AFFINITY_COLLAB  = 5
AFFINITY_TRADE   = 3
AFFINITY_GIFT    = 5
AFFINITY_HUG     = 1
AFFINITY_PAT     = 1
AFFINITY_SLAP    = 1

FRIENDSHIP_TIERS = {
  0   => { name: 'Stranger',     bonus: 0 },
  10  => { name: 'Acquaintance', bonus: 0 },
  25  => { name: 'Friend',       bonus: 0.05 },
  50  => { name: 'Close Friend', bonus: 0.10 },
  100 => { name: 'Best Friend',  bonus: 0.15 }
}.freeze

BLACK_MARKET_ITEMS = {
  'headset'         => { name: '🎧 Cheap Headset',           price: 500,   type: 'upgrade',    desc: 'Better audio! Grants +25% to !post payouts.' },
  'keyboard'        => { name: '⌨️ RGB Keyboard',            price: 2000,  type: 'upgrade',    desc: 'Type at the speed of light! Grants +25% to !work payouts.' },
  'mic'             => { name: '🎙️ Studio Mic',               price: 10000, type: 'upgrade',    desc: 'Professional audio! Grants +10% to !stream payouts.' },
  'neon sign'       => { name: '✨ Holographic Neon Sign',  price: 25000, type: 'upgrade',    desc: 'Attracts massive attention! Doubles your !daily reward (x2).' },
  'gacha pass'      => { name: '🎟️ Gacha Pass',              price: 15000, type: 'upgrade',    desc: 'Permanently cuts your summon cooldown in half!' },
  'stamina pill'    => { name: "#{EMOJI_STRINGS['stamina_pill']} Stamina Pill",            price: 1500,  type: 'consumable', desc: 'Auto-consumed when you summon on cooldown. Bypasses cooldown once!' },
  'gamer fuel'      => { name: "#{EMOJI_STRINGS['gamer_fuel']} Gamer Fuel",              price: 2500,  type: 'consumable', desc: 'Auto-consumed when you use a content command on cooldown. Bypasses cooldown once!' },
  'rng manipulator' => { name: "#{EMOJI_STRINGS['rng_manipulator']} RNG Manipulator",         price: 5000,  type: 'consumable', desc: 'Guarantees your next !summon is a Rare or higher!' }
}.freeze