# ==========================================
# COMMAND: commleveltoggle
# DESCRIPTION: Toggle community level-up announcements on or off for this server.
# CATEGORY: Moderation / Admin
# ==========================================

def execute_commleveltoggle(event)
  # Only allow server admins or developer to toggle
  unless event.user.permission?(:manage_server) || DEV_IDS.include?(event.user.id)
    return event.respond(content: "#{EMOJI_STRINGS['x_']} *You need the Manage Server permission or be the developer to do this!*", ephemeral: true)
  end

  server_id = event.server.id
  enabled = DB.toggle_community_levelup(server_id)
  status = enabled ? "**enabled** :green_circle:" : "**disabled** :red_circle:"

  send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
    { type: 10, content: "## :globe_with_meridians: Community Level-Ups" },
    { type: 14, spacing: 1 },
    { type: 10, content: "Community level-up announcements are now #{status} for this server." }
  ]}])
end

$bot.command(:commleveltoggle,
  description: 'Toggle community level-up announcements',
  required_permissions: [:manage_server]
) do |event|
  execute_commleveltoggle(event)
  nil
end

$bot.application_command(:commleveltoggle) do |event|
  execute_commleveltoggle(event)
end
