# ==========================================
# COMMAND: kick
# DESCRIPTION: Kick a member from the server with a DM notification and log entry.
# CATEGORY: Moderation
# ==========================================

# ------------------------------------------
# LOGIC: Kick Execution
# ------------------------------------------
def execute_kick(event, member, reason)
  # 1. Security: Verify the moderator has the 'kick_members' permission
  unless event.user.permission?(:kick_members)
    return event.respond(content: "#{EMOJI_STRINGS['x_']} *You don't have permission to do that!*", ephemeral: true)
  end

  # 2. Validation: Ensure the target user is actually in the server
  unless member
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['confused']} Who Am I Kicking?" },
      { type: 14, spacing: 1 },
      { type: 10, content: "I can't find that user in this server. Are they even here?\n`#{PREFIX}kick @user [reason]`" }
    ]}])
  end

  # 3. Normalization: Set a default reason if the moderator left it blank
  reason = "No reason provided." if reason.nil? || reason.to_s.strip.empty?

  begin
    # 4. Preparation: Check logging config for DM preferences
    config = DB.get_log_config(event.server.id)

    # 5. Courtesy: DM the user before kicking to explain why they are being removed
    # 'rescue nil' ensures the command proceeds even if the user's DMs are locked.
    if config[:dm_mods]
      member.pm("You have been kicked from **#{event.server.name}**.\nReason: #{reason}") rescue nil
    end

    # 6. Action: Execute the kick
    event.server.kick(member, reason)
    send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: [
      { type: 10, content: "## :boot: Kick Confirmed" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Successfully kicked **#{member.display_name}**.\n**Reason:** #{reason}" }
    ]}])

    # 7. Logging: Record the event in the server's designated moderation channel
    log_mod_action(
      event.bot,
      event.server.id,
      "👢 Member Kicked",
      "**User:** #{member.mention} (#{member.distinct})\n**Moderator:** #{event.user.mention}\n**Reason:** #{reason}",
      0xFF8C00 # Dark Orange
    )

  rescue => e
    # 8. Error Handling: Specifically catches role hierarchy or bot permission issues
    send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Kick Failed" },
      { type: 14, spacing: 1 },
      { type: 10, content: "**Error:** `#{e.message}`\nMake sure my bot role is placed *higher* than theirs!" }
    ]}])
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!kick)
# ------------------------------------------
$bot.command(:kick,
  description: 'Kicks a user',
  required_permissions: [:kick_members]
) do |event, user_input, *reason_array|
  # Convert input/mention into a Member object
  member = parse_member(event, user_input)
  reason = reason_array.join(' ')

  execute_kick(event, member, reason)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/kick)
# ------------------------------------------
$bot.application_command(:kick) do |event|
  # Resolve the member from the Slash interaction options
  member = parse_member(event, event.options['user'])
  execute_kick(event, member, event.options['reason'])
end
