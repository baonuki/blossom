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