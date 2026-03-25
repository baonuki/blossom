def execute_ban(event, user_input, reason)
  return mod_reply(event, "❌ *You don't have permission to do that!*", is_ephemeral: true) unless event.user.permission?(:ban_members)
  
  target_id = parse_id(user_input)
  return mod_reply(event, "🌸 *Please provide a valid user ID or mention!*", is_ephemeral: true) unless target_id
  
  reason = "No reason provided." if reason.nil? || reason.to_s.strip.empty?

  begin
    member = event.server.member(target_id)
    config = DB.get_log_config(event.server.id)
    
    # Send DM before banning if possible
    member.pm("You have been banned from **#{event.server.name}**.\nReason: #{reason}") rescue nil if config[:dm_mods] && member

    event.server.ban(target_id, 0, reason: reason)
    mod_reply(event, "🔨 Successfully banned ID **#{target_id}**.\n*Reason:* #{reason}")

    mention = member ? member.mention : "<@#{target_id}>"
    distinct = member ? member.distinct : "Unknown Tag"

    log_mod_action(
      event.bot, 
      event.server.id, 
      "🔨 Member Banned", 
      "**User:** #{mention} (#{distinct})\n**Moderator:** #{event.user.mention}\n**Reason:** #{reason}",
      0x8B0000
    )
  rescue => e
    mod_reply(event, "❌ *Action Failed! Error:* `#{e.message}`\n*(Make sure my Bot Role is placed higher than theirs!)*", is_ephemeral: true)
  end
end

bot.command(:ban, description: 'Bans a user (or ID)', required_permissions: [:ban_members]) do |event, user_input, *reason_array|
  reason = reason_array.join(' ')
  execute_ban(event, user_input, reason)
  nil
end

bot.application_command(:ban) do |event|
  execute_ban(event, event.options['user'], event.options['reason'])
end