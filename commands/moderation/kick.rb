def execute_kick(event, member, reason)
  return mod_reply(event, "❌ *You don't have permission to do that!*", is_ephemeral: true) unless event.user.permission?(:kick_members)
  return mod_reply(event, "🌸 *I couldn't find that user in this server!*", is_ephemeral: true) unless member
  
  reason = "No reason provided." if reason.nil? || reason.to_s.strip.empty?

  begin
    config = DB.get_log_config(event.server.id)
    member.pm("You have been kicked from **#{event.server.name}**.\nReason: #{reason}") rescue nil if config[:dm_mods]
    event.server.kick(member, reason)
    mod_reply(event, "👢 Successfully kicked **#{member.display_name}**.\n*Reason:* #{reason}")

    log_mod_action(
      event.bot, 
      event.server.id, 
      "👢 Member Kicked", 
      "**User:** #{member.mention} (#{member.distinct})\n**Moderator:** #{event.user.mention}\n**Reason:** #{reason}",
      0xFF8C00
    )
  rescue => e
    mod_reply(event, "❌ *Action Failed! Error:* `#{e.message}`\n*(Make sure my Bot Role is placed higher than theirs!)*", is_ephemeral: true)
  end
end

bot.command(:kick, description: 'Kicks a user', required_permissions: [:kick_members]) do |event, user_input, *reason_array|
  member = parse_member(event, user_input)
  reason = reason_array.join(' ')
  execute_kick(event, member, reason)
  nil
end

bot.application_command(:kick) do |event|
  member = parse_member(event, event.options['user'])
  execute_kick(event, member, event.options['reason'])
end