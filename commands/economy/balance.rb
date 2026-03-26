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
  
  # 2. Check: Determine if the user has active Premium status
  is_sub = is_premium?(event.bot, uid)
  
  # 3. Data Retrieval: Get the daily streak info from the cooldowns module
  daily_info = DB.get_daily_info(uid)

  # 4. Badge Logic: Build a list of visual achievements/roles
  badges = []
  badges << "#{EMOJI_STRINGS['developer']} **Bot Developer**" if DEV_IDS.include?(uid)
  badges << "#{EMOJI_STRINGS['prisma']} **Premium**" if is_sub
  
  # 5. Header Formatting: Create the top-row badge line if badges exist
  header = badges.empty? ? "" : badges.join(" | ") + "\n\n"

  # 6. UI: Construct the primary Balance Embed
  embed = Discordrb::Webhooks::Embed.new(
    title: "🌸 #{target_user.display_name}'s Balance",
    description: "#{header}**Coins:** #{coins} #{EMOJI_STRINGS['s_coin']}\n" \
                 "**Prisma:** #{prisma} #{EMOJI_STRINGS['prisma']}\n" \
                 "🔥 **Daily Streak:** #{daily_info['streak']} Days\n\n" \
                 "*Use the dropdown below to view your items, VTubers, and Achievements!*",
    color: 0xFFB6C1 # Light Pink (Princess Vibe)
  )

  # 7. Components: Attach the interactive Select Menu for inventory navigation
  # Note: The 'home' parameter tells the menu to highlight the current page.
  view = balance_select_menu(uid, 'home')

  # 8. Messaging: Respond with the embed and components based on event type
  if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
    event.respond(embeds: [embed], components: view)
  else
    event.channel.send_message(nil, false, embed, nil, nil, nil, view)
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!balance)
# ------------------------------------------
$bot.command(:balance, 
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