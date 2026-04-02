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
      # Check user notification preference
      user_pref = DB.get_ach_notify(uid)
      return true if user_pref == 'silent'

      # Check if the server has achievement notifications disabled
      server = if channel_or_event.respond_to?(:server)
                 channel_or_event.server
               elsif channel_or_event.respond_to?(:channel) && channel_or_event.channel.respond_to?(:server)
                 channel_or_event.channel.server
               end
      notify = server ? DB.achievements_enabled?(server.id) : true

      if notify
        embed = Discordrb::Webhooks::Embed.new(
          title: "#{EMOJI_STRINGS['achievement']} Achievement Unlocked!",
          description: "Oh? **#{data[:emoji]} #{data[:name]}**\n> #{data[:desc]}\n\n*Not bad. Here's **#{data[:reward]}** #{EMOJI_STRINGS['s_coin'] || '🪙'} for your trouble.*",
          color: 0xFFD700
        )

        if user_pref == 'dm'
          # DM the achievement to the user
          begin
            user = channel_or_event.respond_to?(:user) ? channel_or_event.user : nil
            user ||= $bot.user(uid)
            user&.dm&.send_message(nil, false, embed)
          rescue StandardError
            nil
          end
        else
          # Post in channel (default behavior)
          if channel_or_event.respond_to?(:channel)
            channel_or_event.channel.send_message(nil, false, embed) rescue nil
          else
            channel_or_event.send_message(nil, false, embed) rescue nil
          end
        end
      end
    end
    return true
  end
  false
end

def check_wealth_achievements(channel_or_event, uid)
  coins = DB.get_coins(uid)
  check_achievement(channel_or_event, uid, 'wealth_0') if coins == 0
  check_achievement(channel_or_event, uid, 'wealth_10k') if coins >= 10_000
  check_achievement(channel_or_event, uid, 'wealth_100k') if coins >= 100_000
  check_achievement(channel_or_event, uid, 'wealth_1m') if coins >= 1_000_000
  check_achievement(channel_or_event, uid, 'wealth_10m') if coins >= 10_000_000
end

def generate_achievements_page(username, uid, page)
  unlocked_data = DB.get_achievements(uid)
  unlocked_ids = unlocked_data.map { |row| row['achievement_id'] }
  per_page = 5 
  
  embed = Discordrb::Webhooks::Embed.new(
    title: "#{EMOJI_STRINGS['achievement']} Trophy Case",
    color: 0xFFD700
  )
  
  desc = "**#{username}'s Trophies**\n*Flexing: #{unlocked_ids.size} / #{ACHIEVEMENTS.size}*\n\n"
  
  if unlocked_ids.empty?
    desc += "*No trophies yet?? Go grind, come back when you've done something.*"
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

  # 5. Interactions (Hugs, Slaps & Pats)
  stats = DB.get_interactions(uid) || {}

  %w[hug slap pat].each do |action|
    sent = stats.dig(action, 'sent').to_i
    rec = stats.dig(action, 'received').to_i
    unlocked_count += 1 if sent >= 1 && check_achievement(channel, uid, "first_#{action}", silent: true)
    unlocked_count += 1 if sent >= 10 && check_achievement(channel, uid, "#{action}_sent_10", silent: true)
    unlocked_count += 1 if sent >= 50 && check_achievement(channel, uid, "#{action}_sent_50", silent: true)
    unlocked_count += 1 if sent >= 100 && check_achievement(channel, uid, "#{action}_sent_100", silent: true)
    unlocked_count += 1 if rec >= 10 && check_achievement(channel, uid, "#{action}_rec_10", silent: true)
    unlocked_count += 1 if rec >= 50 && check_achievement(channel, uid, "#{action}_rec_50", silent: true)
    unlocked_count += 1 if rec >= 100 && check_achievement(channel, uid, "#{action}_rec_100", silent: true)
  end

  # 6. Leveling (check across all servers the user has XP in)
  # We check via the bot's known servers to find the highest level
  begin
    highest_level = 0
    $bot.servers.each_key do |server_id|
      xp_data = DB.get_user_xp(server_id, uid)
      highest_level = [highest_level, xp_data['level'].to_i].max
    end
    unlocked_count += 1 if highest_level >= 5 && check_achievement(channel, uid, 'level_5', silent: true)
    unlocked_count += 1 if highest_level >= 10 && check_achievement(channel, uid, 'level_10', silent: true)
    unlocked_count += 1 if highest_level >= 25 && check_achievement(channel, uid, 'level_25', silent: true)
    unlocked_count += 1 if highest_level >= 50 && check_achievement(channel, uid, 'level_50', silent: true)
    unlocked_count += 1 if highest_level >= 100 && check_achievement(channel, uid, 'level_100', silent: true)
  rescue => e
    puts "[SYNC] Level check failed for #{uid}: #{e.message}"
  end

  # 7. Tracking Counters (Pulls, Trades, Givecards, Coins Given)
  tracking = DB.get_tracking_stats(uid)
  unlocked_count += 1 if tracking['pull_count'] >= 100 && check_achievement(channel, uid, 'summon_100', silent: true)
  unlocked_count += 1 if tracking['pull_count'] >= 500 && check_achievement(channel, uid, 'summon_500', silent: true)
  unlocked_count += 1 if tracking['pull_count'] >= 1000 && check_achievement(channel, uid, 'summon_1000', silent: true)
  unlocked_count += 1 if tracking['trade_count'] >= 10 && check_achievement(channel, uid, 'trade_10', silent: true)
  unlocked_count += 1 if tracking['givecard_count'] >= 10 && check_achievement(channel, uid, 'givecard_10', silent: true)
  unlocked_count += 1 if tracking['coins_given_total'] >= 10_000 && check_achievement(channel, uid, 'give_10k', silent: true)
  unlocked_count += 1 if tracking['coins_given_total'] >= 100_000 && check_achievement(channel, uid, 'give_100k', silent: true)

  # 8. Meta: Achievement count milestones
  total_unlocked = DB.get_achievements(uid).size + unlocked_count
  unlocked_count += 1 if total_unlocked >= 10 && check_achievement(channel, uid, 'ach_10', silent: true)
  unlocked_count += 1 if total_unlocked >= 25 && check_achievement(channel, uid, 'ach_25', silent: true)
  unlocked_count += 1 if total_unlocked >= 50 && check_achievement(channel, uid, 'ach_50', silent: true)

  unlocked_count
end