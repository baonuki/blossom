require 'discordrb'
require 'dotenv/load'

# =========================
# BOT SETUP
# =========================

puts "[SYSTEM] Checking voice engine..."
begin
  if defined?(Discordrb::Voice)
    puts "✅  Voice Engine: Ready"
  else
    puts "❌  Voice Engine: Missing (libsodium/sodium.dll not found)"
  end
rescue LoadError => e
  puts "❌  Voice Engine: Load Error - #{e.message}"
end

# =========================
# LOAD CONFIG DATA & DATABASE
# =========================
require_relative 'data/config'
require_relative 'data/pools'
require_relative 'data/database'

# =========================
# DATA STRUCTURES
# =========================
SERVER_BOMB_CONFIGS = DB.load_all_bomb_configs
ACTIVE_BOMBS       = {} 
ACTIVE_COLLABS     = {}
ACTIVE_TRADES      = {}

COMMAND_CATEGORIES = {
  'Economy'   => [:balance, :daily, :work, :stream, :post, :collab, :cooldowns, :coinlb, :lottery, :lotteryinfo, :givecoins, :remindme],
  'Gacha'     => [:summon, :collection, :banner, :shop, :buy, :view, :ascend, :trade, :givecard, :sell],
  'Arcade'    => [:coinflip, :slots, :roulette, :scratch, :dice, :cups],
  'Fun'       => [:kettle, :level, :leaderboard, :hug, :slap, :interactions],
  'Utility'   => [:ping, :help, :about, :support, :premium, :call, :dismiss, :serverinfo, :suggest],
  'Admin'     => [:setlevel, :enablebombs, :disablebombs, :levelup, :addxp, :giveaway, :logsetup, :logtoggle, :purge, :kick, :ban, :timeout, :verifysetup],
  'Developer' => [:addcoins, :removecoins, :setcoins, :blacklist, :card, :backup, :givepremium, :removepremium, :bomb]
}.freeze


# =========================
# BOT SETUP
# =========================

bot = Discordrb::Commands::CommandBot.new(
  token: ENV['TOKEN'],
  prefix: PREFIX,
  intents: [:servers, :server_messages, :server_members, :server_voice_states]
)

# =========================
# DYNAMIC SAFE LOADER
# =========================

def safe_load(file_path, context_binding)
  begin
    eval(File.read(file_path), context_binding)
    puts "✅ Loaded: #{File.basename(file_path)}"
  rescue StandardError => e
    puts "❌ ERROR in #{File.basename(file_path)}!"
    puts "   Line: #{e.backtrace.first}"
    puts "   Message: #{e.message}"
  rescue SyntaxError => e
    puts "⚠️ SYNTAX ERROR in #{File.basename(file_path)}!"
    puts "   Message: #{e.message}"
  end
end

puts "\n[SYSTEM] Booting Blossom Modules..."

# Load Helpers
Dir.glob(File.join(__dir__, 'helpers', '**', '*.rb')).each do |file|
  safe_load(file, binding)
end

# Load everything else
['commands', 'events', 'components'].each do |folder|
  Dir.glob(File.join(__dir__, folder, '**', '*.rb')).each do |file|
    safe_load(file, binding)
  end
end

# ------------------------------------

puts "Starting bot with prefix #{PREFIX.inspect}..."
bot.run