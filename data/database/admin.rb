# ==========================================
# MODULE: Database Admin
# DESCRIPTION: Manages server configurations, moderation tools, and giveaways.
# ==========================================

module DatabaseAdmin
  # We use 'public' to ensure the Bot can reach these from the outside.
  public 

  # --- GIVEAWAY MANAGEMENT ---
  def get_active_giveaways
    @db.exec("SELECT * FROM giveaways").to_a
  end

  def add_giveaway_entrant(gw_id, user_id)
    result = @db.exec_params(
      "INSERT INTO giveaway_entrants (giveaway_id, user_id) VALUES ($1, $2) 
       ON CONFLICT DO NOTHING", 
      [gw_id, user_id]
    )
    result.cmd_tuples > 0
  end

  def get_giveaway_entrants(gw_id)
    @db.exec_params("SELECT user_id FROM giveaway_entrants WHERE giveaway_id = $1", [gw_id]).map { |r| r['user_id'].to_i }
  end

  def delete_giveaway(gw_id)
    @db.exec_params("DELETE FROM giveaways WHERE id = $1", [gw_id])
    @db.exec_params("DELETE FROM giveaway_entrants WHERE giveaway_id = $1", [gw_id])
  end

  # --- BOMB CONFIGURATION ---
  def save_bomb_config(sid, enabled, channel_id, threshold, count)
    val = enabled ? 1 : 0
    @db.exec_params(
      "INSERT INTO server_bombs (server_id, enabled, channel_id, threshold, count) 
       VALUES ($1, $2, $3, $4, $5) 
       ON CONFLICT (server_id) DO UPDATE 
       SET enabled = $6, channel_id = $7, threshold = $8, count = $9", 
      [sid, val, channel_id, threshold, count, val, channel_id, threshold, count]
    )
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

  # --- BLACKLIST & PREMIUM ---
  def get_blacklist
    @db.exec("SELECT user_id FROM blacklist").map { |row| row['user_id'].to_i }
  end

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

  def is_lifetime_premium?(uid)
    row = @db.exec_params("SELECT user_id FROM lifetime_premium WHERE user_id = $1", [uid]).first
    !row.nil?
  end

  def set_lifetime_premium(uid, status)
    if status
      @db.exec_params("INSERT INTO lifetime_premium (user_id) VALUES ($1) ON CONFLICT DO NOTHING", [uid])
    else
      @db.exec_params("DELETE FROM lifetime_premium WHERE user_id = $1", [uid])
    end
  end


  # =========================
  # GLOBAL LOTTERY SYSTEM
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
      puts "[DB ERROR] Failed to insert lottery tickets: #{e.message}"
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