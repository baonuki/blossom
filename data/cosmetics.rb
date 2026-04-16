# ==========================================
# DATA: Cosmetic Definitions
# DESCRIPTION: Pets, Titles, Themes, and Badges for premium users.
# ==========================================

# --- PETS ---
# Cosmetic companions that appear in command responses.
# Each has a name, emoji, idle/happy/sad flavor text.
PETS = {
  'shadow_cat' => {
    name: 'Shadow Cat', emoji: '🐈‍⬛', price: 15,
    idle: '*A shadowy cat lounges nearby, watching with glowing eyes.*',
    happy: '*The Shadow Cat purrs and rubs against your leg.*',
    sad: '*The Shadow Cat hisses softly at your misfortune.*'
  },
  'pixel_slime' => {
    name: 'Pixel Slime', emoji: '🟢', price: 10,
    idle: '*A blobby green slime bounces at your feet.*',
    happy: '*The Pixel Slime jiggles excitedly!*',
    sad: '*The Pixel Slime deflates a little...*'
  },
  'neon_fox' => {
    name: 'Neon Fox', emoji: '🦊', price: 20,
    idle: '*A glowing fox with neon fur sits beside you, tail swishing.*',
    happy: '*The Neon Fox yips and does a backflip!*',
    sad: '*The Neon Fox whimpers and presses against you.*'
  },
  'arcade_drone' => {
    name: 'Arcade Drone', emoji: '🤖', price: 25,
    idle: '*A tiny floating drone buzzes around your head.*',
    happy: '*The Arcade Drone beeps a victory jingle!*',
    sad: '*The Arcade Drone plays a sad trombone sound.*'
  },
  'ghost_flame' => {
    name: 'Ghost Flame', emoji: '🔥', price: 30,
    idle: '*A spectral flame flickers and dances in the air.*',
    happy: '*The Ghost Flame flares bright with excitement!*',
    sad: '*The Ghost Flame dims to barely an ember...*'
  },
  'star_jellyfish' => {
    name: 'Star Jellyfish', emoji: "\u{1FABC}", price: 35,
    idle: '*A translucent jellyfish drifts serenely beside you, trailing stardust.*',
    happy: '*The Star Jellyfish pulses with radiant light!*',
    sad: '*The Star Jellyfish dims and sinks lower...*'
  },
  # Craftable-exclusive pets
  'scrap_golem' => {
    name: 'Scrap Golem', emoji: "\u{1F916}", price: 0, craftable: true,
    idle: '*A clunky golem made of scrap metal clanks beside you, gears whirring.*',
    happy: '*The Scrap Golem pumps a rusty fist in celebration!*',
    sad: '*The Scrap Golem\u2019s gears grind to a slow, sad halt...*'
  },
  'spark_wisp' => {
    name: 'Spark Wisp', emoji: "\u2728", price: 0, craftable: true,
    idle: '*A tiny wisp of crackling energy orbits your head, leaving sparkle trails.*',
    happy: '*The Spark Wisp flares into a brilliant burst of light!*',
    sad: '*The Spark Wisp flickers and dims to a faint glow...*'
  }
}.freeze

# --- TITLES ---
# Custom title displayed under name on level/balance pages.
TITLES = {
  'developer' => { name: 'Bot Developer', price: 0, dev_only: true },
  'arcade_rat' => { name: 'Arcade Rat', price: 5 },
  'gacha_addict' => { name: 'Gacha Addict', price: 5 },
  'high_roller' => { name: 'High Roller', price: 10 },
  'vtuber_simp' => { name: 'VTuber Simp', price: 10 },
  'whale_status' => { name: 'Whale Status', price: 20 },
  'neon_royalty' => { name: 'Neon Royalty', price: 25 },
  'shadow_broker' => { name: 'Shadow Broker', price: 15 },
  'content_machine' => { name: 'Content Machine', price: 10 },
  'lucky_charm' => { name: 'Lucky Charm', price: 15 },
  'chaos_gremlin' => { name: 'Chaos Gremlin', price: 20 },
  # Craftable-exclusive titles
  'tinkerer'       => { name: 'Tinkerer', price: 0, craftable: true },
  'engineer'       => { name: 'Engineer', price: 0, craftable: true },
  'scrapyard_boss' => { name: 'Scrapyard Boss', price: 0, craftable: true }
}.freeze

