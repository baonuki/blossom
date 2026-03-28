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
        'slap' => { 'sent' => row['slap_sent'].to_i, 'received' => row['slap_received'].to_i },
        'pat' => { 'sent' => row['pat_sent'].to_i, 'received' => row['pat_received'].to_i }
      }
    else
      { 'hug' => { 'sent' => 0, 'received' => 0 }, 'slap' => { 'sent' => 0, 'received' => 0 }, 'pat' => { 'sent' => 0, 'received' => 0 } }
    end
  end

  VALID_INTERACTION_COLUMNS = %w[hug_sent hug_received slap_sent slap_received pat_sent pat_received].freeze

  def add_interaction(uid, type, role)
    col = "#{type}_#{role}" # e.g., 'hug_sent' or 'slap_received'
    raise ArgumentError, "Invalid interaction column: #{col}" unless VALID_INTERACTION_COLUMNS.include?(col)
    @db.exec_params(
      "INSERT INTO interactions (user_id, #{col}) VALUES ($1, 1)
       ON CONFLICT (user_id) DO UPDATE SET #{col} = interactions.#{col} + 1",
      [uid]
    )
  end

  # --- REPUTATION ---
  def get_reputation(uid)
    row = @db.exec_params("SELECT reputation FROM global_users WHERE user_id = $1", [uid]).first
    row ? row['reputation'].to_i : 0
  end

  def add_reputation(uid)
    @db.exec_params("INSERT INTO global_users (user_id, reputation) VALUES ($1, 1) ON CONFLICT (user_id) DO UPDATE SET reputation = global_users.reputation + 1", [uid])
  end

  def can_rep?(giver_id, receiver_id)
    row = @db.exec_params("SELECT given_at FROM rep_cooldowns WHERE giver_id = $1 AND receiver_id = $2", [giver_id, receiver_id]).first
    return true unless row
    (Time.now - Time.parse(row['given_at'].to_s)) >= 86_400
  end

  def reps_given_today(giver_id)
    @db.exec_params(
      "SELECT COUNT(*) AS cnt FROM rep_cooldowns WHERE giver_id = $1 AND given_at > $2",
      [giver_id, (Time.now - 86_400).utc.iso8601]
    ).first['cnt'].to_i
  end

  def set_rep_cooldown(giver_id, receiver_id)
    @db.exec_params(
      "INSERT INTO rep_cooldowns (giver_id, receiver_id, given_at) VALUES ($1, $2, $3)
       ON CONFLICT (giver_id, receiver_id) DO UPDATE SET given_at = $3",
      [giver_id, receiver_id, Time.now.utc.iso8601]
    )
  end
end