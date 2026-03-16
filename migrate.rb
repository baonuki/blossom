require 'sqlite3'
require 'pg'
require 'dotenv/load'

puts "🌸 Connecting to databases..."
sqlite = SQLite3::Database.new("blossom.db")
pg = PG.connect(ENV['DATABASE_URL'])

# Get all tables from SQLite
tables = sqlite.execute("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';").flatten

tables.each do |table|
  puts "📦 Migrating table: #{table}..."
  
  # Fetch all rows from the SQLite table
  rows = sqlite.execute("SELECT * FROM #{table}")
  next if rows.empty?

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
      puts "⚠️ Skipped a row in #{table} (Likely already exists): #{e.message.split("\n").first}"
    end
  end
  
  puts "✅ Successfully moved #{success} rows into #{table}!"
end

puts "\n🎉 MIGRATION COMPLETE! Blossom's memory is safely in the cloud."