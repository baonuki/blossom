# ==========================================
# MODULE: Database Schema
# DESCRIPTION: Defines the table structures and handles migrations.
# ==========================================

module DatabaseSchema # <--- Changed from 'class' to 'module'
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

      CREATE TABLE IF NOT EXISTS user_prisma (
        user_id BIGINT PRIMARY KEY,
        balance INTEGER DEFAULT 0
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

      CREATE TABLE IF NOT EXISTS community_levels (
        server_id BIGINT PRIMARY KEY,
        xp INTEGER DEFAULT 0,
        level INTEGER DEFAULT 1
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

      CREATE TABLE IF NOT EXISTS user_achievements (
        user_id BIGINT,
        achievement_id VARCHAR(50),
        unlocked_at TIMESTAMP,
        PRIMARY KEY(user_id, achievement_id)
      );
    SQL

    # Migration checks
    begin; @db.exec("ALTER TABLE global_users ADD COLUMN IF NOT EXISTS daily_streak INTEGER DEFAULT 0"); rescue PG::Error; end
    begin; @db.exec("ALTER TABLE global_users ADD COLUMN IF NOT EXISTS reminder_channel BIGINT"); rescue PG::Error; end
    begin; @db.exec("ALTER TABLE global_users ADD COLUMN IF NOT EXISTS reminder_sent INTEGER DEFAULT 0"); rescue PG::Error; end
    begin; @db.exec("ALTER TABLE server_logs ADD COLUMN IF NOT EXISTS dm_mods INTEGER DEFAULT 1"); rescue PG::Error; end
    begin; @db.exec("ALTER TABLE server_configs ADD COLUMN IF NOT EXISTS verify_channel BIGINT"); rescue PG::Error; end
    begin; @db.exec("ALTER TABLE server_configs ADD COLUMN IF NOT EXISTS verify_role BIGINT"); rescue PG::Error; end
    begin; @db.exec("ALTER TABLE community_levels ADD COLUMN IF NOT EXISTS server_name TEXT DEFAULT 'Unknown Arcade'"); rescue PG::Error; end
    begin; @db.exec("ALTER TABLE global_users ADD COLUMN IF NOT EXISTS tickets INTEGER DEFAULT 0"); rescue PG::Error; end
    begin; @db.exec("ALTER TABLE global_users ADD COLUMN IF NOT EXISTS favorite_card VARCHAR(255)"); rescue PG::Error; end
    begin; @db.exec("ALTER TABLE server_configs ADD COLUMN IF NOT EXISTS achievements_enabled INTEGER DEFAULT 0"); rescue PG::Error; end
    begin; @db.exec("ALTER TABLE interactions ADD COLUMN IF NOT EXISTS pat_sent INTEGER DEFAULT 0"); rescue PG::Error; end
    begin; @db.exec("ALTER TABLE interactions ADD COLUMN IF NOT EXISTS pat_received INTEGER DEFAULT 0"); rescue PG::Error; end
    begin; @db.exec("ALTER TABLE server_configs ADD COLUMN IF NOT EXISTS welcome_channel BIGINT"); rescue PG::Error; end
    begin; @db.exec("ALTER TABLE server_configs ADD COLUMN IF NOT EXISTS welcome_enabled INTEGER DEFAULT 0"); rescue PG::Error; end
    begin; @db.exec("ALTER TABLE server_logs ADD COLUMN IF NOT EXISTS log_joins INTEGER DEFAULT 0"); rescue PG::Error; end
    begin; @db.exec("ALTER TABLE server_logs ADD COLUMN IF NOT EXISTS log_leaves INTEGER DEFAULT 0"); rescue PG::Error; end
    begin; @db.exec("ALTER TABLE global_users ADD COLUMN IF NOT EXISTS pity_counter INTEGER DEFAULT 0"); rescue PG::Error; end
    begin; @db.exec("ALTER TABLE global_users ADD COLUMN IF NOT EXISTS reputation INTEGER DEFAULT 0"); rescue PG::Error; end

    @db.exec(<<-SQL)
      CREATE TABLE IF NOT EXISTS rep_cooldowns (
        giver_id BIGINT,
        receiver_id BIGINT,
        given_at TIMESTAMP,
        PRIMARY KEY(giver_id, receiver_id)
      );
    SQL
  end # Closes 'def setup_schema'
end # Closes 'module DatabaseSchema'