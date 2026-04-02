# ==========================================
# COMMAND: balance (The Economy Dashboard)
# DESCRIPTION: Displays a user's coins, Prisma, daily streak, and special badges.
# CATEGORY: Economy
# ==========================================

# ------------------------------------------
# LOGIC: Balance Display Execution
# ------------------------------------------
def execute_balance(event, target_user)
  # 1. Initialization: Get target ID and fetch all relevant data points
  uid = target_user.id
  coins = DB.get_coins(uid)
  prisma = DB.get_prisma(uid)
  rep = DB.get_reputation(uid)

  # 2. Check: Determine if the user has active Premium status
  is_sub = is_premium?(event.bot, uid)
  profile = is_sub ? DB.get_profile(uid) : { 'color' => nil, 'bio' => nil, 'favorites' => [] }

  # 3. Data Retrieval: Get the daily streak info from the cooldowns module
  daily_info = DB.get_daily_info(uid)

  # 4. Cosmetics: Load and build display elements
  cosmetics = DB.get_cosmetics(uid)

  # Auto-grant developer cosmetics
  if DEV_IDS.include?(uid)
    DB.unlock_badge(uid, 'developer')
    DB.set_equipped_badge(uid, 'developer') unless cosmetics['badge']
    DB.set_title(uid, 'developer') unless cosmetics['title']
    cosmetics = DB.get_cosmetics(uid)
  end

  # Title + Badge line (badge emoji displayed next to title)
  title_badge_line = ""
  badge_emoji = ""
  if cosmetics['badge'] && BADGES[cosmetics['badge']]
    badge_emoji = "#{BADGES[cosmetics['badge']][:emoji]} "
  end
  if cosmetics['title'] && TITLES[cosmetics['title']]
    title_badge_line = "#{badge_emoji}*#{TITLES[cosmetics['title']][:name]}*\n"
  elsif !badge_emoji.empty?
    title_badge_line = "#{badge_emoji.strip}\n"
  end

  # Status badges (Premium only now — developer is handled via cosmetics)
  status_line = is_sub ? "#{EMOJI_STRINGS['prisma']} **Premium**\n" : ""

  # 5. Bio line (premium only)
  bio_line = (profile['bio'] && !profile['bio'].empty?) ? "*\"#{profile['bio']}\"*\n" : ""

  # 6. Marriage line
  marriage = DB.get_marriage(uid)
  if marriage
    partner_user = event.bot.user(marriage[:partner])
    partner_name = partner_user ? partner_user.username : "Unknown"
    marriage_line = "\n#{EMOJI_STRINGS['rainbowheart']} **Married to:** #{partner_name}"
  else
    marriage_line = ""
  end

  # 7. Favorite cards (premium: up to 3)
  favs = profile['favorites']
  fav_lines = favs.map { |name| format_fav_line(name) }.compact
  fav_section = fav_lines.empty? ? "" : "\n#{EMOJI_STRINGS['hearts']} **Favorites:** #{fav_lines.join(' · ')}"

  # 8. Pet line
  pet_line = ""
  if cosmetics['pet'] && PETS[cosmetics['pet']]
    pet = PETS[cosmetics['pet']]
    pet_line = "\n\n#{pet[:emoji]} #{pet[:idle]}"
  end

  # 9. UI: Construct the primary Balance Embed
  accent = profile['color'] ? profile['color'].to_i(16) : 0xFFB6C1
  embed = Discordrb::Webhooks::Embed.new(
    title: "🌸 #{target_user.display_name}'s Balance",
    description: "#{title_badge_line}#{status_line}#{bio_line}\n" \
                 "**Coins:** #{coins} #{EMOJI_STRINGS['s_coin']}\n" \
                 "**Prisma:** #{prisma} #{EMOJI_STRINGS['prisma']}\n" \
                 "**Reputation:** #{rep} #{EMOJI_STRINGS['rainbowheart']}\n" \
                 "**Daily Streak:** #{daily_info['streak']} Days#{marriage_line}#{fav_section}#{pet_line}\n\n" \
                 "*Use the dropdown below to view your items, VTubers, and Achievements!*#{mom_remark(uid, 'economy')}",
    color: accent
  )

  # 7. Components: Attach the interactive Select Menu for inventory navigation
  # Note: The 'home' parameter tells the menu to highlight the current page.
  view = balance_select_menu(uid, 'home')

  # 8. Messaging: Respond with the embed and components based on event type
  if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
    event.respond(embeds: [embed], components: view)
  else
    event.channel.send_message(nil, false, embed, nil, nil, event.message, view)
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!balance)
# ------------------------------------------
$bot.command(:balance, aliases: [:bal],
  description: 'Show a user\'s coin balance, gacha stats, and inventory', 
  category: 'Economy'
) do |event|
  # Default to the message author if no mention is provided
  execute_balance(event, event.message.mentions.first || event.user)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/balance)
# ------------------------------------------
$bot.application_command(:balance) do |event|
  # Fetch target user from options or default to the command runner
  target_id = event.options['user']
  target = target_id ? event.bot.user(target_id.to_i) : event.user
  execute_balance(event, target)
end