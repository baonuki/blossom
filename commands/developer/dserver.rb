# ==========================================
# COMMAND: dserver (Developer Only)
# DESCRIPTION: DMs info to the developer — currently a list of every server
# Blossom is connected to, sorted alphabetically by name. Chunked across
# multiple DMs so we never trip Discord's 2000-char message limit.
# CATEGORY: Developer
# ==========================================

DSERVER_DM_CHAR_LIMIT = 1900

def execute_dserver(event)
  unless DEV_IDS.include?(event.user.id)
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Permission Denied" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Only my creator can use this." }
    ]}])
  end

  servers = event.bot.servers.values
  total = servers.size

  if total.zero?
    return send_cv2(event, [{ type: 17, accent_color: 0xFFA500, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['confused']} No Servers" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Uh... I'm not actually in any servers right now? That's weird, mom." }
    ]}])
  end

  names = servers.map { |s| s.name.to_s }.sort_by(&:downcase)

  # Chunk lines into messages under Discord's 2000-char cap.
  header = "## #{EMOJI_STRINGS['stream']} Connected Servers (#{total})\n\n"
  chunks = []
  current = String.new(header)
  names.each_with_index do |name, i|
    line = "#{i + 1}. #{name}\n"
    if current.length + line.length > DSERVER_DM_CHAR_LIMIT
      chunks << current
      current = String.new
    end
    current << line
  end
  chunks << current unless current.empty?

  begin
    pm_channel = event.user.pm
    chunks.each { |chunk| pm_channel.send_message(chunk) }
  rescue StandardError => e
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['error']} DM Failed" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Couldn't slide into your DMs, mom — `#{e.class}: #{e.message}`. Check your privacy settings?" }
    ]}])
  end

  send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
    { type: 10, content: "## #{EMOJI_STRINGS['checkmark']} Server List Sent" },
    { type: 14, spacing: 1 },
    { type: 10, content: "Slid **#{total}** server name#{total == 1 ? '' : 's'} into your DMs across **#{chunks.size}** message#{chunks.size == 1 ? '' : 's'}, mom. Check your inbox." }
  ]}])
end

# ------------------------------------------
# TRIGGERS: Prefix Only (intentional — no slash variant)
# ------------------------------------------
$bot.command(:dserver,
  description: "DMs info to the developer (Dev Only)",
  category: 'Developer'
) do |event|
  execute_dserver(event)
  nil
end
