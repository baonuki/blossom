require 'pg'
require 'time'
require 'connection_pool'

class PGPoolWrapper
  def initialize(url)
    @pool = ConnectionPool.new(size: 20, timeout: 5) { PG.connect(url) }
  end

  def exec(*args)
    @pool.with { |conn| conn.exec(*args) }
  end

  def exec_params(*args)
    @pool.with { |conn| conn.exec_params(*args) }
  end
end

class BotDatabase
  def initialize
    @db = PGPoolWrapper.new(ENV['DATABASE_URL'])
    
    setup_schema
  end

  def setup_schema
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

      CREATE TABLE IF NOT EXISTS server_logs (
        server_id BIGINT PRIMARY KEY,
        log_channel BIGINT,
        log_deletes INTEGER DEFAULT 0,
        log_edits INTEGER DEFAULT 0,
        log_mod INTEGER DEFAULT 0
      );

      CREATE TABLE IF NOT EXISTS giveaway_entrants (
        giveaway_id VARCHAR(255), 
        user_id BIGINT, 
        UNIQUE(giveaway_id, user_id)
      );

      CREATE TABLE IF NOT EXISTS lottery (
        id SERIAL PRIMARY KEY,
        user_id BIGINT
      );
    SQL

    begin; @db.exec("ALTER TABLE global_users ADD COLUMN daily_streak INTEGER DEFAULT 0"); rescue PG::Error; end
    begin; @db.exec("ALTER TABLE global_users ADD COLUMN reminder_channel BIGINT"); rescue PG::Error; end
    begin; @db.exec("ALTER TABLE global_users ADD COLUMN reminder_sent INTEGER DEFAULT 0"); rescue PG::Error; end
    begin; @db.exec("ALTER TABLE server_logs ADD COLUMN dm_mods INTEGER DEFAULT 1"); rescue PG::Error; end
    
    begin; @db.exec("ALTER TABLE server_configs ADD COLUMN verify_channel BIGINT"); rescue PG::Error; end
    begin; @db.exec("ALTER TABLE server_configs ADD COLUMN verify_role BIGINT"); rescue PG::Error; end
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

  def give_card(from_uid, to_uid, char_name, rarity)
    @db.exec_params("INSERT INTO global_users (user_id, coins) VALUES ($1, 0) ON CONFLICT DO NOTHING", [to_uid])
    
    @db.exec_params(
      "UPDATE collections SET count = count - 1 WHERE user_id = $1 AND character_name = $2", 
      [from_uid, char_name]
    )
    
    @db.exec_params(
      "INSERT INTO collections (user_id, character_name, rarity, count, ascended) 
       VALUES ($1, $2, $3, 1, 0) 
       ON CONFLICT (user_id, character_name) 
       DO UPDATE SET count = collections.count + 1", 
      [to_uid, char_name, rarity]
    )
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

  def get_daily_info(uid)
    row = @db.exec_params("SELECT daily_at, daily_streak, reminder_channel, reminder_sent FROM global_users WHERE user_id = $1", [uid]).first
    if row
      {
        'at' => row['daily_at'] ? Time.parse(row['daily_at']) : nil,
        'streak' => row['daily_streak'].to_i,
        'channel' => row['reminder_channel'] ? row['reminder_channel'].to_i : nil,
        'sent' => row['reminder_sent'].to_i == 1
      }
    else
      { 'at' => nil, 'streak' => 0, 'channel' => nil, 'sent' => false }
    end
  end

  def update_daily_claim(uid, streak, time_obj)
    time_str = time_obj.iso8601
    @db.exec_params(
      "INSERT INTO global_users (user_id, coins, daily_streak, reminder_sent, daily_at) 
       VALUES ($1, 0, $2, 0, $3) 
       ON CONFLICT (user_id) DO UPDATE 
       SET daily_streak = $2, reminder_sent = 0, daily_at = $3", 
      [uid, streak, time_str]
    )
  end

  def toggle_daily_reminder(uid, channel_id)
    row = @db.exec_params("SELECT reminder_channel FROM global_users WHERE user_id = $1", [uid]).first
    
    if row && row['reminder_channel'] && channel_id.nil?
      @db.exec_params("UPDATE global_users SET reminder_channel = NULL, reminder_sent = 0 WHERE user_id = $1", [uid])
      return false
    else
      @db.exec_params("INSERT INTO global_users (user_id, coins) VALUES ($1, 0) ON CONFLICT DO NOTHING", [uid])
      @db.exec_params("UPDATE global_users SET reminder_channel = $2, reminder_sent = 0 WHERE user_id = $1", [uid, channel_id])
      return true
    end
  end

  def get_pending_daily_reminders
    query = "SELECT user_id, reminder_channel FROM global_users 
             WHERE reminder_channel IS NOT NULL 
             AND reminder_sent = 0 
             AND daily_at <= NOW() - INTERVAL '24 hours'"
    @db.exec(query).to_a
  end

  def mark_reminder_sent(uid)
    @db.exec_params("UPDATE global_users SET reminder_sent = 1 WHERE user_id = $1", [uid])
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

  def set_card_count(uid, char_name, new_count)
    @db.exec_params(
      "UPDATE collections SET count = $1 WHERE user_id = $2 AND character_name = $3", 
      [new_count, uid, char_name]
    )
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

  def get_log_config(server_id)
    row = @db.exec_params("SELECT * FROM server_logs WHERE server_id = $1", [server_id]).first
    if row
      {
        channel: row['log_channel'] ? row['log_channel'].to_i : nil,
        deletes: row['log_deletes'].to_i == 1,
        edits: row['log_edits'].to_i == 1,
        mod: row['log_mod'].to_i == 1,
        dm_mods: row['dm_mods'].to_i == 1
      }
    else
      @db.exec_params("INSERT INTO server_logs (server_id) VALUES ($1) ON CONFLICT DO NOTHING", [server_id])
      { channel: nil, deletes: false, edits: false, mod: false, dm_mods: true } # <--- And add dm_mods here!
    end
  end

  def set_log_channel(server_id, channel_id)
    @db.exec_params(
      "INSERT INTO server_logs (server_id, log_channel) VALUES ($1, $2) 
       ON CONFLICT (server_id) DO UPDATE SET log_channel = $2", 
      [server_id, channel_id]
    )
  end

  def toggle_log_setting(server_id, setting)
    current = @db.exec_params("SELECT #{setting} FROM server_logs WHERE server_id = $1", [server_id]).first
    
    if current
      new_val = current[setting].to_i == 1 ? 0 : 1
      @db.exec_params("UPDATE server_logs SET #{setting} = $1 WHERE server_id = $2", [new_val, server_id])
      return new_val == 1
    end
    false
  end

  def set_verification(sid, cid, rid)
    @db.exec_params(
      "INSERT INTO server_configs (server_id, verify_channel, verify_role) VALUES ($1, $2, $3) 
       ON CONFLICT (server_id) DO UPDATE SET verify_channel = $2, verify_role = $3", 
      [sid, cid, rid]
    )
  end

  def get_verify_role(sid)
    row = @db.exec_params("SELECT verify_role FROM server_configs WHERE server_id = $1", [sid]).first
    row && row['verify_role'] ? row['verify_role'].to_i : nil
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

  # =========================
  # GLOBAL LOTTERY
  # =========================

  def enter_lottery(uid, tickets)
    @db.exec("BEGIN")
    begin
      tickets.times do
        @db.exec_params("INSERT INTO lottery (user_id) VALUES ($1)", [uid])
      end
      @db.exec("COMMIT")
    rescue => e
      @db.exec("ROLLBACK")
      puts "[DB ERROR] Failed to insert tickets: #{e.message}"
    end
  end

  def get_lottery_entries
    @db.exec("SELECT user_id FROM lottery").map { |row| row['user_id'].to_i }
  end

  def clear_lottery
    @db.exec("DELETE FROM lottery")
  end

  def get_lottery_stats(uid)
    all_rows = @db.exec("SELECT user_id FROM lottery").to_a
    user_tickets = all_rows.count { |r| r['user_id'].to_i == uid }
    { total_tickets: all_rows.size, user_tickets: user_tickets }
  end

end

DB = BotDatabase.new