# ==========================================
# MODULE: Database Crews, Friendships, Crafting, Challenges
# DESCRIPTION: Social systems, crafting materials, and weekly challenges.
# ==========================================

module DatabaseCrews
  public

  # ==========================================
  # CREWS
  # ==========================================
  def create_crew(name, tag, leader_id)
    row = @db.exec_params(
      "INSERT INTO crews (name, tag, leader_id) VALUES ($1, $2, $3) RETURNING id",
      [name, tag.upcase, leader_id]
    ).first
    crew_id = row['id'].to_i
    @db.exec_params(
      "INSERT INTO crew_members (crew_id, user_id, role) VALUES ($1, $2, 'leader')",
      [crew_id, leader_id]
    )
    crew_id
  end

  def get_crew(crew_id)
    row = @db.exec_params("SELECT * FROM crews WHERE id = $1", [crew_id]).first
    return nil unless row
    {
      'id' => row['id'].to_i, 'name' => row['name'], 'tag' => row['tag'],
      'leader_id' => row['leader_id'].to_i, 'crew_xp' => row['crew_xp'].to_i,
      'crew_level' => row['crew_level'].to_i, 'created_at' => row['created_at']
    }
  end

  def get_user_crew(uid)
    row = @db.exec_params(
      "SELECT c.*, cm.role FROM crew_members cm JOIN crews c ON c.id = cm.crew_id WHERE cm.user_id = $1", [uid]
    ).first
    return nil unless row
    {
      'id' => row['id'].to_i, 'name' => row['name'], 'tag' => row['tag'],
      'leader_id' => row['leader_id'].to_i, 'crew_xp' => row['crew_xp'].to_i,
      'crew_level' => row['crew_level'].to_i, 'role' => row['role']
    }
  end

  def get_crew_members(crew_id)
    @db.exec_params(
      "SELECT user_id, role, joined_at FROM crew_members WHERE crew_id = $1 ORDER BY role ASC, joined_at ASC", [crew_id]
    ).to_a
  end

  def add_crew_member(crew_id, uid)
    @db.exec_params("INSERT INTO crew_members (crew_id, user_id) VALUES ($1, $2) ON CONFLICT DO NOTHING", [crew_id, uid])
  end

  def remove_crew_member(crew_id, uid)
    @db.exec_params("DELETE FROM crew_members WHERE crew_id = $1 AND user_id = $2", [crew_id, uid])
  end

  def set_crew_role(crew_id, uid, role)
    @db.exec_params("UPDATE crew_members SET role = $3 WHERE crew_id = $1 AND user_id = $2", [crew_id, uid, role])
  end

  def transfer_crew_leader(crew_id, new_leader_id)
    @db.exec_params("UPDATE crews SET leader_id = $2 WHERE id = $1", [crew_id, new_leader_id])
    @db.exec_params("UPDATE crew_members SET role = 'member' WHERE crew_id = $1 AND role = 'leader'", [crew_id])
    @db.exec_params("UPDATE crew_members SET role = 'leader' WHERE crew_id = $1 AND user_id = $2", [crew_id, new_leader_id])
  end

  def disband_crew(crew_id)
    @db.exec_params("DELETE FROM crew_members WHERE crew_id = $1", [crew_id])
    @db.exec_params("DELETE FROM crews WHERE id = $1", [crew_id])
  end

  def add_crew_xp(crew_id, amount)
    @db.exec_params("UPDATE crews SET crew_xp = crew_xp + $2 WHERE id = $1", [crew_id, amount])
  end

  def set_crew_level(crew_id, level)
    @db.exec_params("UPDATE crews SET crew_level = $2 WHERE id = $1", [crew_id, level])
  end

  def get_crew_count(crew_id)
    row = @db.exec_params("SELECT COUNT(*) AS cnt FROM crew_members WHERE crew_id = $1", [crew_id]).first
    row['cnt'].to_i
  end

  def get_top_crews(limit = 10)
    @db.exec_params("SELECT * FROM crews ORDER BY crew_xp DESC LIMIT $1", [limit]).to_a
  end

  # ==========================================
  # FRIENDSHIPS
  # ==========================================
  def get_friendship(uid_a, uid_b)
    a, b = [uid_a, uid_b].sort
    row = @db.exec_params("SELECT affinity, last_interaction FROM friendships WHERE user_a = $1 AND user_b = $2", [a, b]).first
    return { 'affinity' => 0, 'last_interaction' => nil } unless row
    { 'affinity' => row['affinity'].to_i, 'last_interaction' => row['last_interaction'] }
  end

  def add_affinity(uid_a, uid_b, amount)
    a, b = [uid_a, uid_b].sort
    @db.exec_params(
      "INSERT INTO friendships (user_a, user_b, affinity, last_interaction) VALUES ($1, $2, $3, NOW()) " \
      "ON CONFLICT (user_a, user_b) DO UPDATE SET affinity = friendships.affinity + $3, last_interaction = NOW()",
      [a, b, amount]
    )
  end

  def get_top_friends(uid, limit = 10)
    @db.exec_params(
      "SELECT CASE WHEN user_a = $1 THEN user_b ELSE user_a END AS friend_id, affinity " \
      "FROM friendships WHERE user_a = $1 OR user_b = $1 ORDER BY affinity DESC LIMIT $2",
      [uid, limit]
    ).to_a
  end

  # ==========================================
  # CRAFTING MATERIALS
  # ==========================================
  def get_materials(uid)
    rows = @db.exec_params("SELECT material, count FROM user_materials WHERE user_id = $1", [uid])
    mats = {}
    rows.each { |r| mats[r['material']] = r['count'].to_i }
    mats
  end

  def add_material(uid, material, amount)
    @db.exec_params(
      "INSERT INTO user_materials (user_id, material, count) VALUES ($1, $2, $3) " \
      "ON CONFLICT (user_id, material) DO UPDATE SET count = user_materials.count + $3",
      [uid, material, amount]
    )
  end

  def remove_material(uid, material, amount)
    @db.exec_params("UPDATE user_materials SET count = count - $3 WHERE user_id = $1 AND material = $2", [uid, material, amount])
    @db.exec_params("DELETE FROM user_materials WHERE user_id = $1 AND material = $2 AND count <= 0", [uid, material])
  end

  def has_materials?(uid, requirements)
    mats = get_materials(uid)
    requirements.all? { |mat, amt| (mats[mat] || 0) >= amt }
  end

  # ==========================================
  # WEEKLY CHALLENGES
  # ==========================================
  def get_weekly_challenges(week_start)
    row = @db.exec_params("SELECT challenges_json FROM weekly_challenges WHERE week_start = $1", [week_start.to_s]).first
    return nil unless row
    JSON.parse(row['challenges_json'])
  end

  def set_weekly_challenges(week_start, challenges)
    json = JSON.generate(challenges)
    @db.exec_params(
      "INSERT INTO weekly_challenges (week_start, challenges_json) VALUES ($1, $2) ON CONFLICT (week_start) DO UPDATE SET challenges_json = $2",
      [week_start.to_s, json]
    )
  end

  def get_challenge_progress(uid, week_start)
    row = @db.exec_params(
      "SELECT progress_json, claimed FROM user_challenge_progress WHERE user_id = $1 AND week_start = $2",
      [uid, week_start.to_s]
    ).first
    return { 'progress' => {}, 'claimed' => false } unless row
    { 'progress' => JSON.parse(row['progress_json']), 'claimed' => row['claimed'].to_i == 1 }
  end

  def update_challenge_progress(uid, week_start, type, amount)
    existing = get_challenge_progress(uid, week_start)
    progress = existing['progress']
    progress[type] = (progress[type] || 0) + amount
    json = JSON.generate(progress)
    @db.exec_params(
      "INSERT INTO user_challenge_progress (user_id, week_start, progress_json) VALUES ($1, $2, $3) " \
      "ON CONFLICT (user_id, week_start) DO UPDATE SET progress_json = $3",
      [uid, week_start.to_s, json]
    )
  end

  def mark_challenges_claimed(uid, week_start)
    @db.exec_params(
      "UPDATE user_challenge_progress SET claimed = 1 WHERE user_id = $1 AND week_start = $2",
      [uid, week_start.to_s]
    )
  end

  # ==========================================
  # TIP CHANNEL
  # ==========================================
  def get_tip_channel(server_id)
    row = @db.exec_params("SELECT tip_channel FROM server_configs WHERE server_id = $1", [server_id]).first
    row && row['tip_channel'] ? row['tip_channel'].to_i : nil
  end

  def set_tip_channel(server_id, channel_id)
    @db.exec_params(
      "INSERT INTO server_configs (server_id, tip_channel) VALUES ($1, $2) ON CONFLICT (server_id) DO UPDATE SET tip_channel = $2",
      [server_id, channel_id]
    )
  end

  def get_all_tip_channels
    @db.exec("SELECT server_id, tip_channel FROM server_configs WHERE tip_channel IS NOT NULL").to_a
  end
end
