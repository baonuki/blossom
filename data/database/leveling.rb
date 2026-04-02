# ==========================================
# MODULE: Database Leveling
# DESCRIPTION: Handles user XP, server leveling, and community levels.
# ==========================================

module DatabaseLeveling
  # --- USER LEVELING ---
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

  # --- LEVEL-UP CONFIG ---
  def get_levelup_config(sid)
    CACHE.fetch(:levelup_cfg, sid, ttl: CACHE_TTL_SERVER_CFG) do
      row = @db.exec_params("SELECT levelup_channel, levelup_enabled FROM server_configs WHERE server_id = $1", [sid]).first
      if row
        { channel: row['levelup_channel'] ? row['levelup_channel'].to_i : nil, enabled: row['levelup_enabled'].to_i == 1 }
      else
        { channel: nil, enabled: true }
      end
    end
  end

  def set_levelup_config(sid, channel_id, enabled)
    val = enabled ? 1 : 0
    @db.exec_params(
      "INSERT INTO server_configs (server_id, levelup_channel, levelup_enabled) VALUES ($1, $2, $3) ON CONFLICT (server_id) DO UPDATE SET levelup_channel = $2, levelup_enabled = $3",
      [sid, channel_id, val]
    )
    CACHE.invalidate(:levelup_cfg, sid)
  end

  # --- COMMUNITY (SERVER) LEVELING ---
  def get_community_level(server_id)
    result = @db.exec_params("SELECT xp, level FROM community_levels WHERE server_id = $1", [server_id]).to_a
    result.empty? ? { 'xp' => 0, 'level' => 1 } : result[0]
  end

  def update_community_level(server_id, server_name, new_xp, new_level)
    @db.exec_params("INSERT INTO community_levels (server_id, server_name, xp, level) VALUES ($1, $2, $3, $4) ON CONFLICT (server_id) DO UPDATE SET server_name = EXCLUDED.server_name, xp = EXCLUDED.xp, level = EXCLUDED.level", [server_id, server_name, new_xp, new_level])
  end

  # --- COMMUNITY LEVEL-UP ANNOUNCEMENT TOGGLE ---
  def toggle_community_levelup(server_id)
    begin
      @db.exec("ALTER TABLE community_levels ADD COLUMN IF NOT EXISTS announce_enabled INTEGER DEFAULT 0")
    rescue PG::Error
    end

    @db.exec_params("INSERT INTO community_levels (server_id) VALUES ($1) ON CONFLICT (server_id) DO NOTHING", [server_id])
    @db.exec_params("UPDATE community_levels SET announce_enabled = 1 - COALESCE(announce_enabled, 0) WHERE server_id = $1", [server_id])

    row = @db.exec_params("SELECT announce_enabled FROM community_levels WHERE server_id = $1", [server_id]).first
    row && row['announce_enabled'].to_i == 1
  end

  def get_community_announce_enabled(server_id)
    row = @db.exec_params("SELECT announce_enabled FROM community_levels WHERE server_id = $1", [server_id]).first
    row && row['announce_enabled'].to_i == 1
  rescue PG::Error
    false
  end

  # --- ACTIVITY STREAKS ---
  def get_chat_streak(sid, uid)
    row = @db.exec_params("SELECT chat_streak, last_chat_date FROM server_xp WHERE server_id = $1 AND user_id = $2", [sid, uid]).first
    if row
      { 'streak' => row['chat_streak'].to_i, 'last_date' => row['last_chat_date'] }
    else
      { 'streak' => 0, 'last_date' => nil }
    end
  end

  def update_chat_streak(sid, uid, streak, date_str)
    @db.exec_params(
      "UPDATE server_xp SET chat_streak = $3, last_chat_date = $4 WHERE server_id = $1 AND user_id = $2",
      [sid, uid, streak, date_str]
    )
  end

  # --- LEADERBOARD: Top Users by XP/Level ---
  def get_top_users(server_id, limit = 50)
    @db.exec_params("SELECT user_id, xp, level FROM server_xp WHERE server_id = $1 ORDER BY level DESC, xp DESC LIMIT $2", [server_id, limit]).to_a
  end

  # --- LEADERBOARD: Global Server Leaderboard ---
  def get_global_server_leaderboard(limit = 10)
    @db.exec_params("SELECT server_id, server_name, xp, level FROM community_levels ORDER BY xp DESC, level DESC LIMIT $1", [limit]).to_a
  end
end
