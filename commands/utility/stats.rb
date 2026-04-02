# ==========================================
# COMMAND: stats
# DESCRIPTION: Lifetime statistics dashboard.
# CATEGORY: Utility
# ==========================================

def execute_stats(event)
  uid = event.user.id
  s = DB.get_full_stats(uid)
  prisma = DB.get_prisma(uid)
  col = DB.get_collection(uid)
  achievements = DB.get_achievements(uid)
  interactions = DB.get_interactions(uid)
  arcade = DB.get_arcade_stats(uid)
  is_sub = is_premium?(event.bot, uid)

  # Collection breakdown
  unique = col.keys.size
  total_cards = col.values.sum { |d| d['count'] + (d['ascended'].to_i * 5) }
  ascended = col.values.count { |d| d['ascended'].to_i > 0 }
  by_rarity = { 'common' => 0, 'rare' => 0, 'legendary' => 0, 'goddess' => 0 }
  col.each_value { |d| by_rarity[d['rarity'].downcase] = (by_rarity[d['rarity'].downcase] || 0) + 1 }

  # Interaction totals
  total_hugs = interactions['hug']['sent'] + interactions['hug']['received']
  total_slaps = interactions['slap']['sent'] + interactions['slap']['received']
  total_pats = interactions['pat']['sent'] + interactions['pat']['received']

  # Toggles
  autosell_status = s['autosell_enabled'] == 1 ? '🟢 ON' : '🔴 OFF'
  shiny_status = s['shiny_mode'] == 1 ? '🟢 ON' : '🔴 OFF'

  components = [{ type: 17, accent_color: NEON_COLORS.sample, components: [
    { type: 10, content: "## #{EMOJI_STRINGS['neonsparkle']} #{event.user.display_name}'s Stats" },
    { type: 14, spacing: 1 },
    { type: 10, content: "**#{EMOJI_STRINGS['s_coin']} Economy**\n" \
                         "Coins: **#{s['coins'].to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}** #{EMOJI_STRINGS['s_coin']}\n" \
                         "#{EMOJI_STRINGS['prisma']} Prisma: **#{prisma}**\n" \
                         "Daily Streak: **#{s['daily_streak']}** days 🔥\n" \
                         "Reputation: **#{s['reputation']}** #{EMOJI_STRINGS['heart']}\n" \
                         "Coins Given: **#{s['coins_given_total'].to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}** #{EMOJI_STRINGS['s_coin']}" },
    { type: 14, spacing: 1 },
    { type: 10, content: "**#{EMOJI_STRINGS['surprise']} Gacha**\n" \
                         "Total Summons: **#{s['pull_count']}**\n" \
                         "Unique Characters: **#{unique}**\n" \
                         "Total Cards: **#{total_cards}**\n" \
                         "Ascended: **#{ascended}**\n" \
                         "#{EMOJI_STRINGS['common']} #{by_rarity['common']} · #{EMOJI_STRINGS['rare']} #{by_rarity['rare']} · #{EMOJI_STRINGS['legendary']} #{by_rarity['legendary']} · #{EMOJI_STRINGS['goddess']} #{by_rarity['goddess']}" },
    { type: 14, spacing: 1 },
    { type: 14, spacing: 1 },
    { type: 10, content: "**🕹️ Arcade**\n" \
                         "Wins: **#{arcade['wins']}** · Losses: **#{arcade['losses']}**\n" \
                         "Win Rate: **#{arcade['wins'] + arcade['losses'] > 0 ? ((arcade['wins'].to_f / (arcade['wins'] + arcade['losses']) * 100).round(1)).to_s + '%' : 'N/A'}**" },
    { type: 14, spacing: 1 },
    { type: 10, content: "**🤝 Social**\n" \
                         "Trades: **#{s['trade_count']}** · Cards Gifted: **#{s['givecard_count']}**\n" \
                         "Hugs: **#{total_hugs}** · Slaps: **#{total_slaps}** · Pats: **#{total_pats}**\n" \
                         "Achievements: **#{achievements.size}** / **#{ACHIEVEMENTS.size}** #{EMOJI_STRINGS['achievement']}" },
    { type: 14, spacing: 1 },
    { type: 10, content: "**⚙️ Toggles** #{is_sub ? EMOJI_STRINGS['crown'] : ''}\n" \
                         "Auto-Sell Dupes: #{autosell_status}\n" \
                         "Shiny Hunting: #{shiny_status}#{mom_remark(uid, 'utility')}" }
  ]}]
  send_cv2(event, components)
end

# ------------------------------------------
# TRIGGERS
# ------------------------------------------
$bot.command(:stats, aliases: [:statistics, :mystats],
  description: 'View your lifetime stats dashboard',
  category: 'Utility'
) do |event|
  execute_stats(event)
  nil
end

$bot.application_command(:stats) do |event|
  execute_stats(event)
end
