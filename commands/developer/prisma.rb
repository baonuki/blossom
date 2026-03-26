# ==========================================
# COMMAND: prisma (Developer Only)
# DESCRIPTION: Manually manage a user's Prisma balance (Add, Remove, or Set).
# CATEGORY: Developer / Economy Management
# ==========================================

# ------------------------------------------
# LOGIC: Prisma Modification Execution
# ------------------------------------------
def execute_prisma(event, action, target, amount)
  # 0. Security: Ensure only the developer can execute this
  unless DEV_IDS.include?(event.user.id)
    return event.respond(content: "#{EMOJI_STRINGS['x_']} *This command is restricted to the bot developer.*", ephemeral: true) if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
    return
  end

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
    error_msg = "#{EMOJI_STRINGS['x_']} Invalid action! Use `add`, `remove`, or `set`."
    if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
      return event.respond(content: error_msg, ephemeral: true)
    else
      return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Invalid Action" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Use `add`, `remove`, or `set`." }
    ]}])
    end
  end

  # 5. Data Retrieval: Fetch the updated balance for the final confirmation
  new_bal = DB.get_prisma(uid)

  # 6. UI: Confirm via CV2
  send_cv2(event, [{ type: 17, accent_color: 0x9370DB, components: [
    { type: 10, content: "## #{EMOJI_STRINGS['prisma']} Prisma Updated" },
    { type: 14, spacing: 1 },
    { type: 10, content: "#{action_word} #{target.mention}!\n\n**New Balance:** #{new_bal} #{EMOJI_STRINGS['prisma']}" }
  ]}])
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!prisma)
# ------------------------------------------
$bot.command(:prisma, 
  description: 'Manage user Prisma (Dev Only)', 
  category: 'Developer'
) do |event, action, user_mention, amount|
  # Security: Hard check for Developer ID
  return unless DEV_IDS.include?(event.user.id)
  
  # Argument Check: Ensure all required fields are filled
  target = event.message.mentions.first
  if target.nil? || action.nil? || amount.nil?
    send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['confused']} Usage" },
      { type: 14, spacing: 1 },
      { type: 10, content: "`#{PREFIX}prisma <add/remove/set> @user <amount>`" }
    ]}])
    return nil
  end
  
  execute_prisma(event, action, target, amount)
  nil # Suppress double-response
end