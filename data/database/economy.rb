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
end