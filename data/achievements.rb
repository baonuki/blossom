# ==========================================
# DATA: Achievement Definitions
# DESCRIPTION: The complete list of unlockable trophies.
# ==========================================

ACHIEVEMENTS = {
  # --- ECONOMY & STREAKS ---
  'streak_7'       => { name: "The Daily Grind", desc: "Reach a 7-day daily streak.", emoji: "🔥", reward: 1000 },
  'streak_30'      => { name: "Dedication", desc: "Reach a 30-day daily streak.", emoji: "📅", reward: 5000 },
  'streak_69'      => { name: "Nice.", desc: "Reach a 69-day daily streak.", emoji: "😏", reward: 6969 },
  'streak_100'     => { name: "Centurion", desc: "Reach a 100-day daily streak.", emoji: "💯", reward: 10000 },
  'streak_365'     => { name: "Touch Grass", desc: "Reach a 365-day daily streak.", emoji: "🌱", reward: 50000 },
  
  'wealth_0'       => { name: "Rock Bottom", desc: "Hit exactly 0 coins.", emoji: "📉", reward: 100 },
  'wealth_10k'     => { name: "Savings Account", desc: "Hold 10,000 coins at once.", emoji: "💵", reward: 1000 },
  'wealth_100k'    => { name: "Making Bank", desc: "Hold 100,000 coins at once.", emoji: "💰", reward: 5000 },
  'wealth_1m'      => { name: "Millionaire", desc: "Hold 1,000,000 coins at once.", emoji: "👑", reward: 25000 },
  'wealth_10m'     => { name: "Leviathan", desc: "Hold 10,000,000 coins at once.", emoji: "🐋", reward: 100000 },

  'first_stream'   => { name: "Going Live!", desc: "Use the stream command.", emoji: "🎙️", reward: 500 },
  'first_collab'   => { name: "Networking", desc: "Successfully start a collab stream.", emoji: "🤝", reward: 1000 },

  # --- GACHA & COLLECTION ---
  'first_pull'     => { name: "Gacha Addict in Training", desc: "Roll the gacha.", emoji: "🎲", reward: 500 },
  'goddess_luck'   => { name: "Divine Luck", desc: "Pull a Goddess-tier character.", emoji: "💎", reward: 5000 },
  
  'coll_10'        => { name: "Collector", desc: "Hold 10 unique VTubers.", emoji: "📚", reward: 1000 },
  'coll_50'        => { name: "Archivist", desc: "Hold 50 unique VTubers.", emoji: "🏛️", reward: 5000 },
  'coll_100'       => { name: "Legion", desc: "Hold 100 unique VTubers.", emoji: "⚔️", reward: 15000 },
  'coll_200'       => { name: "Completionist", desc: "Hold 200 unique VTubers.", emoji: "🏆", reward: 50000 },

  'rare_25'        => { name: "Shiny Hunter", desc: "Hold 25 unique Rares.", emoji: "✨", reward: 5000 },
  'leg_10'         => { name: "SSR Collector", desc: "Hold 10 unique Legendaries.", emoji: "🌟", reward: 5000 },
  'leg_25'         => { name: "Elite Roster", desc: "Hold 25 unique Legendaries.", emoji: "🌠", reward: 15000 },
  'god_5'          => { name: "Pantheon", desc: "Hold 5 unique Goddesses.", emoji: "⛩️", reward: 25000 },
  
  'dupe_100'       => { name: "Sea of Dupes", desc: "Have 100 copies of a single character.", emoji: "👯", reward: 5000 },

  'ascension'      => { name: "Going Further Beyond", desc: "Ascend a character.", emoji: "⬆️", reward: 2500 },
  'ascend_5'       => { name: "Breaking Limits", desc: "Ascend 5 unique characters.", emoji: "🔥", reward: 10000 },
  'ascend_10'      => { name: "True Potential", desc: "Ascend 10 unique characters.", emoji: "💫", reward: 25000 },
  'ascend_25'      => { name: "Awakening", desc: "Ascend 25 unique characters.", emoji: "🌌", reward: 100000 },

  # --- ITEMS & BLACK MARKET ---
  'buy_upgrade'    => { name: "Tech Support", desc: "Buy a permanent stream upgrade.", emoji: "🖥️", reward: 1000 },
  'max_upgrades'   => { name: "The Perfect Setup", desc: "Buy all 5 permanent stream upgrades.", emoji: "🎛️", reward: 10000 },
  'buy_consumable' => { name: "Time to Mix Drinks", desc: "Buy a consumable item.", emoji: "🍹", reward: 500 },
  'use_fuel'       => { name: "Caffeine Crash", desc: "Drink a Gamer Fuel.", emoji: "🥫", reward: 1000 },
  'use_pill'       => { name: "Questionable Medicine", desc: "Swallow a Stamina Pill.", emoji: "💊", reward: 1000 },
  'hoard_10_cons'  => { name: "Pharmacy", desc: "Hold 10 consumables in your inventory.", emoji: "🏥", reward: 2500 },

  # --- SOCIAL & INTERACTIONS ---
  'first_hug'      => { name: "Spreading Joy", desc: "Hug someone.", emoji: "🫂", reward: 100 },
  'hug_sent_10'    => { name: "Friendly", desc: "Send 10 hugs.", emoji: "🤗", reward: 1000 },
  'hug_sent_50'    => { name: "Cuddle Bug", desc: "Send 50 hugs.", emoji: "🥰", reward: 5000 },
  'hug_rec_10'     => { name: "Loved", desc: "Receive 10 hugs.", emoji: "💌", reward: 1000 },
  'hug_rec_50'     => { name: "Idolized", desc: "Receive 50 hugs.", emoji: "💖", reward: 5000 },

  'first_slap'     => { name: "Menace", desc: "Slap someone.", emoji: "👋", reward: 100 },
  'slap_sent_10'   => { name: "Bully", desc: "Send 10 slaps.", emoji: "💢", reward: 1000 },
  'slap_sent_50'   => { name: "Public Enemy", desc: "Send 50 slaps.", emoji: "😈", reward: 5000 },
  'slap_rec_10'    => { name: "Punching Bag", desc: "Receive 10 slaps.", emoji: "🩹", reward: 1000 },
  'slap_rec_50'    => { name: "Victim", desc: "Receive 50 slaps.", emoji: "🤕", reward: 5000 },
  
  'first_trade'    => { name: "The Art of the Deal", desc: "Complete a trade.", emoji: "🤝", reward: 1000 },
  'giveaway_win'   => { name: "Lucky Winner", desc: "Win a server giveaway.", emoji: "🎉", reward: 5000 },

  # --- ARCADE & EVENTS ---
  'gamble_win'     => { name: "Beginner's Luck", desc: "Win a coinflip.", emoji: "🪙", reward: 500 },
  'slots_spin'     => { name: "Neon Lights", desc: "Spin the slots.", emoji: "🎰", reward: 500 },

  'carnival_ring'  => { name: "Ringmaster", desc: "Play the Ring Toss game.", emoji: "⭕", reward: 250 },
  'carnival_pop'   => { name: "Sharpshooter", desc: "Play the Balloon Pop game.", emoji: "🎈", reward: 250 },
  'carnival_snack' => { name: "Sweet Tooth", desc: "Buy an item from the Carnival tent.", emoji: "🍿", reward: 500 },
  'carnival_char'  => { name: "Carnival VIP", desc: "Buy an exclusive Carnival VTuber.", emoji: "🎪", reward: 2000 },
  'tickets_1k'     => { name: "Carny", desc: "Hold 1,000 Carnival Tickets.", emoji: "🎟️", reward: 2500 },
  'tickets_5k'     => { name: "Ticket Master", desc: "Hold 5,000 Carnival Tickets.", emoji: "🎡", reward: 10000 }
}.freeze