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
      return event.respond(error_msg)
    end
  end

  sid = event.server.id
  uid = target_user.id

  user = DB.get_user_xp(sid, uid)
  daily_info = DB.get_daily_info(uid)
  is_sub = is_premium?(event.bot, uid)
  coins = DB.get_coins(uid)

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

  components = [
    {
      type: 17,
      accent_color: NEON_COLORS.sample,
      components: [
        { type: 10, content: "## #{target_user.display_name}'s Stats" },
        { type: 14, spacing: 1 },
        {
          type: 10,
          content: badge_line +
            "**Level** #{level}  ·  **XP** #{xp}/#{needed}  ·  #{EMOJI_STRINGS['s_coin']} #{coins}\n" \
            "`#{bar}` #{((xp.to_f / [needed, 1].max) * 100).round}%\n" \
            "🔥 **#{streak}** day streak"
        }
      ]
    }
  ]

  send_cv2(event, components)
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!level)
# ------------------------------------------
$bot.command(:level,
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
