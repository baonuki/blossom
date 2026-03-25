# ==========================================
# COMMAND: ban
# DESCRIPTION: Ban a member or ID from the server with logging and DM notification.
# CATEGORY: Moderation
# ==========================================

# ------------------------------------------
# LOGIC: Ban Execution
# ------------------------------------------
def execute_ban(event, user_input, reason)
  # 1. Security: Verify the moderator has the 'ban_members' permission
  unless event.user.permission?(:ban_members)
    return mod_reply(event, "❌ *You don't have permission to do that!*", is_ephemeral: true)
  end
  
  # 2. Input Parsing: Resolve the user ID (handles mentions or raw numbers)
  target_id = parse_id(user_input)
  unless target_id
    return mod_reply(event, "🌸 *Please provide a valid user ID or mention!*", is_ephemeral: true)
  end
  
  # 3. Normalization: Set a default reason if none is provided
  reason = "No reason provided." if reason.nil? || reason.to_s.strip.empty?

  begin
    # 4. Preparation: Fetch member object and logging configuration
    member = event.server.member(target_id)
    config = DB.get_log_config(event.server.id)
    
    # 5. Courtesy: Send a DM before the ban if the config allows it
    # We use 'rescue nil' to ignore errors if the user's DMs are closed.
    if config[:dm_mods] && member
      member.pm("You have been banned from **#{event.server.name}**.\nReason: #{reason}") rescue nil
    end

    # 6. Action: Execute the ban (0 indicates 'delete 0 days of messages')
    event.server.ban(target_id, 0, reason: reason)
    mod_reply(event, "🔨 Successfully banned ID **#{target_id}**.\n*Reason:* #{reason}")

    # 7. Metadata: Prepare data for the log entry
    mention = member ? member.mention : "<@#{target_id}>"
    distinct = member ? member.distinct : "Unknown Tag"

    # 8. Logging: Create a permanent record in the moderation log channel
    log_mod_action(
      event.bot, 
      event.server.id, 
      "🔨 Member Banned", 
      "**User:** #{mention} (#{distinct})\n**Moderator:** #{event.user.mention}\n**Reason:** #{reason}",
      0x8B0000 # Dark Red
    )

  rescue => e
    # 9. Error Handling: Specifically catches Permission Hierarchy issues
    mod_reply(event, "❌ *Action Failed! Error:* `#{e.message}`\n*(Make sure my Bot Role is placed higher than theirs!)*", is_ephemeral: true)
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!ban)
# ------------------------------------------
bot.command(:ban, 
  description: 'Bans a user (or ID)', 
  required_permissions: [:ban_members]
) do |event, user_input, *reason_array|
  # Join reason array into a single string
  reason = reason_array.join(' ')
  execute_ban(event, user_input, reason)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/ban)
# ------------------------------------------
bot.application_command(:ban) do |event|
  execute_ban(event, event.options['user'], event.options['reason'])
end