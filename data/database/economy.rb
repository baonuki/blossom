# ==========================================
# MODULE: Database Economy
# DESCRIPTION: Handles coins, inventory, prisma, and tickets.
# ==========================================

module DatabaseEconomy
  # --- COINS ---
  def get_coins(uid)
    row = @db.exec_params("SELECT coins FROM global_users WHERE user_id = $1", [uid]).first
    row ? row['coins'].to_i : 0
  end

  def add_coins(uid, amount)
    @db.exec_params("INSERT INTO global_users (user_id, coins) VALUES ($1, $2) ON CONFLICT (user_id) DO UPDATE SET coins = global_users.coins + $3", [uid, amount, amount])
  end

  def set_coins(uid, amount)
    @db.exec_params("INSERT INTO global_users (user_id, coins) VALUES ($1, $2) ON CONFLICT (user_id) DO UPDATE SET coins = $3", [uid, amount, amount])
  end

  # --- INVENTORY ---
  def get_inventory(uid)
    CACHE.fetch(:inventory, uid, ttl: CACHE_TTL_INVENTORY) do
      results = @db.exec_params("SELECT item_name, count FROM inventory WHERE user_id = $1", [uid])
      results.map do |row|
        {
          'item_id' => row['item_name'],
          'quantity' => row['count'].to_i
        }
      end
    end
  end

  def add_inventory(uid, item_name, count)
    @db.exec_params(
      "INSERT INTO inventory (user_id, item_name, count) VALUES ($1, $2, $3) ON CONFLICT (user_id, item_name) DO UPDATE SET count = inventory.count + $3",
      [uid, item_name, count]
    )
    CACHE.invalidate(:inventory, uid)
  end

  def remove_inventory(uid, item_name, count)
    @db.exec_params(
      "UPDATE inventory SET count = count - $3 WHERE user_id = $1 AND item_name = $2",
      [uid, item_name, count]
    )
    @db.exec_params(
      "DELETE FROM inventory WHERE user_id = $1 AND item_name = $2 AND count <= 0",
      [uid, item_name]
    )
    CACHE.invalidate(:inventory, uid)
  end

  # --- TICKETS (Event Currency) ---
  def get_tickets(uid)
    row = @db.exec_params("SELECT tickets FROM global_users WHERE user_id = $1", [uid]).first
    row ? row['tickets'].to_i : 0
  end

  def add_tickets(uid, amount)
    @db.exec_params("INSERT INTO global_users (user_id, coins, tickets) VALUES ($1, 0, $2) ON CONFLICT (user_id) DO UPDATE SET tickets = global_users.tickets + $3", [uid, amount, amount])
  end

  # --- PRISMA (Premium Currency) ---
  def get_prisma(uid)
    result = @db.exec_params("SELECT balance FROM user_prisma WHERE user_id = $1", [uid]).to_a
    result.empty? ? 0 : result[0]['balance'].to_i
  end

  def add_prisma(uid, amount)
    @db.exec_params("INSERT INTO user_prisma (user_id, balance) VALUES ($1, $2) ON CONFLICT (user_id) DO UPDATE SET balance = user_prisma.balance + $3", [uid, amount, amount])
  end

  def set_prisma(uid, amount)
    @db.exec_params("INSERT INTO user_prisma (user_id, balance) VALUES ($1, $2) ON CONFLICT (user_id) DO UPDATE SET balance = $2", [uid, amount])
  end

  # --- LEADERBOARD: Top Users by Coins ---
  def get_top_coins(limit = 10)
    @db.exec_params("SELECT user_id, coins FROM global_users ORDER BY coins DESC LIMIT $1", [limit]).to_a
  end

  # --- ACHIEVEMENT TRACKING COUNTERS ---
  def increment_pull_count(uid)
    @db.exec_params("INSERT INTO global_users (user_id, pull_count) VALUES ($1, 1) ON CONFLICT (user_id) DO UPDATE SET pull_count = global_users.pull_count + 1 RETURNING pull_count", [uid]).first['pull_count'].to_i
  end

  def increment_trade_count(uid)
    @db.exec_params("INSERT INTO global_users (user_id, trade_count) VALUES ($1, 1) ON CONFLICT (user_id) DO UPDATE SET trade_count = global_users.trade_count + 1 RETURNING trade_count", [uid]).first['trade_count'].to_i
  end

  def increment_givecard_count(uid)
    @db.exec_params("INSERT INTO global_users (user_id, givecard_count) VALUES ($1, 1) ON CONFLICT (user_id) DO UPDATE SET givecard_count = global_users.givecard_count + 1 RETURNING givecard_count", [uid]).first['givecard_count'].to_i
  end

  def add_coins_given(uid, amount)
    @db.exec_params("INSERT INTO global_users (user_id, coins_given_total) VALUES ($1, $2) ON CONFLICT (user_id) DO UPDATE SET coins_given_total = global_users.coins_given_total + $2 RETURNING coins_given_total", [uid, amount]).first['coins_given_total'].to_i
  end

  def set_last_pull_rarity(uid, rarity)
    @db.exec_params("UPDATE global_users SET last_pull_rarity = $2 WHERE user_id = $1", [uid, rarity])
  end

  def get_last_pull_rarity(uid)
    row = @db.exec_params("SELECT last_pull_rarity FROM global_users WHERE user_id = $1", [uid]).first
    row ? row['last_pull_rarity'] : nil
  end

  def get_tracking_stats(uid)
    row = @db.exec_params("SELECT pull_count, trade_count, givecard_count, coins_given_total FROM global_users WHERE user_id = $1", [uid]).first
    if row
      { 'pull_count' => row['pull_count'].to_i, 'trade_count' => row['trade_count'].to_i, 'givecard_count' => row['givecard_count'].to_i, 'coins_given_total' => row['coins_given_total'].to_i }
    else
      { 'pull_count' => 0, 'trade_count' => 0, 'givecard_count' => 0, 'coins_given_total' => 0 }
    end
  end

  # --- ARCADE TRACKING ---
  def increment_arcade_wins(uid)
    @db.exec_params("INSERT INTO global_users (user_id, arcade_wins) VALUES ($1, 1) ON CONFLICT (user_id) DO UPDATE SET arcade_wins = global_users.arcade_wins + 1", [uid])
  end

  def increment_arcade_losses(uid)
    @db.exec_params("INSERT INTO global_users (user_id, arcade_losses) VALUES ($1, 1) ON CONFLICT (user_id) DO UPDATE SET arcade_losses = global_users.arcade_losses + 1", [uid])
  end

  def get_arcade_stats(uid)
    row = @db.exec_params("SELECT arcade_wins, arcade_losses FROM global_users WHERE user_id = $1", [uid]).first
    if row
      { 'wins' => row['arcade_wins'].to_i, 'losses' => row['arcade_losses'].to_i }
    else
      { 'wins' => 0, 'losses' => 0 }
    end
  end

  # --- USER PREFERENCES ---
  def get_ach_notify(uid)
    row = @db.exec_params("SELECT ach_notify FROM global_users WHERE user_id = $1", [uid]).first
    row ? (row['ach_notify'] || 'channel') : 'channel'
  end

  def set_ach_notify(uid, mode)
    @db.exec_params("INSERT INTO global_users (user_id, ach_notify) VALUES ($1, $2) ON CONFLICT (user_id) DO UPDATE SET ach_notify = $2", [uid, mode])
  end

  def get_autosell(uid)
    row = @db.exec_params("SELECT autosell_enabled FROM global_users WHERE user_id = $1", [uid]).first
    row ? row['autosell_enabled'].to_i == 1 : false
  end

  def toggle_autosell(uid)
    @db.exec_params("INSERT INTO global_users (user_id, autosell_enabled) VALUES ($1, 1) ON CONFLICT (user_id) DO UPDATE SET autosell_enabled = CASE WHEN global_users.autosell_enabled = 1 THEN 0 ELSE 1 END", [uid])
    get_autosell(uid)
  end

  def get_shiny_mode(uid)
    row = @db.exec_params("SELECT shiny_mode FROM global_users WHERE user_id = $1", [uid]).first
    row ? row['shiny_mode'].to_i == 1 : false
  end

  def toggle_shiny_mode(uid)
    @db.exec_params("INSERT INTO global_users (user_id, shiny_mode) VALUES ($1, 1) ON CONFLICT (user_id) DO UPDATE SET shiny_mode = CASE WHEN global_users.shiny_mode = 1 THEN 0 ELSE 1 END", [uid])
    get_shiny_mode(uid)
  end

  # --- INVESTMENTS (Premium Passive Income) ---
  def get_investment(uid)
    row = @db.exec_params("SELECT principal, invested_at FROM investments WHERE user_id = $1", [uid]).first
    return nil unless row
    { 'principal' => row['principal'].to_i, 'invested_at' => Time.parse(row['invested_at']) }
  end

  def create_investment(uid, amount)
    @db.exec_params(
      "INSERT INTO investments (user_id, principal, invested_at) VALUES ($1, $2, NOW()) ON CONFLICT (user_id) DO UPDATE SET principal = $2, invested_at = NOW()",
      [uid, amount]
    )
  end

  def delete_investment(uid)
    @db.exec_params("DELETE FROM investments WHERE user_id = $1", [uid])
  end

  # --- FULL STATS (for /stats dashboard) ---
  def get_full_stats(uid)
    row = @db.exec_params(
      "SELECT coins, daily_streak, pull_count, trade_count, givecard_count, coins_given_total, reputation, autosell_enabled, shiny_mode FROM global_users WHERE user_id = $1", [uid]
    ).first
    if row
      { 'coins' => row['coins'].to_i, 'daily_streak' => row['daily_streak'].to_i, 'pull_count' => row['pull_count'].to_i,
        'trade_count' => row['trade_count'].to_i, 'givecard_count' => row['givecard_count'].to_i,
        'coins_given_total' => row['coins_given_total'].to_i, 'reputation' => row['reputation'].to_i,
        'autosell_enabled' => row['autosell_enabled'].to_i, 'shiny_mode' => row['shiny_mode'].to_i }
    else
      { 'coins' => 0, 'daily_streak' => 0, 'pull_count' => 0, 'trade_count' => 0, 'givecard_count' => 0, 'coins_given_total' => 0, 'reputation' => 0, 'autosell_enabled' => 0, 'shiny_mode' => 0 }
    end
  end
end
