def execute_serverinfo(event)
  unless event.server
    return send_embed(event, title: "⚠️ Error", description: "This command can only be used inside a server!")
  end

  server = event.server
  owner = server.owner
  created_time = server.creation_time.to_i

  # Fetch the Community Level and convert them to numbers!
  comm_stats = DB.get_community_level(server.id)
  current_level = comm_stats['level'].to_i
  current_xp = comm_stats['xp'].to_i
  next_level_xp = (100 * (current_level ** 2)) + (1000 * current_level)

  fields = [
    { name: '👑 Server Owner', value: owner ? owner.mention : "Unknown", inline: true },
    { name: '👥 Total Members', value: server.member_count.to_s, inline: true },
    { name: '✨ Community Rank', value: "**Level #{current_level}**\n*(#{current_xp} / #{next_level_xp} XP)*", inline: false },
    { name: '📅 Created On', value: "<t:#{created_time}:D> (<t:#{created_time}:R>)", inline: false }
  ]

  send_embed(
    event, 
    title: "📊 #{server.name} - Server Info", 
    description: "Here are the stats for **#{server.name}**:", 
    fields: fields,
    image: server.icon_url
  )
end

bot.command(:serverinfo, description: 'Displays information about the current server', category: 'Utility') { |e| execute_serverinfo(e); nil }
bot.application_command(:serverinfo) { |e| execute_serverinfo(e) }