def execute_help(event)
  embed = generate_category_embed(event.bot, event.user, 'Home')
  view = help_select_menu(event.user.id)

  if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
    event.respond(embeds: [embed], components: view)
  else
    event.channel.send_message(nil, false, embed, nil, nil, nil, view)
  end
end

bot.command(:help, description: 'Shows the interactive help menu', category: 'Utility') do |event|
  execute_help(event)
  nil
end

bot.application_command(:help) do |event|
  execute_help(event)
end