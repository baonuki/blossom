def execute_shop(event)
  embed, view = build_shop_home(event.user.id)
  if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
    event.respond(embeds: [embed], components: view)
  else
    event.channel.send_message(nil, false, embed, nil, { replied_user: false }, event.message, view)
  end
end

bot.command(:shop, description: 'View the character shop and direct-buy prices!', category: 'Gacha') { |e| execute_shop(e); nil }
bot.application_command(:shop) { |e| execute_shop(e) }