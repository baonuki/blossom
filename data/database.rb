require 'pg'
require 'time'

class BotDatabase
  def initialize
    # Connect to Neon/Postgres using your .env variable
    @db = PG.connect(ENV['DATABASE_URL'])
    
    # Run all table creations ONCE when the bot boots up!
    setup_schema
  end

  def setup_schema
    # Using BIGINT for all Discord IDs because standard integers are too small in Postgres
    @db.exec(<<-SQL)
      CREATE TABLE IF NOT EXISTS server_settings (
        server_id BIGINT PRIMARY KEY,
        levelup_enabled INTEGER DEFAULT 1
      );
      
      CREATE TABLE IF NOT EXISTS blacklist (
        user_id BIGINT PRIMARY KEY
      );

      CREATE TABLE IF NOT EXISTS global_users (
        user_id BIGINT PRIMARY KEY,
        coins INTEGER DEFAULT 0,
        daily_at TIMESTAMP,
        work_at TIMESTAMP,
        stream_at TIMESTAMP,
        post_at TIMESTAMP,
        collab_at TIMESTAMP,
        summon_at TIMESTAMP
      );

      CREATE TABLE IF NOT EXISTS inventory (
        user_id BIGINT,
        item_name VARCHAR(255),
        count INTEGER DEFAULT 0,
        PRIMARY KEY(user_id, item_name)
      );

      CREATE TABLE IF NOT EXISTS collections (
        user_id BIGINT,
        character_name VARCHAR(255),
        rarity VARCHAR(50),
        count INTEGER DEFAULT 0,
        ascended INTEGER DEFAULT 0,
        PRIMARY KEY(user_id, character_name)
      );

      CREATE TABLE IF NOT EXISTS server_xp (
        server_id BIGINT,
        user_id BIGINT,
        xp INTEGER DEFAULT 0,
        level INTEGER DEFAULT 1,
        last_xp_at TIMESTAMP,
        PRIMARY KEY(server_id, user_id)
      );

      CREATE TABLE IF NOT EXISTS interactions (
        user_id BIGINT PRIMARY KEY,
        hug_sent INTEGER DEFAULT 0,
        hug_received INTEGER DEFAULT 0,
        slap_sent INTEGER DEFAULT 0,
        slap_received INTEGER DEFAULT 0
      );

      CREATE TABLE IF NOT EXISTS server_configs (
        server_id BIGINT PRIMARY KEY, 
        levelup_channel BIGINT, 
        levelup_enabled INTEGER
      );

      CREATE TABLE IF NOT EXISTS server_bombs (
        server_id BIGINT PRIMARY KEY, 
        enabled INTEGER, 
        channel_id BIGINT, 
        threshold INTEGER, 
        count INTEGER
      );

      CREATE TABLE IF NOT EXISTS lifetime_premium (
        user_id BIGINT PRIMARY KEY
      );

      CREATE TABLE IF NOT EXISTS giveaways (
        id VARCHAR(255) PRIMARY KEY, 
        channel_id BIGINT, 
        message_id BIGINT, 
        host_id BIGINT, 
        prize TEXT, 
        end_time BIGINT
      );

      CREATE TABLE IF NOT EXISTS giveaway_entrants (
        giveaway_id VARCHAR(255), 
        user_id BIGINT, 
        UNIQUE(giveaway_id, user_id)
      );
    SQL
  end

  # =========================
  # ECONOMY
  # =========================

  def get_coins(uid)
    row = @db.exec_params("SELECT coins FROM global_users WHERE user_id = $1", [uid]).first
    row ? row['coins'].to_i : 0
  end

  def add_coins(uid, amount)
    @db.exec_params("INSERT INTO global_users (user_id, coins) VALUES ($1, $2) ON CONFLICT (user_id) DO UPDATE SET coins = global_users.coins + $3", [uid, amount, amount])
  end

  def set_coins(uid, amount)
    @db.exec_params("INSERT INTO global_users (user_id, coins) VALUES ($1, $2) ON CONFLICT (user_id) DO UPDATE SET coins = $3", [uid, amount, amount])
  end

  def get_total_users
    row = @db.exec("SELECT COUNT(user_id) AS total FROM global_users").first
    row ? row['total'].to_i : 0
  end

  def get_top_coins(limit = 10)
    @db.exec_params("SELECT user_id, coins FROM global_users ORDER BY coins DESC LIMIT $1", [limit]).to_a
  end

  # =========================
  # COOLDOWNS
  # =========================

  def get_cooldown(uid, type)
    row = @db.exec_params("SELECT #{type}_at FROM global_users WHERE user_id = $1", [uid]).first
    return nil unless row && row["#{type}_at"]
    Time.parse(row["#{type}_at"])
  end

  def set_cooldown(uid, type, time_obj)
    time_str = time_obj ? time_obj.iso8601 : nil
    @db.exec_params("INSERT INTO global_users (user_id, coins) VALUES ($1, 0) ON CONFLICT DO NOTHING", [uid])
    @db.exec_params("UPDATE global_users SET #{type}_at = $2 WHERE user_id = $1", [uid, time_str])
  end

  # =========================
  # INVENTORY
  # =========================

  def get_inventory(uid)
    rows = @db.exec_params("SELECT item_name, count FROM inventory WHERE user_id = $1", [uid])
    inv = {}
    rows.each { |r| inv[r['item_name']] = r['count'].to_i }
    inv
  end

  def add_inventory(uid, item_name, amount = 1)
    @db.exec_params("INSERT INTO inventory (user_id, item_name, count) VALUES ($1, $2, $3) ON CONFLICT (user_id, item_name) DO UPDATE SET count = inventory.count + $4", [uid, item_name, amount, amount])
  end

  def remove_inventory(uid, item_name, amount = 1)
    @db.exec_params("UPDATE inventory SET count = count - $1 WHERE user_id = $2 AND item_name = $3", [amount, uid, item_name])
  end

  # =========================
  # GACHA COLLECTIONS
  # =========================

  def get_collection(uid)
    rows = @db.exec_params("SELECT character_name, rarity, count, ascended FROM collections WHERE user_id = $1", [uid])
    col = {}
    rows.each do |r|
      col[r['character_name']] = { 'rarity' => r['rarity'], 'count' => r['count'].to_i, 'ascended' => r['ascended'].to_i }
    end
    col
  end

  def add_character(uid, name, rarity, amount = 1)
    @db.exec_params("INSERT INTO collections (user_id, character_name, rarity, count, ascended) VALUES ($1, $2, $3, $4, 0) ON CONFLICT (user_id, character_name) DO UPDATE SET count = collections.count + $5", [uid, name, rarity, amount, amount])
  end
  
  def remove_character(uid, name, amount = 1)
    @db.exec_params("UPDATE collections SET count = count - $1 WHERE user_id = $2 AND character_name = $3", [amount, uid, name])
  end

  def ascend_character(uid, name)
    @db.exec_params("UPDATE collections SET count = count - 5, ascended = ascended + 1 WHERE user_id = $1 AND character_name = $2", [uid, name])
  end

  # =========================
  # LEVELING & XP
  # =========================

  def get_user_xp(sid, uid)
    row = @db.exec_params("SELECT xp, level, last_xp_at FROM server_xp WHERE server_id = $1 AND user_id = $2", [sid, uid]).first
    if row
      { 'xp' => row['xp'].to_i, 'level' => row['level'].to_i, 'last_xp_at' => (row['last_xp_at'] ? Time.parse(row['last_xp_at']) : nil) }
    else
      { 'xp' => 0, 'level' => 1, 'last_xp_at' => nil }
    end
  end

  def update_user_xp(sid, uid, xp, level, last_xp_at)
    time_str = last_xp_at ? last_xp_at.iso8601 : nil
    @db.exec_params("INSERT INTO server_xp (server_id, user_id, xp, level, last_xp_at) VALUES ($1, $2, $3, $4, $5) ON CONFLICT (server_id, user_id) DO UPDATE SET xp = $6, level = $7, last_xp_at = $8", [sid, uid, xp, level, time_str, xp, level, time_str])
  end

  def remove_user_xp(sid, uid)
    @db.exec_params("DELETE FROM server_xp WHERE server_id = $1 AND user_id = $2", [sid, uid])
  end
  
  def get_top_users(sid, limit = 10)
    @db.exec_params("SELECT user_id, xp, level FROM server_xp WHERE server_id = $1 ORDER BY level DESC, xp DESC LIMIT $2", [sid, limit]).to_a
  end

  # =========================
  # INTERACTIONS
  # =========================

  def get_interactions(uid)
    row = @db.exec_params("SELECT * FROM interactions WHERE user_id = $1", [uid]).first
    if row
      {
        'hug' => { 'sent' => row['hug_sent'].to_i, 'received' => row['hug_received'].to_i },
        'slap' => { 'sent' => row['slap_sent'].to_i, 'received' => row['slap_received'].to_i }
      }
    else
      { 'hug' => { 'sent' => 0, 'received' => 0 }, 'slap' => { 'sent' => 0, 'received' => 0 } }
    end
  end

  def add_interaction(uid, type, role)
    col = "#{type}_#{role}"
    @db.exec_params("INSERT INTO interactions (user_id, #{col}) VALUES ($1, 1) ON CONFLICT (user_id) DO UPDATE SET #{col} = interactions.#{col} + 1", [uid])
  end

  # =========================
  # SERVER SETTINGS
  # =========================

  def get_levelup_config(server_id)
    row = @db.exec_params("SELECT levelup_channel, levelup_enabled FROM server_configs WHERE server_id = $1", [server_id]).first
    if row
      { channel: row['levelup_channel'] ? row['levelup_channel'].to_i : nil, enabled: row['levelup_enabled'].to_i == 1 }
    else
      { channel: nil, enabled: GLOBAL_LEVELUP_ENABLED }
    end
  end

  def set_levelup_config(server_id, channel_id, enabled)
    val = enabled ? 1 : 0
    @db.exec_params("INSERT INTO server_configs (server_id, levelup_channel, levelup_enabled) VALUES ($1, $2, $3) ON CONFLICT (server_id) DO UPDATE SET levelup_channel = $4, levelup_enabled = $5", [server_id, channel_id, val, channel_id, val])
  end

  # =========================
  # BOMB CONFIG
  # =========================

  def save_bomb_config(sid, enabled, channel_id, threshold, count)
    val = enabled ? 1 : 0
    @db.exec_params("INSERT INTO server_bombs (server_id, enabled, channel_id, threshold, count) VALUES ($1, $2, $3, $4, $5) ON CONFLICT (server_id) DO UPDATE SET enabled = $6, channel_id = $7, threshold = $8, count = $9", [sid, val, channel_id, threshold, count, val, channel_id, threshold, count])
  end

  def load_all_bomb_configs
    rows = @db.exec("SELECT * FROM server_bombs")
    configs = {}
    rows.each do |row|
      configs[row['server_id'].to_i] = {
        'enabled' => row['enabled'].to_i == 1,
        'channel_id' => row['channel_id'] ? row['channel_id'].to_i : nil,
        'threshold' => row['threshold'].to_i,
        'message_count' => row['count'].to_i,
        'last_user_id' => nil
      }
    end
    configs
  end

  # =========================
  # BLACKLIST
  # =========================

  def toggle_blacklist(uid)
    row = @db.exec_params("SELECT user_id FROM blacklist WHERE user_id = $1", [uid]).first
    if row
      @db.exec_params("DELETE FROM blacklist WHERE user_id = $1", [uid])
      return false
    else
      @db.exec_params("INSERT INTO blacklist (user_id) VALUES ($1)", [uid])
      return true
    end
  end

  def get_blacklist
    @db.exec("SELECT user_id FROM blacklist").map { |row| row['user_id'].to_i }
  end

  # =========================
  # LIFETIME PREMIUM
  # =========================

  def set_lifetime_premium(uid, status)
    if status
      @db.exec_params("INSERT INTO lifetime_premium (user_id) VALUES ($1) ON CONFLICT DO NOTHING", [uid])
    else
      @db.exec_params("DELETE FROM lifetime_premium WHERE user_id = $1", [uid])
    end
  end

  def is_lifetime_premium?(uid)
    row = @db.exec_params("SELECT user_id FROM lifetime_premium WHERE user_id = $1", [uid]).first
    !row.nil?
  end

  # =========================
  # GIVEAWAYS
  # =========================

  def create_giveaway(id, channel_id, message_id, host_id, prize, end_time)
    @db.exec_params("INSERT INTO giveaways (id, channel_id, message_id, host_id, prize, end_time) VALUES ($1, $2, $3, $4, $5, $6)", [id, channel_id, message_id, host_id, prize, end_time])
  end

  def add_giveaway_entrant(gw_id, user_id)
    result = @db.exec_params("INSERT INTO giveaway_entrants (giveaway_id, user_id) VALUES ($1, $2) ON CONFLICT DO NOTHING", [gw_id, user_id])
    result.cmd_tuples > 0 # Returns true if a row was actually inserted
  end

  def get_giveaway_entrants(gw_id)
    @db.exec_params("SELECT user_id FROM giveaway_entrants WHERE giveaway_id = $1", [gw_id]).map { |r| r['user_id'].to_i }
  end

  def get_active_giveaways
    @db.exec("SELECT * FROM giveaways").to_a
  end

  def delete_giveaway(gw_id)
    @db.exec_params("DELETE FROM giveaways WHERE id = $1", [gw_id])
    @db.exec_params("DELETE FROM giveaway_entrants WHERE giveaway_id = $1", [gw_id])
  end

end

DB = BotDatabase.new