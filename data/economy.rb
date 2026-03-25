# ==========================================
# DATA: Economy & Shop Configuration
# DESCRIPTION: Cooldowns, rewards, and item prices.
# ==========================================

# --- REWARDS & COOLDOWNS ---
DAILY_REWARD   = 500
DAILY_COOLDOWN = 24 * 60 * 60

WORK_REWARD_RANGE = (50..100)
WORK_COOLDOWN     = 60 * 10

STREAM_REWARD_RANGE = (100..200)
STREAM_COOLDOWN     = 30 * 60
STREAM_GAMES = ['Minecraft', 'Valorant', 'Just Chatting', 'Apex Legends', 'Lethal Company', 'Elden Ring', 'Genshin Impact', 'Phasmophobia', 'Overwatch 2', 'VRChat'].freeze

POST_REWARD_RANGE = (20..50)
POST_COOLDOWN     = 5 * 60
POST_PLATFORMS    = ['Twitter/X', 'TikTok', 'Instagram', 'YouTube Shorts', 'Bluesky', 'Threads', 'Reddit'].freeze

COLLAB_REWARD   = 200
COLLAB_COOLDOWN = 30 * 60

# --- GACHA & SHOP ---
SUMMON_COST = 100

SHOP_PRICES = { 'common' => 1_000, 'rare' => 5_000, 'legendary' => 25_000 }.freeze
SELL_PRICES = { 'common' => 50, 'rare' => 250, 'legendary' => 1_000, 'goddess' => 5_000 }.freeze

BLACK_MARKET_ITEMS = {
  'headset'         => { name: '🎧 Cheap Headset',           price: 500,   type: 'upgrade',    desc: 'Better audio! Grants +25% to !post payouts.' },
  'keyboard'        => { name: '⌨️ RGB Keyboard',            price: 2000,  type: 'upgrade',    desc: 'Type at the speed of light! Grants +25% to !work payouts.' },
  'mic'             => { name: '🎙️ Studio Mic',               price: 10000, type: 'upgrade',    desc: 'Professional audio! Grants +10% to !stream payouts.' },
  'neon sign'       => { name: '✨ Holographic Neon Sign',  price: 25000, type: 'upgrade',    desc: 'Attracts massive attention! Doubles your !daily reward (x2).' },
  'gacha pass'      => { name: '🎟️ Gacha Pass',              price: 15000, type: 'upgrade',    desc: 'Permanently cuts your summon cooldown in half!' },
  'stamina pill'    => { name: '💊 Stamina Pill',            price: 1500,  type: 'consumable', desc: 'Instantly resets your summon cooldown!' },
  'gamer fuel'      => { name: '🥫 Gamer Fuel',              price: 2500,  type: 'consumable', desc: 'Instantly resets your stream, post, and collab cooldowns!' },
  'rng manipulator' => { name: '🔮 RNG Manipulator',         price: 5000,  type: 'consumable', desc: 'Guarantees your next !summon is a Rare or higher!' }
}.freeze