# ==========================================
# HELPER: Achievement System
# DESCRIPTION: Validates, grants, and formats achievements.
# ==========================================

# MERGED: Intelligently accepts either an Event or a direct Channel object!
def check_achievement(channel_or_event, uid, ach_id, silent: false)
  return false unless ACHIEVEMENTS.key?(ach_id)
  
  if DB.unlock_achievement(uid, ach_id)
    data = ACHIEVEMENTS[ach_id]
    DB.add_coins(uid, data[:reward]) 
    
    unless silent || channel_or_event.nil?
      embed = Discordrb::Webhooks::Embed.new(
        title: "🏆 Achievement Unlocked!",
        description: "**#{data[:emoji]} #{data[:name]}**\n> #{data[:desc]}\n\n*Reward: **#{data[:reward]}** #{EMOJIS['s_coin'] || '🪙'}*",
        color: 0xFFD700
      )
      
      # Route appropriately if it's an event or raw channel
      if channel_or_event.respond_to?(:channel)
        channel_or_event.channel.send_message(nil, false, embed) rescue nil
      else
        channel_or_event.send_message(nil, false, embed) rescue nil
      end
    end
    return true 
  end
  false
end

def generate_achievements_page(username, uid, page)
  unlocked_data = DB.get_achievements(uid)
  unlocked_ids = unlocked_data.map { |row| row['achievement_id'] }
  per_page = 5 
  
  embed = Discordrb::Webhooks::Embed.new(
    title: "🏆 Achievement Showcase",
    color: 0xFFD700
  )
  
  desc = "**#{username}'s Unlocked Trophies**\n*Unlocked: #{unlocked_ids.size} / #{ACHIEVEMENTS.size}*\n\n"
  
  if unlocked_ids.empty?
    desc += "*You haven't unlocked any achievements yet! Keep playing!*"
    embed.description = desc
    return [embed, 1]
  end

  total_pages = (unlocked_ids.size / per_page.to_f).ceil
  page = 1 if page < 1
  page = total_pages if page > total_pages
  
  start_idx = (page - 1) * per_page
  page_keys = unlocked_ids[start_idx, per_page]
  
  page_keys.each do |ach_id|
    data = ACHIEVEMENTS[ach_id]
    time_str = unlocked_data.find { |r| r['achievement_id'] == ach_id }['unlocked_at']
    timestamp = "<t:#{Time.parse(time_str).to_i}:d>"
    
    desc += "#{data[:emoji]} **#{data[:name]}**\n> #{data[:desc]}\n> *Unlocked on #{timestamp}*\n\n"
  end
  
  embed.description = desc.strip
  [embed, total_pages]
end

