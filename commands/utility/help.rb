# ==========================================
# COMMAND: help
# DESCRIPTION: The primary navigation hub for all bot commands.
# CATEGORY: Utility
# ==========================================

# ------------------------------------------
# LOGIC: Help Menu Execution
# ------------------------------------------
def execute_help(event)
  # 1. Initialization: Generate the "Home" page embed
  # This usually contains a welcome message and general bot info.
  embed = generate_category_embed(event.bot, event.user, 'Home')
  
  # 2. Components: Build the interactive Select Menu
  # Passing the user's ID ensures only they can interact with their own menu.
  view = help_select_menu(event.user.id)

  # 3. Messaging: Dispatch based on the trigger type
  if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
    # Slash Command (/help)
    event.respond(embeds: [embed], components: view)
  else
    # Prefix Command (b!help)
    # Note: We don't use a reply reference here to keep the UI as clean as possible.
    event.channel.send_message(nil, false, embed, nil, nil, nil, view)
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!help)
# ------------------------------------------
bot.command(:help, 
  description: 'Shows the interactive help menu', 
  category: 'Utility'
) do |event|
  execute_help(event)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/help)
# ------------------------------------------
bot.application_command(:help) do |event|
  execute_help(event)
end