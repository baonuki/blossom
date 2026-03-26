# ==========================================
# MODULE: Database Admin
# DESCRIPTION: Manages server configurations, moderation tools, and giveaways.
# ==========================================

module DatabaseAdmin
  # --- GIVEAWAY MANAGEMENT ---
  def create_giveaway(id, channel_id, message_id, host_id, prize, end_time)
    @db.exec_params("INSERT INTO giveaways (id, channel_id, message_id, host_id, prize, end_time) VALUES ($1, $2, $3, $4, $5, $6)", [id, channel_id, message_id, host_id, prize, end_time])
  end

  def get_active_giveaways
    @db.exec("SELECT * FROM giveaways").to_a
  end

  def add_giveaway_entrant(gw_id, user_id)
    result = @db.exec_params(
      "INSERT INTO giveaway_entrants (giveaway_id, user_id) VALUES ($1, $2) ON CONFLICT DO NOTHING",
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

  # --- LOGGING CONFIGURATION ---
  def get_log_config(server_id)
    row = @db.exec_params("SELECT * FROM server_logs WHERE server_id = $1", [server_id]).first
    return nil unless row
    {
      'log_channel' => row['log_channel'] ? row['log_channel'].to_i : nil,
      'log_deletes' => row['log_deletes'].to_i == 1,
      'log_edits' => row['log_edits'].to_i == 1,
      'log_mod' => row['log_mod'].to_i == 1
    }
  end

  def set_log_channel(server_id, channel_id)
    @db.exec_params(
      "INSERT INTO server_logs (server_id, log_channel) VALUES ($1, $2) ON CONFLICT (server_id) DO UPDATE SET log_channel = $2",
      [server_id, channel_id]
    )
  end

  def toggle_log_setting(server_id, column)
    valid_columns = %w[log_deletes log_edits log_mod dm_mods]
    raise ArgumentError, "Invalid log column" unless valid_columns.include?(column)

    @db.exec_params("INSERT INTO server_logs (server_id) VALUES ($1) ON CONFLICT (server_id) DO NOTHING", [server_id])
    @db.exec_params("UPDATE server_logs SET #{column} = 1 - COALESCE(#{column}, 0) WHERE server_id = $1", [server_id])

    row = @db.exec_params("SELECT #{column} FROM server_logs WHERE server_id = $1", [server_id]).first
    row && row[column].to_i == 1
  end

  # --- SERVER VERIFICATION ---
  def set_verification(server_id, channel_id, role_id)
    @db.exec_params(
      "INSERT INTO server_configs (server_id, verify_channel, verify_role) VALUES ($1, $2, $3) " \
      "ON CONFLICT (server_id) DO UPDATE SET verify_channel = $2, verify_role = $3",
      [server_id, channel_id, role_id]
    )
  end

  def get_verify_role(server_id)
    row = @db.exec_params("SELECT verify_role FROM server_configs WHERE server_id = $1", [server_id]).first
    row && row['verify_role'] ? row['verify_role'].to_i : nil
  end

  # --- BOMB CONFIGURATION ---
  def save_bomb_config(sid, enabled, channel_id, threshold, count)
    val = enabled ? 1 : 0
    @db.exec_params(
      "INSERT INTO server_bombs (server_id, enabled, channel_id, threshold, count) VALUES ($1, $2, $3, $4, $5) ON CONFLICT (server_id) DO UPDATE SET enabled = $6, channel_id = $7, threshold = $8, count = $9",
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

  # --- GLOBAL LOTTERY SYSTEM ---
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
