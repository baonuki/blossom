# ==========================================
# COMMAND: timeout
# DESCRIPTION: Restrict a user's communication for a set period.
# CATEGORY: Moderation
# ==========================================

# ------------------------------------------
# LOGIC: Timeout Execution
# ------------------------------------------
def execute_timeout(event, member, duration_str, reason)
  # 1. Security: Verify moderator permissions
  # Requires 'moderate_members' (the native permission for timeouts).
  unless event.user.permission?(:moderate_members) || event.user.permission?(:kick_members)
    return event.respond(content: "#{EMOJI_STRINGS['x_']} *You don't have permission to do that!*", ephemeral: true)
  end

  # 2. Validation: Ensure target and duration are present
  unless member
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['confused']} Who Am I Timing Out?" },
      { type: 14, spacing: 1 },
      { type: 10, content: "I can't find that user in this server.\n`#{PREFIX}timeout @user <duration> [reason]`\nDurations: `10m`, `1h`, `2d`" }
    ]}])
  end

  unless duration_str
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['confused']} How Long?" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You need to give me a duration.\n`#{PREFIX}timeout @user <duration> [reason]`\nExamples: `10m`, `1h`, `2d`" }
    ]}])
  end

  # 3. Time Parsing: Convert strings like '1h' or '2d' into total minutes
  duration_str = duration_str.to_s
  minutes = duration_str.to_i
  minutes *= 60 if duration_str.end_with?('h')
  minutes *= 1440 if duration_str.end_with?('d')

  if minutes <= 0
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['confused']} Invalid Duration" },
      { type: 14, spacing: 1 },
      { type: 10, content: "That's not a valid duration. Try something like `10m`, `1h`, or `2d`." }
    ]}])
  end

  # 4. API Preparation: Format the expiration timestamp in ISO8601 (Required by Discord)
  reason = "No reason provided." if reason.nil? || reason.to_s.strip.empty?
  expire_time = (Time.now.utc + (minutes * 60)).iso8601

  begin
    # 5. Courtesy: DM the user with the duration and reason
    config = DB.get_log_config(event.server.id)
    member.pm("You have been timed out in **#{event.server.name}** for #{duration_str}.\nReason: #{reason}") rescue nil if config[:dm_mods]

    # 6. Action: Directly update the member via the Discord API
    Discordrb::API::Server.update_member(
      event.bot.token,
      event.server.id,
      member.id,
      communication_disabled_until: expire_time,
      reason: reason
    )

    # 7. Feedback: Confirm the action in the channel
    send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: [
      { type: 10, content: "## :timer: Timeout Confirmed" },
      { type: 14, spacing: 1 },
      { type: 10, content: "**#{member.display_name}** has been timed out for #{duration_str}.\n**Reason:** #{reason}" }
    ]}])

    # 8. Logging: Create a record in the server's moderation logs
    log_mod_action(
      event.bot,
      event.server.id,
      "⏳ Member Timed Out",
      "**User:** #{member.mention} (#{member.distinct})\n**Moderator:** #{event.user.mention}\n**Duration:** #{duration_str}\n**Reason:** #{reason}",
      0xFFFF00 # Yellow
    )
  rescue => e
    # 9. Error Handling: Specifically catches role hierarchy or bot permission issues
    send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Timeout Failed" },
      { type: 14, spacing: 1 },
      { type: 10, content: "**Error:** `#{e.message}`\nMake sure my bot role is placed *higher* than theirs!" }
    ]}])
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!timeout)
# ------------------------------------------
$bot.command(:timeout,
  description: 'Timeouts a user',
  required_permissions: [:moderate_members]
) do |event, user_input, duration, *reason_array|
  member = parse_member(event, user_input)
  reason = reason_array.join(' ')
  execute_timeout(event, member, duration, reason)
  nil
end

# ------------------------------------------
# TRIGGER: Slash Command (/timeout)
# ------------------------------------------
$bot.application_command(:timeout) do |event|
  member = parse_member(event, event.options['user'])
  # Supports either 'duration' or 'minutes' option naming
  execute_timeout(event, member, event.options['duration'] || event.options['minutes'], event.options['reason'])
end
