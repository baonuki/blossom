# ==========================================
# MODULE: Database Social
# DESCRIPTION: Handles achievements and user-to-user interaction stats.
# ==========================================

module DatabaseSocial
  # --- ACHIEVEMENTS ---
  def unlock_achievement(uid, ach_id)
    result = @db.exec_params(
      "INSERT INTO user_achievements (user_id, achievement_id, unlocked_at) 
       VALUES ($1, $2, $3) ON CONFLICT DO NOTHING", 
      [uid, ach_id, Time.now.utc.iso8601]
    )
    result.cmd_tuples > 0 # Returns true if a new trophy was actually unlocked
  end

  def get_achievements(uid)
    @db.exec_params("SELECT achievement_id, unlocked_at FROM user_achievements WHERE user_id = $1", [uid]).to_a
  end

  # --- INTERACTION STATS (Hugs/Slaps) ---
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
    col = "#{type}_#{role}" # e.g., 'hug_sent' or 'slap_received'
    @db.exec_params(
      "INSERT INTO interactions (user_id, #{col}) VALUES ($1, 1) 
       ON CONFLICT (user_id) DO UPDATE SET #{col} = interactions.#{col} + 1", 
      [uid]
    )
  end
end