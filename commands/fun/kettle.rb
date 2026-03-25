def execute_kettle(event)
  if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
    event.respond(content: "#{EMOJIS['sparkle']} <@266358927401287680> #{EMOJIS['sparkle']}")
  else
    event.respond("#{EMOJIS['sparkle']} <@266358927401287680> #{EMOJIS['sparkle']}")
  end
end

bot.command(:kettle, description: 'Pings a specific user with a yay emoji', category: 'Fun') { |e| execute_kettle(e); nil }
bot.application_command(:kettle) { |e| execute_kettle(e) }