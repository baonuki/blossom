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

  # --- COMMUNITY (SERVER) LEVELING ---
  def get_community_level(server_id)
    result = @db.exec_params("SELECT xp, level FROM community_levels WHERE server_id = $1", [server_id]).to_a
    result.empty? ? { 'xp' => 0, 'level' => 1 } : result[0]
  end

  def update_community_level(server_id, server_name, new_xp, new_level)
    @db.exec_params("INSERT INTO community_levels (server_id, server_name, xp, level) VALUES ($1, $2, $3, $4) ON CONFLICT (server_id) DO UPDATE SET server_name = EXCLUDED.server_name, xp = EXCLUDED.xp, level = EXCLUDED.level", [server_id, server_name, new_xp, new_level])
  end
end