def sync_user_achievements(uid, channel = nil)
  unlocked_count = 0

  # 1. Wealth & Tickets
  coins = DB.get_coins(uid)
  unlocked_count += 1 if coins == 0 && check_achievement(channel, uid, 'wealth_0', silent: true)
  unlocked_count += 1 if coins >= 10_000 && check_achievement(channel, uid, 'wealth_10k', silent: true)
  unlocked_count += 1 if coins >= 100_000 && check_achievement(channel, uid, 'wealth_100k', silent: true)
  unlocked_count += 1 if coins >= 1_000_000 && check_achievement(channel, uid, 'wealth_1m', silent: true)
  unlocked_count += 1 if coins >= 10_000_000 && check_achievement(channel, uid, 'wealth_10m', silent: true)

  tickets = DB.get_tickets(uid)
  unlocked_count += 1 if tickets >= 1000 && check_achievement(channel, uid, 'tickets_1k', silent: true)
  unlocked_count += 1 if tickets >= 5000 && check_achievement(channel, uid, 'tickets_5k', silent: true)

  # 2. Daily Streak
  streak = DB.get_daily_info(uid)['streak']
  unlocked_count += 1 if streak >= 7 && check_achievement(channel, uid, 'streak_7', silent: true)
  unlocked_count += 1 if streak >= 30 && check_achievement(channel, uid, 'streak_30', silent: true)
  unlocked_count += 1 if streak >= 69 && check_achievement(channel, uid, 'streak_69', silent: true)
  unlocked_count += 1 if streak >= 100 && check_achievement(channel, uid, 'streak_100', silent: true)
  unlocked_count += 1 if streak >= 365 && check_achievement(channel, uid, 'streak_365', silent: true)

  # 3. Inventory (Upgrades & Consumables)
  inv_arr = DB.get_inventory(uid)
  # Convert array of { 'item_id' => ..., 'quantity' => ... } to a hash { item_id => quantity }
  inv = inv_arr.is_a?(Array) ? inv_arr.each_with_object({}) { |row, h| h[row['item_id']] = row['quantity'] } : (inv_arr || {})
  upgrades = inv.keys.select { |item| ['headset', 'keyboard', 'mic', 'neon sign', 'gacha pass'].any? { |k| item.downcase.include?(k) } && inv[item] > 0 }
  consumables_total = inv.reject { |item, _| upgrades.include?(item) }.values.sum
  
  unlocked_count += 1 if upgrades.size >= 1 && check_achievement(channel, uid, 'buy_upgrade', silent: true)
  unlocked_count += 1 if upgrades.size >= 5 && check_achievement(channel, uid, 'max_upgrades', silent: true)
  unlocked_count += 1 if consumables_total >= 10 && check_achievement(channel, uid, 'hoard_10_cons', silent: true)

  # 4. Collection (Counts, Rarities, Ascensions)
  col = DB.get_collection(uid)
  unless col.empty?
    unlocked_count += 1 if check_achievement(channel, uid, 'first_pull', silent: true)
    
    unique_total = col.keys.size
    unlocked_count += 1 if unique_total >= 10 && check_achievement(channel, uid, 'coll_10', silent: true)
    unlocked_count += 1 if unique_total >= 50 && check_achievement(channel, uid, 'coll_50', silent: true)
    unlocked_count += 1 if unique_total >= 100 && check_achievement(channel, uid, 'coll_100', silent: true)
    unlocked_count += 1 if unique_total >= 200 && check_achievement(channel, uid, 'coll_200', silent: true)

    r_rare = col.values.count { |d| d['rarity'] == 'rare' && (d['count'] > 0 || d['ascended'] > 0) }
    r_leg = col.values.count { |d| d['rarity'] == 'legendary' && (d['count'] > 0 || d['ascended'] > 0) }
    r_god = col.values.count { |d| d['rarity'] == 'goddess' && (d['count'] > 0 || d['ascended'] > 0) }

    unlocked_count += 1 if r_rare >= 25 && check_achievement(channel, uid, 'rare_25', silent: true)
    unlocked_count += 1 if r_leg >= 10 && check_achievement(channel, uid, 'leg_10', silent: true)
    unlocked_count += 1 if r_leg >= 25 && check_achievement(channel, uid, 'leg_25', silent: true)
    unlocked_count += 1 if r_god >= 1 && check_achievement(channel, uid, 'goddess_luck', silent: true)
    unlocked_count += 1 if r_god >= 5 && check_achievement(channel, uid, 'god_5', silent: true)

    ascended_total = col.values.count { |d| d['ascended'] > 0 }
    unlocked_count += 1 if ascended_total >= 1 && check_achievement(channel, uid, 'ascension', silent: true)
    unlocked_count += 1 if ascended_total >= 5 && check_achievement(channel, uid, 'ascend_5', silent: true)
    unlocked_count += 1 if ascended_total >= 10 && check_achievement(channel, uid, 'ascend_10', silent: true)
    unlocked_count += 1 if ascended_total >= 25 && check_achievement(channel, uid, 'ascend_25', silent: true)

    unlocked_count += 1 if col.values.any? { |d| d['count'] >= 100 } && check_achievement(channel, uid, 'dupe_100', silent: true)
  end

  # 5. Interactions (Hugs & Slaps)
  stats = DB.get_interactions(uid) || {}
  
  hug_sent = stats.dig('hug', 'sent').to_i
  hug_rec = stats.dig('hug', 'received').to_i
  unlocked_count += 1 if hug_sent >= 1 && check_achievement(channel, uid, 'first_hug', silent: true)
  unlocked_count += 1 if hug_sent >= 10 && check_achievement(channel, uid, 'hug_sent_10', silent: true)
  unlocked_count += 1 if hug_sent >= 50 && check_achievement(channel, uid, 'hug_sent_50', silent: true)
  unlocked_count += 1 if hug_rec >= 10 && check_achievement(channel, uid, 'hug_rec_10', silent: true)
  unlocked_count += 1 if hug_rec >= 50 && check_achievement(channel, uid, 'hug_rec_50', silent: true)

  slap_sent = stats.dig('slap', 'sent').to_i
  slap_rec = stats.dig('slap', 'received').to_i
  unlocked_count += 1 if slap_sent >= 1 && check_achievement(channel, uid, 'first_slap', silent: true)
  unlocked_count += 1 if slap_sent >= 10 && check_achievement(channel, uid, 'slap_sent_10', silent: true)
  unlocked_count += 1 if slap_sent >= 50 && check_achievement(channel, uid, 'slap_sent_50', silent: true)
  unlocked_count += 1 if slap_rec >= 10 && check_achievement(channel, uid, 'slap_rec_10', silent: true)
  unlocked_count += 1 if slap_rec >= 50 && check_achievement(channel, uid, 'slap_rec_50', silent: true)

  unlocked_count
end