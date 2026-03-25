# ==========================================
# COMMAND: serverinfo
# DESCRIPTION: Displays technical stats and the "Community Level" for the current server.
# CATEGORY: Utility / Social
# ==========================================

# ------------------------------------------
# LOGIC: Server Info Execution
# ------------------------------------------
def execute_serverinfo(event)
  # 1. Validation: Ensure the command is not run in DMs
  # Server metadata and Community XP require a guild context.
  unless event.server
    return send_embed(event, 
      title: "⚠️ Error", 
      description: "This command can only be used inside a server!"
    )
  end

  # 2. Initialization: Gather basic server metadata
  server = event.server
  owner = server.owner
  created_time = server.creation_time.to_i

  # 3. Data Retrieval: Fetch the server's specific "Community Level" from the DB
  comm_stats = DB.get_community_level(server.id)
  current_level = comm_stats['level'].to_i
  current_xp = comm_stats['xp'].to_i
  
  # 4. Math: Calculate the quadratic XP curve for the next level
  # Formula: (100 * Level^2) + (1000 * Level)
  next_level_xp = (100 * (current_level ** 2)) + (1000 * current_level)

  # 5. UI: Prepare the data fields for the Embed
  fields = [
    { name: '👑 Server Owner', value: owner ? owner.mention : "Unknown", inline: true },
    { name: '👥 Total Members', value: server.member_count.to_s, inline: true },
    { name: '✨ Community Rank', value: "**Level #{current_level}**\n*(#{current_xp} / #{next_level_xp} XP)*", inline: false },
    { name: '📅 Created On', value: "<t:#{created_time}:D> (<t:#{created_time}:R>)", inline: false }
  ]

  # 6. Messaging: Construct and send the final Server Info Embed
  send_embed(
    event, 
    title: "📊 #{server.name} - Server Info", 
    description: "Here are the stats for **#{server.name}**:", 
    fields: fields,
    image: server.icon_url # Sets the server icon as the embed's large image
  )
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!serverinfo)
# ------------------------------------------
bot.command(:serverinfo, 
  description: 'Displays information about the current server', 
  category: 'Utility'
) do |event|
  execute_serverinfo(event)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/serverinfo)
# ------------------------------------------
bot.application_command(:serverinfo) do |event|
  execute_serverinfo(event)
end