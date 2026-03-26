# ==========================================
# MODULE: Database Cooldowns
# DESCRIPTION: Handles daily claims, streaks, and reminders.
# ==========================================

module DatabaseCooldowns
  # Force all methods below this to be accessible by the bot
  public 

  # --- DAILY INFO & CLAIM ---
  def get_daily_info(uid)
    row = @db.exec_params("SELECT daily_at, daily_streak, reminder_channel, reminder_sent FROM global_users WHERE user_id = $1", [uid]).first
    if row
      {
        'at' => row['daily_at'] ? Time.parse(row['daily_at']) : nil,
        'streak' => row['daily_streak'].to_i,
        'channel' => row['reminder_channel'] ? row['reminder_channel'].to_i : nil,
        'sent' => row['reminder_sent'].to_i == 1
      }
    else
      { 'at' => nil, 'streak' => 0, 'channel' => nil, 'sent' => false }
    end
  end

  def update_daily_claim(uid, streak, time_obj)
    time_str = time_obj.iso8601
    @db.exec_params(
      "INSERT INTO global_users (user_id, coins, daily_streak, reminder_sent, daily_at) 
       VALUES ($1, 0, $2, 0, $3) 
       ON CONFLICT (user_id) DO UPDATE 
       SET daily_streak = $2, reminder_sent = 0, daily_at = $3", 
      [uid, streak, time_str]
    )
  end

  # --- GENERAL COOLDOWNS ---
  VALID_COOLDOWN_TYPES = %w[daily work stream post collab summon].freeze

  def get_cooldown(uid, type)
    raise ArgumentError, "Invalid cooldown type: #{type}" unless VALID_COOLDOWN_TYPES.include?(type.to_s)
    column = "#{type}_at"
    row = @db.exec_params("SELECT #{column} FROM global_users WHERE user_id = $1", [uid]).first
    return nil unless row && row[column]
    Time.parse(row[column])
  end

  def set_cooldown(uid, type, time_obj)
    raise ArgumentError, "Invalid cooldown type: #{type}" unless VALID_COOLDOWN_TYPES.include?(type.to_s)
    column = "#{type}_at"
    time_str = time_obj ? time_obj.iso8601 : nil
    @db.exec_params("INSERT INTO global_users (user_id, coins) VALUES ($1, 0) ON CONFLICT DO NOTHING", [uid])
    @db.exec_params("UPDATE global_users SET #{column} = $2 WHERE user_id = $1", [uid, time_str])
  end

  # --- DAILY REMINDERS ---
  def get_pending_daily_reminders
    query = "SELECT user_id, reminder_channel FROM global_users 
             WHERE reminder_channel IS NOT NULL 
             AND reminder_sent = 0 
             AND daily_at <= NOW() - INTERVAL '24 hours'"
    @db.exec(query).to_a
  end

  def mark_reminder_sent(uid)
    @db.exec_params("UPDATE global_users SET reminder_sent = 1 WHERE user_id = $1", [uid])
  end

  def toggle_daily_reminder(uid, channel_id)
    row = @db.exec_params("SELECT reminder_channel FROM global_users WHERE user_id = $1", [uid]).first
    
    if row && row['reminder_channel'] && channel_id.nil?
      @db.exec_params("UPDATE global_users SET reminder_channel = NULL, reminder_sent = 0 WHERE user_id = $1", [uid])
      return false
    else
      @db.exec_params("INSERT INTO global_users (user_id, coins) VALUES ($1, 0) ON CONFLICT DO NOTHING", [uid])
      @db.exec_params("UPDATE global_users SET reminder_channel = $2, reminder_sent = 0 WHERE user_id = $1", [uid, channel_id])
      return true
    end
  end
end