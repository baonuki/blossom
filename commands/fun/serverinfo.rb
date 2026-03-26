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
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['error']} Error" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You gotta be in a server for this one, chief." }
    ]}])
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

  # 5. Messaging: Construct and send the final Server Info CV2 message
  send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
    { type: 10, content: "## 📊 #{server.name} — The Rundown" },
    { type: 14, spacing: 1 },
    { type: 10, content: "Alright, here's what we're working with in **#{server.name}**:" },
    { type: 14, spacing: 1 },
    { type: 10, content: "**#{EMOJI_STRINGS['crown']} Server Owner:** #{owner ? owner.mention : "Unknown"}" },
    { type: 10, content: "**👥 Total Members:** #{server.member_count}" },
    { type: 10, content: "**#{EMOJI_STRINGS['neonsparkle']} Community Rank:** **Level #{current_level}**\n*(#{current_xp} / #{next_level_xp} XP)*" },
    { type: 10, content: "**📅 Created On:** <t:#{created_time}:D> (<t:#{created_time}:R>)" },
    { type: 14, spacing: 1 },
    { type: 12, items: [{ media: { url: server.icon_url } }] }
  ]}])
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!serverinfo)
# ------------------------------------------
$bot.command(:serverinfo, 
  description: 'Displays information about the current server', 
  category: 'Utility'
) do |event|
  execute_serverinfo(event)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/serverinfo)
# ------------------------------------------
$bot.application_command(:serverinfo) do |event|
  execute_serverinfo(event)
end