  def remove_character(uid, name, amount = 1)
    @db.exec_params("UPDATE collections SET count = count - $3 WHERE user_id = $1 AND character_name = $2 AND count >= $3", [uid, name, amount])
    @db.exec_params("DELETE FROM collections WHERE user_id = $1 AND character_name = $2 AND count <= 0", [uid, name])
  end

  public :remove_character
module DatabaseGacha
    # --- SET CARD COUNT ---
    def set_card_count(uid, name, count)
      @db.exec_params("UPDATE collections SET count = $3 WHERE user_id = $1 AND character_name = $2", [uid, name, count])
    end

    public :set_card_count
  def get_collection(uid)
    rows = @db.exec_params("SELECT character_name, rarity, count, ascended FROM collections WHERE user_id = $1", [uid])
    col = {}
    rows.each do |r|
      col[r['character_name']] = { 'rarity' => r['rarity'], 'count' => r['count'].to_i, 'ascended' => r['ascended'].to_i }
    end
    col
  end

  def add_character(uid, name, rarity, amount = 1)
    @db.exec_params("INSERT INTO collections (user_id, character_name, rarity, count, ascended) VALUES ($1, $2, $3, $4, 0) ON CONFLICT (user_id, character_name) DO UPDATE SET count = collections.count + $5", [uid, name, rarity, amount, amount])
  end

  def give_card(from_uid, to_uid, char_name, rarity)
    @db.exec_params("INSERT INTO global_users (user_id, coins) VALUES ($1, 0) ON CONFLICT DO NOTHING", [to_uid])
    @db.exec_params("UPDATE collections SET count = count - 1 WHERE user_id = $1 AND character_name = $2", [from_uid, char_name])
    @db.exec_params("INSERT INTO collections (user_id, character_name, rarity, count, ascended) VALUES ($1, $2, $3, 1, 0) ON CONFLICT (user_id, character_name) DO UPDATE SET count = collections.count + 1", [to_uid, char_name, rarity])
  end

  def ascend_character(uid, name)
    @db.exec_params("UPDATE collections SET count = count - 5, ascended = ascended + 1 WHERE user_id = $1 AND character_name = $2", [uid, name])
  end
end