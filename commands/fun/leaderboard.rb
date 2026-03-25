def execute_leaderboard(event)
  unless event.server
    error_msg = "❌ This command can only be used in a server!"
    if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
      return event.respond(content: error_msg, ephemeral: true)
    else
      return event.respond(error_msg)
    end
  end

  default_page = 'server_users'
  uid = event.user.id
  
  embed = generate_leaderboard_page(event.bot, event.server, default_page)
  view = leaderboard_select_menu(uid, default_page)

  if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
    event.respond(embeds: [embed], components: view)
  else
    event.channel.send_message(nil, false, embed, nil, nil, event.message, view)
  end
end

bot.command(:leaderboard, description: 'View the local and global leaderboards!', category: 'Fun') { |e| execute_leaderboard(e); nil }
bot.application_command(:leaderboard) { |e| execute_leaderboard(e) }