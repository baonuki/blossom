# ==========================================
# DATA: Global Constants & State
# DESCRIPTION: Holds command categories and active game states.
# ==========================================

# Active session tracking
ACTIVE_BOMBS       = {}
ACTIVE_COLLABS     = {}
ACTIVE_TRADES      = {}
ACTIVE_PROPOSALS   = {}
ACTIVE_SELLS       = {}
ACTIVE_RPS         = {}
ACTIVE_HEISTS      = {} # server_id => { message_id:, participants: [], started_at:, channel_id: }
ACTIVE_CREW_INVITES = {} # "crew_id_target_uid" => { crew_id:, inviter_id:, expires_at: }
ACTIVE_TICKETS      = {} # user_id => channel_id (prevents duplicate open tickets)

# Categorization for the Help Menu
COMMAND_CATEGORIES = {
  'Economy'   => [:balance, :daily, :work, :stream, :post, :collab, :cooldowns, :lottery, :lotteryinfo, :givecoins, :remindme, :invest, :portfolio, :withdraw, :autoclaim, :event],
  'Gacha'     => [:summon, :collection, :custombanner, :shop, :buy, :view, :ascend, :trade, :givecard, :sell, :autosell, :shinymode, :giftlog, :craft, :salvage],
  'Arcade'    => [:coinflip, :slots, :roulette, :scratch, :dice, :cups, :blackjack, :spin, :rps, :fish, :trivia, :boss],
  'Fun'       => [:kettle, :level, :leaderboard, :hug, :slap, :pat, :rep, :marry, :divorce, :birthday, :interactions, :serverinfo, :crew, :friends],
  'Utility'   => [:ping, :help, :about, :support, :premium, :suggest, :profile, :stats, :notifications, :challenges],
  'Admin'     => [:setxp, :bomb, :levelup, :giveaway, :logsetup, :logtoggle, :purge, :kick, :ban, :timeout, :verifysetup, :achievements, :welcomer, :reactionrole, :commleveltoggle, :heist, :automod, :bosssetup, :tipsetup],
  'Developer' => [:dcoin, :dpremium, :blacklist, :card, :prisma, :dbomb, :dreset, :syncachievements, :dticketsetup, :dapplysetup, :devhelp]
}.freeze