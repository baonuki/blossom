# ==========================================
# MODULE: Database Gacha
# DESCRIPTION: Handles character collections, trading, and ascension.
# ==========================================

module DatabaseGacha
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

  def remove_character(uid, name, amount = 1)
    @db.exec_params("UPDATE collections SET count = count - $3 WHERE user_id = $1 AND character_name = $2 AND count >= $3", [uid, name, amount])
    # Only delete the row if BOTH count and ascended are 0 (preserve ascension data)
    @db.exec_params("DELETE FROM collections WHERE user_id = $1 AND character_name = $2 AND count <= 0 AND ascended <= 0", [uid, name])
  end

  def set_card_count(uid, name, count)
    @db.exec_params("UPDATE collections SET count = $3 WHERE user_id = $1 AND character_name = $2", [uid, name, count])
  end

  def get_favorite_card(uid)
    row = @db.exec_params("SELECT favorite_card FROM global_users WHERE user_id = $1", [uid]).first
    row ? row['favorite_card'] : nil
  end

  def set_favorite_card(uid, name)
    @db.exec_params("INSERT INTO global_users (user_id, favorite_card) VALUES ($1, $2) ON CONFLICT (user_id) DO UPDATE SET favorite_card = $2", [uid, name])
  end

  def get_pity(uid)
    row = @db.exec_params("SELECT pity_counter FROM global_users WHERE user_id = $1", [uid]).first
    row ? row['pity_counter'].to_i : 0
  end

  def increment_pity(uid)
    @db.exec_params("UPDATE global_users SET pity_counter = pity_counter + 1 WHERE user_id = $1", [uid])
  end

  def reset_pity(uid)
    @db.exec_params("UPDATE global_users SET pity_counter = 0 WHERE user_id = $1", [uid])
  end

  # --- PREMIUM PROFILE ---
  def get_profile(uid)
    CACHE.fetch(:profile, uid, ttl: CACHE_TTL_PROFILE) do
      row = @db.exec_params("SELECT profile_color, bio, favorite_card, favorite_card_2, favorite_card_3 FROM global_users WHERE user_id = $1", [uid]).first
      if row
        {
          'color' => row['profile_color'],
          'bio' => row['bio'],
          'favorites' => [row['favorite_card'], row['favorite_card_2'], row['favorite_card_3']].compact
        }
      else
        { 'color' => nil, 'bio' => nil, 'favorites' => [] }
      end
    end
  end

  def set_profile_color(uid, hex)
    @db.exec_params("INSERT INTO global_users (user_id, profile_color) VALUES ($1, $2) ON CONFLICT (user_id) DO UPDATE SET profile_color = $2", [uid, hex])
    CACHE.invalidate(:profile, uid)
  end

  def set_profile_bio(uid, text)
    @db.exec_params("INSERT INTO global_users (user_id, bio) VALUES ($1, $2) ON CONFLICT (user_id) DO UPDATE SET bio = $2", [uid, text])
    CACHE.invalidate(:profile, uid)
  end

  def set_favorite_card_slot(uid, slot, name)
    col = case slot
          when 1 then 'favorite_card'
          when 2 then 'favorite_card_2'
          when 3 then 'favorite_card_3'
          end
    @db.exec_params("INSERT INTO global_users (user_id, #{col}) VALUES ($1, $2) ON CONFLICT (user_id) DO UPDATE SET #{col} = $2", [uid, name])
    CACHE.invalidate(:profile, uid)
  end

  def clear_favorite_slot(uid, slot)
    set_favorite_card_slot(uid, slot, nil)
  end

  # --- COSMETICS: PET, TITLE, THEME, BADGES ---
  def get_cosmetics(uid)
    CACHE.fetch(:cosmetics, uid, ttl: CACHE_TTL_COSMETICS) do
      row = @db.exec_params("SELECT pet, title, collection_theme, equipped_badge FROM global_users WHERE user_id = $1", [uid]).first
      if row
        { 'pet' => row['pet'], 'title' => row['title'], 'theme' => row['collection_theme'] || 'default', 'badge' => row['equipped_badge'] }
      else
        { 'pet' => nil, 'title' => nil, 'theme' => 'default', 'badge' => nil }
      end
    end
  end

  def set_pet(uid, pet_id)
    @db.exec_params("INSERT INTO global_users (user_id, pet) VALUES ($1, $2) ON CONFLICT (user_id) DO UPDATE SET pet = $2", [uid, pet_id])
    CACHE.invalidate(:cosmetics, uid)
  end

  def set_title(uid, title_id)
    @db.exec_params("INSERT INTO global_users (user_id, title) VALUES ($1, $2) ON CONFLICT (user_id) DO UPDATE SET title = $2", [uid, title_id])
    CACHE.invalidate(:cosmetics, uid)
  end

  def set_collection_theme(uid, theme_id)
    @db.exec_params("INSERT INTO global_users (user_id, collection_theme) VALUES ($1, $2) ON CONFLICT (user_id) DO UPDATE SET collection_theme = $2", [uid, theme_id])
    CACHE.invalidate(:cosmetics, uid)
  end

  def set_equipped_badge(uid, badge_id)
    @db.exec_params("INSERT INTO global_users (user_id, equipped_badge) VALUES ($1, $2) ON CONFLICT (user_id) DO UPDATE SET equipped_badge = $2", [uid, badge_id])
    CACHE.invalidate(:cosmetics, uid)
  end

  def unlock_badge(uid, badge_id)
    result = @db.exec_params("INSERT INTO user_badges (user_id, badge_id, unlocked_at) VALUES ($1, $2, $3) ON CONFLICT DO NOTHING", [uid, badge_id, Time.now.utc.iso8601])
    result.cmd_tuples > 0
  end

  def get_badges(uid)
    @db.exec_params("SELECT badge_id, unlocked_at FROM user_badges WHERE user_id = $1", [uid]).to_a
  end

  def has_badge?(uid, badge_id)
    row = @db.exec_params("SELECT 1 FROM user_badges WHERE user_id = $1 AND badge_id = $2", [uid, badge_id]).first
    !row.nil?
  end

  # --- CUSTOM BANNERS ---
  def get_custom_banner(uid)
    row = @db.exec_params("SELECT characters_json, expires_at FROM custom_banners WHERE user_id = $1", [uid]).first
    return nil unless row

    expires = Time.parse(row['expires_at'])
    if expires <= Time.now
      @db.exec_params("DELETE FROM custom_banners WHERE user_id = $1", [uid])
      return nil
    end

    chars = JSON.parse(row['characters_json'], symbolize_names: true)
    # Rebuild the banner structure with full character data from UNIVERSAL_POOL
    banner = { name: '🎯 Custom Banner', characters: { common: [], rare: [], legendary: [], goddess: [] }, expires_at: expires }
    chars.each do |rarity_str, names|
      rarity = rarity_str.to_sym
      names.each do |name|
        found = UNIVERSAL_POOL[:characters][rarity]&.find { |c| c[:name] == name }
        banner[:characters][rarity] << found if found
      end
    end
    banner
  end

  def set_custom_banner(uid, characters_hash, duration_seconds = 3600)
    expires = Time.now + duration_seconds
    json = JSON.generate(characters_hash)
    @db.exec_params(
      "INSERT INTO custom_banners (user_id, characters_json, expires_at) VALUES ($1, $2, $3) ON CONFLICT (user_id) DO UPDATE SET characters_json = $2, expires_at = $3",
      [uid, json, expires]
    )
  end

  def clear_custom_banner(uid)
    @db.exec_params("DELETE FROM custom_banners WHERE user_id = $1", [uid])
  end
end
