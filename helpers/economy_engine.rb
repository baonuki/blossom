# ==========================================
# HELPER: Economy & Gacha Engine
# DESCRIPTION: Premium role checks, coin multipliers, 
# and character pool mathematics.
# ==========================================

# Server IDs => Role IDs 
PREMIUM_SERVERS = {
  1125196330646638592 => 1125222184533639338,
  1472509438010065070 => 1477179978004041788
}

def is_premium?(bot, user_id)
  CACHE.fetch(:premium, user_id, ttl: CACHE_TTL_PREMIUM) do
    next true if DB.is_lifetime_premium?(user_id)

    result = false
    PREMIUM_SERVERS.each do |server_id, role_id|
      server = bot.servers[server_id]
      next unless server

      begin
        member = server.member(user_id)
      rescue
        next
      end
      next unless member

      if member.roles.any? { |role| role.id == role_id }
        result = true
        break
      end
    end
    result
  end
end

def award_coins(bot, user_id, amount)
  final_amount = amount
  final_amount = (amount * 1.10).round if is_premium?(bot, user_id)
  
  DB.add_coins(user_id, final_amount)
  final_amount 
end

def roll_rarity(premium = false)
  roll = rand(100)
  premium_table = { common: 55, rare: 36, legendary: 7, goddess: 2 }
  active_table = premium ? premium_table : RARITY_TABLE
  
  total = 0
  active_table.each do |(rarity, weight)|
    total += weight
    return rarity if roll < total
  end
  :common
end

def get_current_banner
  base_pool = Marshal.load(Marshal.dump(UNIVERSAL_POOL))

  if Time.now.month == SPRING_CARNIVAL[:month]
    SPRING_CARNIVAL[:characters].each do |rarity, chars|
      base_pool[:characters][rarity] ||= []
      base_pool[:characters][rarity].concat(chars)
    end
  end
  base_pool
end

# Returns the active banner for a user: custom banner if active, otherwise universal
def get_user_banner(uid)
  custom = DB.get_custom_banner(uid)
  if custom
    return custom
  end
  get_current_banner
end

def find_character_in_pools(search_name, include_event: false)
  if include_event || Time.now.month == SPRING_CARNIVAL[:month]
    SPRING_CARNIVAL[:characters].each do |rarity, char_list|
      found = char_list.find { |c| c[:name].downcase == search_name.downcase }
      return { char: found, rarity: rarity.to_s } if found
    end
  end

  UNIVERSAL_POOL[:characters].each do |rarity, char_list|
    found = char_list.find { |c| c[:name].downcase == search_name.downcase }
    return { char: found, rarity: rarity.to_s } if found
  end
  nil
end

def is_event_character?(search_name)
  SPRING_CARNIVAL[:characters].values.flatten.any? do |char|
    char[:name].downcase == search_name.downcase
  end
end

def find_character_banner(search_name)
  if is_event_character?(search_name)
    return { banner: SPRING_CARNIVAL[:name], event: true }
  end

  UNIVERSAL_POOL[:characters].each do |_rarity, char_list|
    found = char_list.find { |c| c[:name].downcase == search_name.downcase }
    return { banner: UNIVERSAL_POOL[:name], event: false } if found
  end
  nil
end