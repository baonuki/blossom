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
    results = @db.exec_params("SELECT item_name, count FROM inventory WHERE user_id = $1", [uid])
    results.map do |row|
      {
        'item_id' => row['item_name'],
        'quantity' => row['count'].to_i
      }
    end
  end

  def add_inventory(uid, item_name, count)
    @db.exec_params(
      "INSERT INTO inventory (user_id, item_name, count) VALUES ($1, $2, $3) ON CONFLICT (user_id, item_name) DO UPDATE SET count = inventory.count + $3",
      [uid, item_name, count]
    )
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
end
