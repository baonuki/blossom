def execute_timeout(event, member, duration_str, reason)
  return mod_reply(event, "❌ *You don't have permission to do that!*", is_ephemeral: true) unless event.user.permission?(:moderate_members) || event.user.permission?(:kick_members)
  return mod_reply(event, "🌸 *I couldn't find that user in this server!*", is_ephemeral: true) unless member
  return mod_reply(event, "🌸 *Please provide a duration! (e.g., 10m, 1h)*", is_ephemeral: true) unless duration_str

  duration_str = duration_str.to_s 

  minutes = duration_str.to_i
  minutes *= 60 if duration_str.end_with?('h')
  minutes *= 1440 if duration_str.end_with?('d')

  return mod_reply(event, "🌸 *Please provide a valid number of minutes!*", is_ephemeral: true) if minutes <= 0

  reason = "No reason provided." if reason.nil? || reason.to_s.strip.empty?
  expire_time = (Time.now.utc + (minutes * 60)).iso8601

  begin
    config = DB.get_log_config(event.server.id)
    member.pm("You have been timed out in **#{event.server.name}** for #{duration_str}.\nReason: #{reason}") rescue nil if config[:dm_mods]
    
    Discordrb::API::Server.update_member(
      event.bot.token,
      event.server.id,
      member.id,
      communication_disabled_until: expire_time,
      reason: reason
    )
    
    mod_reply(event, "⏱️ **#{member.display_name}** has been timed out for #{duration_str}.\n*Reason:* #{reason}")

    log_mod_action(
      event.bot, 
      event.server.id, 
      "⏳ Member Timed Out", 
      "**User:** #{member.mention} (#{member.distinct})\n**Moderator:** #{event.user.mention}\n**Duration:** #{duration_str}\n**Reason:** #{reason}",
      0xFFFF00
    )
  rescue => e
    mod_reply(event, "❌ *Action Failed! Error:* `#{e.message}`\n*(Make sure my Bot Role is placed higher than theirs!)*", is_ephemeral: true)
  end
end

bot.command(:timeout, description: 'Timeouts a user', required_permissions: [:moderate_members]) do |event, user_input, duration, *reason_array|
  member = parse_member(event, user_input)
  reason = reason_array.join(' ')
  execute_timeout(event, member, duration, reason)
  nil
end

bot.application_command(:timeout) do |event|
  member = parse_member(event, event.options['user'])
  execute_timeout(event, member, event.options['duration'] || event.options['minutes'], event.options['reason'])
end