# --- COLLECTION THEMES ---
# Visual presets for /collection display.
COLLECTION_THEMES = {
  'default' => { name: 'Default', color: nil, prefix: '**', suffix: '**', bullet: '• ', price: 0 },
  'neon'    => { name: 'Neon Glow', color: 0x00FFAA, prefix: '**', suffix: '**', bullet: '▸ ', price: 10 },
  'dark'    => { name: 'Dark Mode', color: 0x1a1a2e, prefix: '', suffix: '', bullet: '> ', price: 10 },
  'pastel'  => { name: 'Pastel Dream', color: 0xFFB7C5, prefix: '*', suffix: '*', bullet: '🌸 ', price: 10 },
  'retro'   => { name: 'Retro Arcade', color: 0xFF6600, prefix: '`', suffix: '`', bullet: '▶ ', price: 15 },
  'galaxy'  => { name: 'Galaxy', color: 0x2B0057, prefix: '', suffix: '', bullet: '✦ ', price: 15 },
  'void'    => { name: 'Void', color: 0x0D0D0D, prefix: '', suffix: '', bullet: "\u{2591} ", price: 20 },
  # Craftable-exclusive themes
  'forge'   => { name: 'Forge', color: 0xFF4500, prefix: '**', suffix: '**', bullet: "\u{1F525} ", price: 0, craftable: true },
  'circuit' => { name: 'Circuit', color: 0x00FF41, prefix: '`', suffix: '`', bullet: "\u{25B8} ", price: 0, craftable: true }
}.freeze

# --- BADGES ---
# Some earnable via achievements, some Prisma-exclusive.
BADGES = {
  # Developer-exclusive (auto-granted, cannot be purchased)
  'developer'     => { name: 'Bot Developer', emoji: EMOJI_STRINGS['developer'], desc: 'The creator behind Blossom.', price: 0, earnable: true, dev_only: true },

  # Achievement-earned (price: 0, earned automatically)
  'early_bird'    => { name: 'Early Bird', emoji: '🐦', desc: 'Joined during the first month.', price: 0, earnable: true },
  'streak_master' => { name: 'Streak Master', emoji: '🔥', desc: '100-day daily streak.', price: 0, earnable: true },
  'collector'     => { name: 'Collector', emoji: '📚', desc: 'Own 100+ unique characters.', price: 0, earnable: true },
  'gambler'       => { name: 'Gambler', emoji: '🎰', desc: 'Win 100+ arcade games.', price: 0, earnable: true },
  'social_butterfly' => { name: 'Social Butterfly', emoji: '🦋', desc: '100+ interactions sent.', price: 0, earnable: true },

  # Prisma-exclusive
  'diamond'       => { name: 'Diamond', emoji: '💎', desc: 'The ultimate flex.', price: 50, earnable: false },
  'crown'         => { name: 'Crown', emoji: '👑', desc: 'Royalty recognized.', price: 30, earnable: false },
  'skull'         => { name: 'Skull', emoji: '💀', desc: 'Fear the reaper.', price: 20, earnable: false },
  'star'          => { name: 'Star', emoji: '⭐', desc: 'Born to shine.', price: 15, earnable: false },
  'heart'         => { name: 'Heart', emoji: '❤️', desc: 'Love is power.', price: 15, earnable: false },
  'lightning'     => { name: 'Lightning', emoji: '⚡', desc: 'Speed demon.', price: 20, earnable: false },
  'ghost'         => { name: 'Ghost', emoji: "\u{1F47B}", desc: 'Now you see me...', price: 25, earnable: false },
  # Craftable-exclusive badges
  'craftsman'     => { name: 'Craftsman', emoji: "\u{2699}\u{FE0F}", desc: 'Forged their own path.', price: 0, earnable: false, craftable: true },
  'forgemaster'   => { name: 'Forgemaster', emoji: "\u{1F525}", desc: 'Master of the forge.', price: 0, earnable: false, craftable: true },
  'scrap_king'    => { name: 'Scrap King', emoji: "\u{1F451}", desc: 'Built an empire from scraps.', price: 0, earnable: false, craftable: true }
}.freeze

# Helper to get pet flavor text based on context
def pet_flavor(uid, mood = :idle)
  cosmetics = DB.get_cosmetics(uid)
  return '' unless cosmetics['pet']
  pet = PETS[cosmetics['pet']]
  return '' unless pet
  "\n\n#{pet[:emoji]} #{pet[mood]}"
end
