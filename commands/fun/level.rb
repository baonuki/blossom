# ==========================================
# COMMAND: level (Server Profile)
# DESCRIPTION: Displays a user's server-specific XP, Level, and global stats.
# CATEGORY: Fun / Social
# ==========================================

# ------------------------------------------
# LOGIC: Level Display Execution
# ------------------------------------------
def execute_level(event, target_user)
  # 1. Validation: Ensure the command is not run in DMs
  # XP and Levels are tied specifically to server IDs.
  unless event.server
    error_msg = "#{EMOJIS['x_']} This command can only be used in a server!"
    if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
      return event.respond(content: error_msg, ephemeral: true)
    else
      return event.respond(error_msg)
    end
  end

  # 2. Initialization: Get IDs for the server and target user
  sid  = event.server.id
  uid  = target_user.id
  
  # 3. Data Retrieval: Fetch XP data and Daily/Premium status
  user = DB.get_user_xp(sid, uid)
  daily_info = DB.get_daily_info(uid)
  is_sub = is_premium?(event.bot, uid)

  # 4. Calculation: Determine XP needed for the next milestone
  # Formula: Current Level * 100
  needed = user['level'] * 100
  
  # 5. Badge Logic: Determine which visual badges to display in the description
  badges = []
  badges << "#{EMOJIS['developer']} **Verified Bot Developer**" if uid == DEV_ID
  badges << "💎 **Blossom Premium**" if is_sub
  
  desc = badges.empty? ? "" : badges.join("\n") + "\n\n"

  # 6. UI: Construct the Profile Embed
  send_embed(
    event,
    title: "#{EMOJIS['crown']} #{target_user.display_name}'s Profile",
    description: desc, 
    fields: [
      { name: 'Level', value: user['level'].to_s, inline: true },
      { name: 'XP', value: "#{user['xp']} / #{needed}", inline: true },
      { name: 'Coins', value: "#{DB.get_coins(uid)} #{EMOJIS['s_coin']}", inline: true },
      { name: 'Daily Streak', value: "🔥 #{daily_info['streak']} Days", inline: true }
    ]
  )
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!level)
# ------------------------------------------
bot.command(:level, 
  description: 'Show a user\'s level and XP for this server', 
  category: 'Fun'
) do |event|
  # Default to the message author if no mention is provided
  execute_level(event, event.message.mentions.first || event.user)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/level)
# ------------------------------------------
bot.application_command(:level) do |event|
  # Fetch target user from options or default to the command runner
  target_id = event.options['user']
  target = target_id ? event.bot.user(target_id.to_i) : event.user
  execute_level(event, target)
end