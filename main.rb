# ==========================================
# MAIN ENTRY POINT: Blossom Bot
# AUTHOR: baonuki
# ==========================================

require 'discordrb'
require 'dotenv/load'
require 'json'
require 'time'

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
require_relative 'helpers/cache'       # In-memory TTL cache (must load before DB)
require_relative 'data/settings'      # Core IDs and Prefixes
require_relative 'data/assets'        # Emojis and Colors
require_relative 'data/economy'       # Rewards and Prices
require_relative 'data/achievements'   # Trophy Definitions
require_relative 'data/constants'     # Global States/Categories
require_relative 'data/cosmetics'     # Pets, Titles, Themes, Badges

# 2. From the old 'pools.rb' split:
require_relative 'data/characters'    # VTuber Rarity Pools
require_relative 'data/interactions'  # Hug/Slap
require_relative 'data/events'        # Seasonal Event Configs
require_relative 'data/trivia'        # Trivia Question Bank
require_relative 'data/crafting'      # Crafting Recipes & Materials
require_relative 'data/challenges'    # Weekly Challenge Pool
require_relative 'data/tips'          # Daily Tips & Fun Facts

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
  intents: [:servers, :server_messages, :server_members, :server_voice_states, :server_message_reactions]
)

# 4. Load System Components
require_relative 'components/loader'
load_blossom_modules # Pass the 'bot' variable context to the loader

# 5. Connect to Discord
puts "\n🌸 Blossom is starting with prefix #{PREFIX.inspect}..."
$bot.run