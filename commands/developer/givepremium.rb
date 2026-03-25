# ==========================================
# COMMAND: givepremium (Developer Only)
# DESCRIPTION: Manually grants a user permanent global Premium status.
# CATEGORY: Developer / Premium Management
# ==========================================

# ------------------------------------------
# LOGIC: Grant Premium Execution
# ------------------------------------------
def execute_givepremium(event, target)
  # 1. Security: Strict Developer-Only Check
  unless event.user.id == DEV_ID 
    return send_embed(event, 
      title: "❌ Access Denied", 
      description: "Only the bot developer can grant Lifetime Premium."
    )
  end

  # 2. Validation: Ensure a target user was identified
  unless target
    return send_embed(event, 
      title: "❌ Error", 
      description: "Please mention a user to give lifetime premium to!"
    )
  end

  # 3. Database: Update the user's status in the 'lifetime_premium' table
  DB.set_lifetime_premium(target.id, true)
  
  # 4. UI: Confirm the upgrade and list the permanent perks via Embed
  send_embed(event, 
    title: "✨ Lifetime Premium Granted!", 
    description: "**#{target.display_name}** has been permanently upgraded!\nThey will now receive the 10% coin boost, half cooldowns, and boosted gacha luck globally."
  )
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!givepremium)
# ------------------------------------------
$bot.command(:givepremium, 
  description: 'Give a user lifetime premium (Dev only)', 
  category: 'Developer'
) do |event|
  # Pass the first mention found in the message to the executor
  execute_givepremium(event, event.message.mentions.first)
  nil # Suppress default return
end