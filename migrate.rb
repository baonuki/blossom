require 'sqlite3'
require 'pg'
require 'dotenv/load'

puts "🌸 Connecting to databases..."
sqlite = SQLite3::Database.new("blossom.db", readonly: true)
pg = PG.connect(ENV['DATABASE_URL'])

puts "🏗️ Building empty Postgres tables..."
pg.exec(<<-SQL)
  CREATE TABLE IF NOT EXISTS server_settings (server_id BIGINT PRIMARY KEY, levelup_enabled INTEGER DEFAULT 1);
  CREATE TABLE IF NOT EXISTS blacklist (user_id BIGINT PRIMARY KEY);
  CREATE TABLE IF NOT EXISTS global_users (user_id BIGINT PRIMARY KEY, coins INTEGER DEFAULT 0, daily_at TIMESTAMP, work_at TIMESTAMP, stream_at TIMESTAMP, post_at TIMESTAMP, collab_at TIMESTAMP, summon_at TIMESTAMP);
  CREATE TABLE IF NOT EXISTS inventory (user_id BIGINT, item_name VARCHAR(255), count INTEGER DEFAULT 0, PRIMARY KEY(user_id, item_name));
  CREATE TABLE IF NOT EXISTS collections (user_id BIGINT, character_name VARCHAR(255), rarity VARCHAR(50), count INTEGER DEFAULT 0, ascended INTEGER DEFAULT 0, PRIMARY KEY(user_id, character_name));
  CREATE TABLE IF NOT EXISTS server_xp (server_id BIGINT, user_id BIGINT, xp INTEGER DEFAULT 0, level INTEGER DEFAULT 1, last_xp_at TIMESTAMP, PRIMARY KEY(server_id, user_id));
  CREATE TABLE IF NOT EXISTS interactions (user_id BIGINT PRIMARY KEY, hug_sent INTEGER DEFAULT 0, hug_received INTEGER DEFAULT 0, slap_sent INTEGER DEFAULT 0, slap_received INTEGER DEFAULT 0);
  CREATE TABLE IF NOT EXISTS server_configs (server_id BIGINT PRIMARY KEY, levelup_channel BIGINT, levelup_enabled INTEGER);
  CREATE TABLE IF NOT EXISTS server_bombs (server_id BIGINT PRIMARY KEY, enabled INTEGER, channel_id BIGINT, threshold INTEGER, count INTEGER);
  CREATE TABLE IF NOT EXISTS lifetime_premium (user_id BIGINT PRIMARY KEY);
  CREATE TABLE IF NOT EXISTS giveaways (id VARCHAR(255) PRIMARY KEY, channel_id BIGINT, message_id BIGINT, host_id BIGINT, prize TEXT, end_time BIGINT);
  CREATE TABLE IF NOT EXISTS giveaway_entrants (giveaway_id VARCHAR(255), user_id BIGINT, UNIQUE(giveaway_id, user_id));
SQL

# Get all tables from SQLite
tables = sqlite.execute("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';").flatten

tables.each do |table|
  puts "📦 Migrating table: #{table}..."
  
  # Fetch all rows from the SQLite table
  rows = sqlite.execute("SELECT * FROM #{table}")
  if rows.empty?
    puts "   Table is empty, skipping!"
    next 
  end

  # Get the column names dynamically
  columns = sqlite.execute("PRAGMA table_info(#{table})").map { |col| col[1] }
  col_names = columns.join(", ")
  
  # Create the Postgres placeholders ($1, $2, $3...)
  placeholders = columns.map.with_index { |_, i| "$#{i + 1}" }.join(", ")

  # Insert each row into Postgres
  success = 0
  rows.each do |row|
    begin
      pg.exec_params("INSERT INTO #{table} (#{col_names}) VALUES (#{placeholders})", row)
      success += 1
    rescue => e
      puts "⚠️ Skipped a row in #{table}: #{e.message.split("\n").first}"
    end
  end
  
  puts "✅ Successfully moved #{success} rows into #{table}!"
end

puts "\n🎉 MIGRATION COMPLETE! Blossom's memory is safely in the cloud."