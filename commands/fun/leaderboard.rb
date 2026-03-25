# ==========================================
# COMMAND: leaderboard
# DESCRIPTION: View the rankings for coins, prisma, or levels (Local & Global).
# CATEGORY: Economy / Social
# ==========================================

# ------------------------------------------
# LOGIC: Leaderboard Display Execution
# ------------------------------------------
def execute_leaderboard(event)
  # 1. Validation: Ensure the command isn't being run in DMs
  # Leaderboards require a server context to calculate "Local" rankings.
  unless event.server
    error_msg = "❌ This command can only be used in a server!"
    if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
      return event.respond(content: error_msg, ephemeral: true)
    else
      return event.respond(error_msg)
    end
  end

  # 2. Initialization: Set the default landing page and user context
  default_page = 'server_users'
  uid = event.user.id
  
  # 3. Data Retrieval: Call the helper to generate the initial Embed
  # This helper handles the heavy SQL lifting for the top 10 rankings.
  embed = generate_leaderboard_page(event.bot, event.server, default_page)
  
  # 4. Components: Attach the interactive Select Menu for navigation
  view = leaderboard_select_menu(uid, default_page)

  # 5. Messaging: Respond with the Embed and the View
  if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
    event.respond(embeds: [embed], components: view)
  else
    # Mentioning the original message in Prefix mode for better UX
    event.channel.send_message(nil, false, embed, nil, nil, event.message, view)
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!leaderboard)
# ------------------------------------------
bot.command(:leaderboard, 
  description: 'View the local and global leaderboards!', 
  category: 'Economy'
) do |event|
  execute_leaderboard(event)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/leaderboard)
# ------------------------------------------
bot.application_command(:leaderboard) do |event|
  execute_leaderboard(event)
end