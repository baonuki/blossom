# ==========================================
# MAIN ENTRY POINT: Blossom Bot
# AUTHOR: Envvy / Kyvrixon Development
# ==========================================

require 'discordrb'
require 'dotenv/load'

# =========================
# BOT SETUP & VOICE CHECK
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
# LOAD ORGANIZED DATA
# =========================

# 1. From the old 'config.rb' split:
require_relative 'data/settings'      # Core IDs and Prefixes
require_relative 'data/economy'       # Rewards and Prices
require_relative 'data/assets'        # Emojis and Colors
require_relative 'data/achievements'   # Trophy Definitions
require_relative 'data/constants'     # Global States/Categories

# 2. From the old 'pools.rb' split:
require_relative 'data/characters'    # VTuber Rarity Pools
require_relative 'data/interactions'  # Hug/Slap
require_relative 'data/events'        # Seasonal Event Configs

# 3. Database Engine
require_relative 'data/database/base' # DB Connection & Query Methods

# =========================
# DATA STRUCTURES
# =========================

SERVER_BOMB_CONFIGS = DB.load_all_bomb_configs

# 2. Initialize Bot Instance
$bot = Discordrb::Commands::CommandBot.new(
  token: ENV['TOKEN'],
  prefix: PREFIX,
  intents: [:servers, :server_messages, :server_members, :server_voice_states]
)

# 4. Load System Components
require_relative 'components/loader'
load_blossom_modules # Pass the 'bot' variable context to the loader

# 5. Connect to Discord
puts "\n🌸 Blossom is starting with prefix #{PREFIX.inspect}..."
$bot.run