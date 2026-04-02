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
  'first_work'     => { name: "Clocking In", desc: "Use the work command for the first time.", emoji: "⌨️", reward: 250 },
  'first_post'     => { name: "Content Creator", desc: "Post on social media for the first time.", emoji: "📱", reward: 250 },
  'first_givecoins' => { name: "Generous Soul", desc: "Give coins to another user.", emoji: "🎁", reward: 500 },
  'give_10k'       => { name: "Philanthropist", desc: "Give away 10,000 coins total.", emoji: "💝", reward: 2500 },
  'give_100k'      => { name: "Sugar Mama", desc: "Give away 100,000 coins total.", emoji: "👸", reward: 10000 },
  'first_sell'     => { name: "Downsizing", desc: "Sell duplicate characters for the first time.", emoji: "♻️", reward: 500 },

  # --- LEVELING ---
  'level_5'        => { name: "Newcomer", desc: "Reach Level 5 in any server.", emoji: "🌱", reward: 500 },
  'level_10'       => { name: "Regular", desc: "Reach Level 10 in any server.", emoji: "⭐", reward: 1000 },
  'level_25'       => { name: "Veteran", desc: "Reach Level 25 in any server.", emoji: "🎖️", reward: 5000 },
  'level_50'       => { name: "Server Legend", desc: "Reach Level 50 in any server.", emoji: "🏅", reward: 15000 },
  'level_100'      => { name: "No Life", desc: "Reach Level 100 in any server.", emoji: "💀", reward: 50000 },

  # --- GACHA & COLLECTION ---
  'first_pull'     => { name: "Gacha Addict in Training", desc: "Roll the gacha.", emoji: "🎲", reward: 500 },
  'goddess_luck'   => { name: "Divine Luck", desc: "Pull a Goddess-tier character.", emoji: EMOJI_STRINGS['goddess'], reward: 5000 },
  'summon_100'     => { name: "Gacha Addict", desc: "Roll the gacha 100 times.", emoji: "🎰", reward: 5000 },
  'summon_500'     => { name: "Wallet Warrior", desc: "Roll the gacha 500 times.", emoji: "💸", reward: 15000 },
  'summon_1000'    => { name: "Down Bad", desc: "Roll the gacha 1,000 times.", emoji: "🕳️", reward: 50000 },
  'leg_pull'       => { name: "Golden Ticket", desc: "Pull a Legendary-tier character.", emoji: EMOJI_STRINGS['legendary'], reward: 2500 },
  'back_to_back'   => { name: "Double Rainbow", desc: "Pull two Rare+ characters in a row.", emoji: "🌈", reward: 3000 },
  'first_goddess_buy' => { name: "Prisma Shopper", desc: "Buy a Goddess from the Prisma Shop.", emoji: EMOJI_STRINGS['goddess'], reward: 5000 },

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

  # --- TRADING & GIFTING ---
  'first_trade'    => { name: "The Art of the Deal", desc: "Complete a trade.", emoji: "🤝", reward: 1000 },
  'trade_10'       => { name: "Trader", desc: "Complete 10 trades.", emoji: "📦", reward: 5000 },
  'first_givecard' => { name: "Sharing is Caring", desc: "Give a VTuber card to someone.", emoji: "💌", reward: 500 },
  'givecard_10'    => { name: "Card Santa", desc: "Give away 10 VTuber cards.", emoji: "🎅", reward: 5000 },

  # --- ITEMS & BLACK MARKET ---
  'buy_upgrade'    => { name: "Tech Support", desc: "Buy a permanent stream upgrade.", emoji: "🖥️", reward: 1000 },
  'max_upgrades'   => { name: "The Perfect Setup", desc: "Buy all 5 permanent stream upgrades.", emoji: "🎛️", reward: 10000 },
  'buy_consumable' => { name: "Time to Mix Drinks", desc: "Buy a consumable item.", emoji: "🍹", reward: 500 },
  'use_fuel'       => { name: "Caffeine Crash", desc: "Drink a Gamer Fuel.", emoji: EMOJI_STRINGS['gamer_fuel'], reward: 1000 },
  'use_pill'       => { name: "Questionable Medicine", desc: "Swallow a Stamina Pill.", emoji: "💊", reward: 1000 },
  'hoard_10_cons'  => { name: "Pharmacy", desc: "Hold 10 consumables in your inventory.", emoji: "🏥", reward: 2500 },
  'use_rng'        => { name: "Rigging the System", desc: "Use an RNG Manipulator.", emoji: EMOJI_STRINGS['rng_manipulator'], reward: 1000 },

  # --- SOCIAL & INTERACTIONS ---
  'first_hug'      => { name: "Spreading Joy", desc: "Hug someone.", emoji: "🫂", reward: 100 },
  'hug_sent_10'    => { name: "Friendly", desc: "Send 10 hugs.", emoji: "🤗", reward: 1000 },
  'hug_sent_50'    => { name: "Cuddle Bug", desc: "Send 50 hugs.", emoji: "🥰", reward: 5000 },
  'hug_sent_100'   => { name: "Professional Hugger", desc: "Send 100 hugs.", emoji: "💗", reward: 10000 },
  'hug_rec_10'     => { name: "Loved", desc: "Receive 10 hugs.", emoji: "💌", reward: 1000 },
  'hug_rec_50'     => { name: "Idolized", desc: "Receive 50 hugs.", emoji: "💖", reward: 5000 },
  'hug_rec_100'    => { name: "National Treasure", desc: "Receive 100 hugs.", emoji: "👑", reward: 10000 },

  'first_slap'     => { name: "Menace", desc: "Slap someone.", emoji: "👋", reward: 100 },
  'slap_sent_10'   => { name: "Bully", desc: "Send 10 slaps.", emoji: "💢", reward: 1000 },
  'slap_sent_50'   => { name: "Public Enemy", desc: "Send 50 slaps.", emoji: "😈", reward: 5000 },
  'slap_sent_100'  => { name: "War Criminal", desc: "Send 100 slaps.", emoji: "☠️", reward: 10000 },
  'slap_rec_10'    => { name: "Punching Bag", desc: "Receive 10 slaps.", emoji: "🩹", reward: 1000 },
  'slap_rec_50'    => { name: "Victim", desc: "Receive 50 slaps.", emoji: "🤕", reward: 5000 },
  'slap_rec_100'   => { name: "Martyrdom", desc: "Receive 100 slaps.", emoji: "⚰️", reward: 10000 },

  'first_pat'      => { name: "Gentle Soul", desc: "Pat someone on the head.", emoji: "🌸", reward: 100 },
  'pat_sent_10'    => { name: "Headpatter", desc: "Send 10 pats.", emoji: "😊", reward: 1000 },
  'pat_sent_50'    => { name: "Comfort Main", desc: "Send 50 pats.", emoji: "🥺", reward: 5000 },
  'pat_sent_100'   => { name: "Certified Therapist", desc: "Send 100 pats.", emoji: "💆", reward: 10000 },
  'pat_rec_10'     => { name: "Pampered", desc: "Receive 10 pats.", emoji: "😌", reward: 1000 },
  'pat_rec_50'     => { name: "Golden Child", desc: "Receive 50 pats.", emoji: "👼", reward: 5000 },
  'pat_rec_100'    => { name: "Head Pat Royalty", desc: "Receive 100 pats.", emoji: "👑", reward: 10000 },

  'giveaway_win'   => { name: "Lucky Winner", desc: "Win a server giveaway.", emoji: "🎉", reward: 5000 },

  # --- ARCADE & GAMBLING ---
  'gamble_win'     => { name: "Beginner's Luck", desc: "Win a coinflip.", emoji: "🪙", reward: 500 },
  'slots_spin'     => { name: "Neon Lights", desc: "Spin the slots.", emoji: "🎰", reward: 500 },
  'slots_jackpot'  => { name: "JACKPOT!", desc: "Hit a 3-of-a-kind on the slots.", emoji: "💰", reward: 5000 },
  'roulette_play'  => { name: "Roulette Rookie", desc: "Play roulette for the first time.", emoji: "🎡", reward: 500 },
  'roulette_number' => { name: "One in a Million", desc: "Win a single-number roulette bet.", emoji: "🎯", reward: 10000 },
  'scratch_play'   => { name: "Scratch Fever", desc: "Buy a scratch-off ticket.", emoji: "🎫", reward: 500 },
  'scratch_jackpot' => { name: "Golden Ticket", desc: "Hit the jackpot on a scratch-off.", emoji: "🏆", reward: 10000 },
  'dice_play'      => { name: "Dice Roller", desc: "Play the dice game.", emoji: "🎲", reward: 500 },
  'dice_seven'     => { name: "Lucky Seven", desc: "Win by betting on 7.", emoji: "7️⃣", reward: 5000 },
  'cups_play'      => { name: "Shell Game", desc: "Play the cups game.", emoji: "🥤", reward: 500 },
  'cups_streak_3'  => { name: "Sharp Eyes", desc: "Win the cups game 3 times in a row.", emoji: "👁️", reward: 5000 },
  'gamble_10k'     => { name: "High Roller", desc: "Bet 10,000+ coins in a single wager.", emoji: "🃏", reward: 5000 },
  'gamble_broke'   => { name: "Gambler's Ruin", desc: "Lose a bet of 5,000+ coins.", emoji: "💔", reward: 1000 },
  'lottery_enter'  => { name: "Feeling Lucky", desc: "Enter the global lottery.", emoji: "🍀", reward: 500 },
  'lottery_win'    => { name: "Lottery Winner", desc: "Win the global lottery.", emoji: "🎊", reward: 25000 },

  # --- EVENTS ---
  'carnival_ring'  => { name: "Ringmaster", desc: "Play the Ring Toss game.", emoji: "⭕", reward: 250 },
  'carnival_pop'   => { name: "Sharpshooter", desc: "Play the Balloon Pop game.", emoji: "🎈", reward: 250 },
  'carnival_snack' => { name: "Sweet Tooth", desc: "Buy an item from the Carnival tent.", emoji: "🍿", reward: 500 },
  'carnival_char'  => { name: "Carnival VIP", desc: "Buy an exclusive Carnival VTuber.", emoji: "🎪", reward: 2000 },
  'tickets_1k'     => { name: "Carny", desc: "Hold 1,000 Carnival Tickets.", emoji: "🎟️", reward: 2500 },
  'tickets_5k'     => { name: "Ticket Master", desc: "Hold 5,000 Carnival Tickets.", emoji: "🎡", reward: 10000 },

  # --- ACTIVITY STREAKS ---
  'active_7'       => { name: "Regular", desc: "Chat for 7 consecutive days in a server.", emoji: "📆", reward: 500 },
  'active_14'      => { name: "Loyal Patron", desc: "Chat for 14 consecutive days in a server.", emoji: "📅", reward: 1500 },
  'active_30'      => { name: "The Local", desc: "Chat for 30 consecutive days in a server.", emoji: "🏠", reward: 5000 },
  'active_60'      => { name: "Pillar of the Community", desc: "Chat for 60 consecutive days in a server.", emoji: "🏛️", reward: 10000 },
  'active_100'     => { name: "Immortalized", desc: "Chat for 100 consecutive days in a server.", emoji: "🗿", reward: 25000 },

  # --- META & MILESTONES ---
  'ach_10'         => { name: "Trophy Case", desc: "Unlock 10 achievements.", emoji: "🗄️", reward: 2500 },
  'ach_25'         => { name: "Overachiever", desc: "Unlock 25 achievements.", emoji: "🏅", reward: 10000 },
  'ach_50'         => { name: "Completionist+", desc: "Unlock 50 achievements.", emoji: "🏆", reward: 50000 },
}.freeze
