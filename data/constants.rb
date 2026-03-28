# ==========================================
# DATA: Global Constants & State
# DESCRIPTION: Holds command categories and active game states.
# ==========================================

# Active session tracking
ACTIVE_BOMBS       = {} 
ACTIVE_COLLABS     = {}
ACTIVE_TRADES      = {}

# Categorization for the Help Menu
COMMAND_CATEGORIES = {
  'Economy'   => [:balance, :daily, :work, :stream, :post, :collab, :cooldowns, :lottery, :lotteryinfo, :givecoins, :remindme, :event],
  'Gacha'     => [:summon, :collection, :banner, :shop, :buy, :view, :ascend, :trade, :givecard, :sell],
  'Arcade'    => [:coinflip, :slots, :roulette, :scratch, :dice, :cups, :blackjack],
  'Fun'       => [:kettle, :level, :leaderboard, :hug, :slap, :pat, :rep, :interactions, :serverinfo],
  'Utility'   => [:ping, :help, :about, :support, :premium, :suggest],
  'Admin'     => [:setxp, :bomb, :levelup, :giveaway, :logsetup, :logtoggle, :purge, :kick, :ban, :timeout, :verifysetup, :achievements, :welcomer, :commleveltoggle],
  'Developer' => [:dcoin, :dpremium, :blacklist, :card, :prisma, :dbomb, :syncachievements, :devhelp]
}.freeze