def execute_interactions(event)
  data = DB.get_interactions(event.user.id)
  send_embed(event, title: "#{event.user.display_name}'s Interaction Stats", description: '', fields: [
    { name: "#{EMOJIS['hearts']} Hugs", value: "Sent: **#{data['hug']['sent']}**\nReceived: **#{data['hug']['received']}**", inline: true },
    { name: "#{EMOJIS['bonk']} Slaps", value: "Sent: **#{data['slap']['sent']}**\nReceived: **#{data['slap']['received']}**", inline: true }
  ])
end

bot.command(:interactions, description: 'Show your hug/slap stats', category: 'Fun') { |e| execute_interactions(e); nil }
bot.application_command(:interactions) { |e| execute_interactions(e) }