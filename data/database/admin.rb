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
    CACHE.fetch(:log_config, server_id, ttl: CACHE_TTL_SERVER_CFG) do
      row = @db.exec_params("SELECT * FROM server_logs WHERE server_id = $1", [server_id]).first
      next nil unless row
      {
        'log_channel' => row['log_channel'] ? row['log_channel'].to_i : nil,
        'log_deletes' => row['log_deletes'].to_i == 1,
        'log_edits' => row['log_edits'].to_i == 1,
        'log_mod' => row['log_mod'].to_i == 1,
        'log_joins' => row['log_joins'].to_i == 1,
        'log_leaves' => row['log_leaves'].to_i == 1
      }
    end
  end

  def set_log_channel(server_id, channel_id)
    @db.exec_params(
      "INSERT INTO server_logs (server_id, log_channel) VALUES ($1, $2) ON CONFLICT (server_id) DO UPDATE SET log_channel = $2",
      [server_id, channel_id]
    )
    CACHE.invalidate(:log_config, server_id)
  end

  def toggle_log_setting(server_id, column)
    valid_columns = %w[log_deletes log_edits log_mod dm_mods log_joins log_leaves]
    raise ArgumentError, "Invalid log column" unless valid_columns.include?(column)

    @db.exec_params("INSERT INTO server_logs (server_id) VALUES ($1) ON CONFLICT (server_id) DO NOTHING", [server_id])
    @db.exec_params("UPDATE server_logs SET #{column} = 1 - COALESCE(#{column}, 0) WHERE server_id = $1", [server_id])

    CACHE.invalidate(:log_config, server_id)
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

  # --- ACHIEVEMENT NOTIFICATIONS ---
  def achievements_enabled?(server_id)
    CACHE.fetch(:ach_enabled, server_id, ttl: CACHE_TTL_SERVER_CFG) do
      row = @db.exec_params("SELECT achievements_enabled FROM server_configs WHERE server_id = $1", [server_id]).first
      row ? row['achievements_enabled'].to_i == 1 : false
    end
  end

  def toggle_achievements(server_id)
    @db.exec_params("INSERT INTO server_configs (server_id, achievements_enabled) VALUES ($1, 0) ON CONFLICT (server_id) DO NOTHING", [server_id])
    @db.exec_params("UPDATE server_configs SET achievements_enabled = 1 - COALESCE(achievements_enabled, 0) WHERE server_id = $1", [server_id])
    CACHE.invalidate(:ach_enabled, server_id)
    row = @db.exec_params("SELECT achievements_enabled FROM server_configs WHERE server_id = $1", [server_id]).first
    row && row['achievements_enabled'].to_i == 1
  end

  # --- WELCOMER CONFIGURATION ---
  def get_welcome_config(server_id)
    row = @db.exec_params("SELECT welcome_channel, welcome_enabled FROM server_configs WHERE server_id = $1", [server_id]).first
    return { enabled: false, channel: nil } unless row
    {
      enabled: row['welcome_enabled'].to_i == 1,
      channel: row['welcome_channel'] ? row['welcome_channel'].to_i : nil
    }
  end

  def set_welcome_config(server_id, channel_id, enabled)
    val = enabled ? 1 : 0
    @db.exec_params(
      "INSERT INTO server_configs (server_id, welcome_channel, welcome_enabled) VALUES ($1, $2, $3) " \
      "ON CONFLICT (server_id) DO UPDATE SET welcome_channel = $2, welcome_enabled = $3",
      [server_id, channel_id, val]
    )
  end

  # --- WELCOME MESSAGE CUSTOMIZATION ---
  def get_welcome_message(server_id)
    row = @db.exec_params("SELECT welcome_message FROM server_configs WHERE server_id = $1", [server_id]).first
    row ? row['welcome_message'] : nil
  end

  def set_welcome_message(server_id, text)
    @db.exec_params(
      "INSERT INTO server_configs (server_id, welcome_message) VALUES ($1, $2) ON CONFLICT (server_id) DO UPDATE SET welcome_message = $2",
      [server_id, text]
    )
  end

  # --- REACTION ROLES ---
  def add_reaction_role(server_id, message_id, emoji, role_id)
    @db.exec_params(
      "INSERT INTO reaction_roles (server_id, message_id, emoji, role_id) VALUES ($1, $2, $3, $4) ON CONFLICT (server_id, message_id, emoji) DO UPDATE SET role_id = $4",
      [server_id, message_id, emoji, role_id]
    )
  end

  def get_reaction_role(server_id, message_id, emoji)
    row = @db.exec_params("SELECT role_id FROM reaction_roles WHERE server_id = $1 AND message_id = $2 AND emoji = $3", [server_id, message_id, emoji]).first
    row ? row['role_id'].to_i : nil
  end

  def get_reaction_roles_for_message(server_id, message_id)
    @db.exec_params("SELECT emoji, role_id FROM reaction_roles WHERE server_id = $1 AND message_id = $2", [server_id, message_id]).to_a
  end

  def remove_reaction_role(server_id, message_id, emoji)
    @db.exec_params("DELETE FROM reaction_roles WHERE server_id = $1 AND message_id = $2 AND emoji = $3", [server_id, message_id, emoji])
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

  # --- AUTO-MOD CONFIGURATION ---
  def get_automod_config(server_id)
    row = @db.exec_params("SELECT link_filter, spam_filter FROM automod_config WHERE server_id = $1", [server_id]).first
    return { 'link_filter' => false, 'spam_filter' => false } unless row
    { 'link_filter' => row['link_filter'].to_i == 1, 'spam_filter' => row['spam_filter'].to_i == 1 }
  end

  def toggle_automod_setting(server_id, setting)
    raise ArgumentError unless %w[link_filter spam_filter].include?(setting)
    @db.exec_params("INSERT INTO automod_config (server_id) VALUES ($1) ON CONFLICT (server_id) DO NOTHING", [server_id])
    @db.exec_params("UPDATE automod_config SET #{setting} = 1 - COALESCE(#{setting}, 0) WHERE server_id = $1", [server_id])
    row = @db.exec_params("SELECT #{setting} FROM automod_config WHERE server_id = $1", [server_id]).first
    row && row[setting].to_i == 1
  end

  def get_automod_words(server_id)
    @db.exec_params("SELECT word FROM automod_words WHERE server_id = $1", [server_id]).map { |r| r['word'] }
  end

  def add_automod_word(server_id, word)
    @db.exec_params("INSERT INTO automod_words (server_id, word) VALUES ($1, $2) ON CONFLICT DO NOTHING", [server_id, word.downcase])
  end

  def remove_automod_word(server_id, word)
    @db.exec_params("DELETE FROM automod_words WHERE server_id = $1 AND word = $2", [server_id, word.downcase])
  end

  # --- HEIST CONFIGURATION ---
  def get_heist_channel(server_id)
    row = @db.exec_params("SELECT heist_channel FROM server_configs WHERE server_id = $1", [server_id]).first
    row && row['heist_channel'] ? row['heist_channel'].to_i : nil
  end

  def set_heist_channel(server_id, channel_id)
    @db.exec_params(
      "INSERT INTO server_configs (server_id, heist_channel) VALUES ($1, $2) ON CONFLICT (server_id) DO UPDATE SET heist_channel = $2",
      [server_id, channel_id]
    )
  end

  def get_all_heist_channels
    @db.exec("SELECT server_id, heist_channel FROM server_configs WHERE heist_channel IS NOT NULL").to_a
  end

  # --- BOSS BATTLES ---
  def get_current_boss(month, year)
    row = @db.exec_params(
      "SELECT * FROM boss_battles WHERE month = $1 AND year = $2 ORDER BY id DESC LIMIT 1",
      [month, year]
    ).first
    return nil unless row
    {
      'id' => row['id'].to_i, 'boss_name' => row['boss_name'],
      'max_hp' => row['max_hp'].to_i, 'current_hp' => row['current_hp'].to_i,
      'defeated' => row['defeated'].to_i == 1, 'channel_id' => row['channel_id'] ? row['channel_id'].to_i : nil
    }
  end

  def create_boss(name, hp, month, year)
    @db.exec_params(
      "INSERT INTO boss_battles (boss_name, max_hp, current_hp, month, year) VALUES ($1, $2, $2, $3, $4) RETURNING id",
      [name, hp, month, year]
    ).first['id'].to_i
  end

  def boss_attack(boss_id, uid, damage)
    # Update boss HP
    @db.exec_params("UPDATE boss_battles SET current_hp = GREATEST(current_hp - $2, 0) WHERE id = $1", [boss_id, damage])
    # Track participant
    @db.exec_params(
      "INSERT INTO boss_participants (boss_id, user_id, total_damage, last_attack) VALUES ($1, $2, $3, NOW()) " \
      "ON CONFLICT (boss_id, user_id) DO UPDATE SET total_damage = boss_participants.total_damage + $3, last_attack = NOW()",
      [boss_id, uid, damage]
    )
    # Return new HP
    row = @db.exec_params("SELECT current_hp FROM boss_battles WHERE id = $1", [boss_id]).first
    row['current_hp'].to_i
  end

  def boss_defeat(boss_id)
    @db.exec_params("UPDATE boss_battles SET defeated = 1 WHERE id = $1", [boss_id])
  end

  def get_boss_participants(boss_id)
    @db.exec_params(
      "SELECT user_id, total_damage FROM boss_participants WHERE boss_id = $1 ORDER BY total_damage DESC",
      [boss_id]
    ).to_a
  end

  def get_boss_participant(boss_id, uid)
    @db.exec_params(
      "SELECT total_damage, last_attack FROM boss_participants WHERE boss_id = $1 AND user_id = $2",
      [boss_id, uid]
    ).first
  end

  def get_boss_channel(server_id)
    row = @db.exec_params("SELECT boss_channel FROM server_configs WHERE server_id = $1", [server_id]).first
    row && row['boss_channel'] ? row['boss_channel'].to_i : nil
  end

  def set_boss_channel(server_id, channel_id)
    @db.exec_params(
      "INSERT INTO server_configs (server_id, boss_channel) VALUES ($1, $2) ON CONFLICT (server_id) DO UPDATE SET boss_channel = $2",
      [server_id, channel_id]
    )
  end
end
