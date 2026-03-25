# ==========================================
# COMMAND: removepremium (Developer Only)
# DESCRIPTION: Manually revokes a user's global Lifetime Premium status.
# CATEGORY: Developer / Premium Management
# ==========================================

# ------------------------------------------
# LOGIC: Revoke Premium Execution
# ------------------------------------------
def execute_removepremium(event, target)
  # 1. Security: Strict Developer-Only Check
  unless event.user.id == DEV_ID
    return send_embed(event, 
      title: "❌ Access Denied", 
      description: "Only the bot developer can revoke Lifetime Premium."
    )
  end

  # 2. Validation: Ensure a target user was identified
  unless target
    return send_embed(event, 
      title: "❌ Error", 
      description: "Please mention a user to remove lifetime premium from!"
    )
  end

  # 3. Database: Update the status to 'false' in the 'lifetime_premium' table
  DB.set_lifetime_premium(target.id, false)
  
  # 4. UI: Confirm the revocation via Embed
  send_embed(event, 
    title: "🥀 Premium Revoked", 
    description: "Lifetime Premium has been removed from **#{target.display_name}**."
  )
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!removepremium)
# ------------------------------------------
bot.command(:removepremium, 
  description: 'Remove lifetime premium (Dev only)', 
  category: 'Developer'
) do |event|
  # Capture the first mention found in the text message
  execute_removepremium(event, event.message.mentions.first)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/removepremium)
# ------------------------------------------
bot.application_command(:removepremium) do |event|
  # Fetch target user object from the provided Slash option ID
  target = event.bot.user(event.options['user'].to_i)
  execute_removepremium(event, target)
end