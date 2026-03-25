# ==========================================
# COMMAND: support
# DESCRIPTION: Get a link to the official support server for help and community.
# CATEGORY: Utility
# ==========================================

# ------------------------------------------
# LOGIC: Support Invite Execution
# ------------------------------------------
def execute_support(event)
  # 1. UI: Construct the support message
  # We use bolding for the link to make it easily clickable on all devices.
  description = "Need assistance, have questions, or want to report a bug?\n" \
                "Join the Tsukiyo Server here:\n\n" \
                "**https://discord.gg/tsukiyo**"

  # 2. Messaging: Send the Support Embed
  send_embed(
    event, 
    title: "🛠️ Support Server", 
    description: description,
    color: 0x5865F2 # Discord Blurple
  )
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!support)
# ------------------------------------------
bot.command(:support, 
  description: 'Get a link to the official support server', 
  category: 'Utility'
) do |event|
  execute_support(event)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/support)
# ------------------------------------------
bot.application_command(:support) do |event|
  execute_support(event)
end