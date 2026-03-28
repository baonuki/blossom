# ==========================================
# COMMAND: level (Server Profile)
# DESCRIPTION: Displays a user's server-specific XP, Level, and global stats.
# CATEGORY: Fun / Social
# ==========================================

def execute_level(event, target_user)
  unless event.server
    error_msg = "#{EMOJI_STRINGS['x_']} Nice try, but this only works in a server!"
    if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
      return event.respond(content: error_msg, ephemeral: true)
    else
      return event.channel.send_message(error_msg, false, nil, nil, nil, event.message)
    end
  end

  sid = event.server.id
  uid = target_user.id

  user = DB.get_user_xp(sid, uid)
  daily_info = DB.get_daily_info(uid)
  is_sub = is_premium?(event.bot, uid)
  coins = DB.get_coins(uid)
  rep = DB.get_reputation(uid)

  level = user['level']
  xp = user['xp']
  needed = level * 100
  streak = daily_info['streak']

  # Progress bar
  progress = needed > 0 ? [(xp.to_f / needed * 10).round, 10].min : 0
  bar = ('▓' * progress) + ('░' * (10 - progress))

  # Badges
  badges = []
  badges << "#{EMOJI_STRINGS['developer']} **Bot Developer**" if DEV_IDS.include?(uid)
  badges << "#{EMOJI_STRINGS['prisma']} **Blossom Premium**" if is_sub
  badge_line = badges.empty? ? "" : badges.join("  ") + "\n"

  avatar_url = target_user.avatar_url || ''

  # Favorite card display (premium feature only)
  fav_name = is_sub ? DB.get_favorite_card(uid) : nil
  fav_line = nil
  if fav_name
    fav_result = find_character_in_pools(fav_name)
    if fav_result
      fav_rarity = fav_result[:rarity]
      fav_emoji = case fav_rarity
                  when 'goddess'   then EMOJI_STRINGS['goddess']
                  when 'legendary' then EMOJI_STRINGS['legendary']
                  when 'rare'      then EMOJI_STRINGS['rare']
                  else EMOJI_STRINGS['common']
                  end
      fav_line = "#{EMOJI_STRINGS['hearts']} **Favorite** #{fav_emoji} #{fav_name}"
    end
  end

  inner = [
    { type: 9, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['neonsparkle']} #{target_user.display_name}" },
      { type: 10, content: badge_line.empty? ? "Server profile" : badge_line.strip }
    ], accessory: { type: 11, media: { url: avatar_url } } },
    { type: 14, spacing: 1 },
    { type: 10, content: "#{EMOJI_STRINGS['level_heart']} **Level** #{level}\n`#{bar}` #{((xp.to_f / [needed, 1].max) * 100).round}%" },
    { type: 10, content: "#{EMOJI_STRINGS['up_arrow']} **XP** #{xp} / #{needed}" },
    { type: 10, content: "#{EMOJI_STRINGS['s_coin']} **Coins** #{coins}" },
    { type: 10, content: "#{EMOJI_STRINGS['rainbowheart']} **Rep** #{rep}" },
    { type: 10, content: "**Streak** #{streak} day#{'s' unless streak == 1}" }
  ]

  if fav_line
    inner << { type: 14, spacing: 1 }
    inner << { type: 10, content: fav_line }
  end

  mama_note = mom_remark(uid, 'general')
  inner << { type: 10, content: mama_note } if mama_note

  components = [{ type: 17, accent_color: NEON_COLORS.sample, components: inner }]

  send_cv2(event, components)
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!level)
# ------------------------------------------
$bot.command(:level, aliases: [:lvl, :rank],
  description: 'Show a user\'s level and XP for this server',
  category: 'Fun'
) do |event|
  execute_level(event, event.message.mentions.first || event.user)
  nil
end

# ------------------------------------------
# TRIGGER: Slash Command (/level)
# ------------------------------------------
$bot.application_command(:level) do |event|
  target_id = event.options['user']
  target = target_id ? event.bot.user(target_id.to_i) : event.user
  execute_level(event, target)
end
