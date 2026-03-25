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
  return true if DB.is_lifetime_premium?(user_id)

  PREMIUM_SERVERS.each do |server_id, role_id|
    server = bot.server(server_id)
    next unless server

    member = server.members.find { |m| m.id == user_id }
    next unless member

    return true if member.roles.any? { |role| role.id == role_id }
  end
  false
end

def award_coins(bot, user_id, amount)
  final_amount = amount
  final_amount = (amount * 1.10).round if is_premium?(bot, user_id)
  
  DB.add_coins(user_id, final_amount)
  final_amount 
end

def roll_rarity(premium = false)
  roll = rand(100)
  premium_table = { common: 42, rare: 41, legendary: 15, goddess: 2 }
  active_table = premium ? premium_table : RARITY_TABLE
  
  total = 0
  active_table.each do |(rarity, weight)|
    total += weight
    return rarity if roll < total
  end
  :common
end

def get_current_banner
  week_number = Time.now.to_i / 604_800 
  available_pools = CHARACTER_POOLS.keys
  active_key = available_pools[week_number % available_pools.size]
  
  base_pool = Marshal.load(Marshal.dump(CHARACTER_POOLS[active_key]))

  if Time.now.month == SPRING_CARNIVAL[:month]
    SPRING_CARNIVAL[:characters].each do |rarity, chars|
      base_pool[:characters][rarity] ||= []
      base_pool[:characters][rarity].concat(chars)
    end
  end
  base_pool
end

def find_character_in_pools(search_name)
  if Time.now.month == SPRING_CARNIVAL[:month]
    SPRING_CARNIVAL[:characters].each do |rarity, char_list|
      found = char_list.find { |c| c[:name].downcase == search_name.downcase }
      return { char: found, rarity: rarity.to_s } if found
    end
  end

  CHARACTER_POOLS.values.each do |pool|
    pool[:characters].each do |rarity, char_list|
      found = char_list.find { |c| c[:name].downcase == search_name.downcase }
      return { char: found, rarity: rarity.to_s } if found
    end
  end
  nil
end

def is_event_character?(search_name)
  SPRING_CARNIVAL[:characters].values.flatten.any? do |char|
    char[:name].downcase == search_name.downcase
  end
end