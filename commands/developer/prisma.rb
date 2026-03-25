# ==========================================
# COMMAND: prisma (Developer Only)
# DESCRIPTION: Manually manage a user's Prisma balance (Add, Remove, or Set).
# CATEGORY: Developer / Economy Management
# ==========================================

# ------------------------------------------
# LOGIC: Prisma Modification Execution
# ------------------------------------------
def execute_prisma(event, action, target, amount)
  # 1. Validation: Exit early if the target user object is missing
  return if target.nil?
  
  # 2. Initialization: Standardize the amount (absolute value) and user ID
  uid = target.id
  amt = amount.to_i.abs 

  # 3. Branching Logic: Handle the requested balance modification
  case action.downcase
  when 'add'
    # Increase the user's Prisma balance
    DB.add_prisma(uid, amt)
    action_word = "Added **#{amt}** to"

  when 'remove'
    # Decrease the balance, ensuring we don't drop below zero
    current = DB.get_prisma(uid)
    remove_amt = [amt, current].min 
    DB.add_prisma(uid, -remove_amt)
    action_word = "Removed **#{remove_amt}** from"

  when 'set'
    # Overwrite the balance with a specific value
    DB.set_prisma(uid, amt)
    action_word = "Set balance to **#{amt}** for"

  else
    # 4. Error Handling: Respond if the action string is unrecognized
    error_msg = "❌ Invalid action! Use `add`, `remove`, or `set`."
    if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
      return event.respond(content: error_msg, ephemeral: true)
    else
      return event.respond(error_msg)
    end
  end

  # 5. Data Retrieval: Fetch the updated balance for the final confirmation
  new_bal = DB.get_prisma(uid)
  
  # 6. UI: Construct the confirmation Embed
  embed = Discordrb::Webhooks::Embed.new(
    title: "<:prisma:1486142162805723196> Prisma Updated",
    description: "#{action_word} #{target.mention}!\n\n**New Balance:** #{new_bal} <:prisma:1486142162805723196>",
    color: 0x9370DB # Deep purple/Prisma theme
  )

  # 7. Messaging: Respond based on event type (Slash vs. Prefix)
  if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
    event.respond(embeds: [embed])
  else
    event.channel.send_message(nil, false, embed)
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!prisma)
# ------------------------------------------
bot.command(:prisma, 
  description: 'Manage user Prisma (Dev Only)', 
  category: 'Developer'
) do |event, action, user_mention, amount|
  # Security: Hard check for Developer ID
  return unless event.user.id == DEV_ID
  
  # Argument Check: Ensure all required fields are filled
  target = event.message.mentions.first
  if target.nil? || action.nil? || amount.nil?
    event.respond("⚠️ *Usage: `#{PREFIX}prisma <add/remove/set> @user <amount>`*")
    return nil
  end
  
  execute_prisma(event, action, target, amount)
  nil # Suppress double-response
end

# ------------------------------------------
# TRIGGER: Slash Command (/prisma)
# ------------------------------------------
bot.application_command(:prisma) do |event|
  # Security: Direct response for non-developers
  unless event.user.id == DEV_ID
    return event.respond(content: "❌ Developer only!", ephemeral: true) 
  end
  
  # Fetch target and pass Slash options to the executor
  target_id = event.options['user']
  target = event.bot.user(target_id.to_i)
  
  execute_prisma(event, event.options['action'], target, event.options['amount'])
end