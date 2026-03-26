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
  'Economy'   => [:balance, :daily, :work, :stream, :post, :collab, :cooldowns, :coinlb, :lottery, :lotteryinfo, :givecoins, :remindme],
  'Gacha'     => [:summon, :collection, :banner, :shop, :buy, :view, :ascend, :trade, :givecard, :sell],
  'Arcade'    => [:coinflip, :slots, :roulette, :scratch, :dice, :cups],
  'Fun'       => [:kettle, :level, :leaderboard, :hug, :slap, :interactions],
  'Utility'   => [:ping, :help, :about, :support, :premium, :call, :dismiss, :serverinfo, :suggest],
  'Admin'     => [:setxp, :bomb, :levelup, :giveaway, :logsetup, :logtoggle, :purge, :kick, :ban, :timeout, :verifysetup],
  'Developer' => [:dcoin, :dpremium, :blacklist, :card, :prisma, :dbomb, :syncachievements, :backup]
}.freeze