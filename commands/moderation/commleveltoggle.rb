# ==========================================
# COMMAND: commleveltoggle
# DESCRIPTION: Toggle community level-up announcements on or off for this server.
# CATEGORY: Moderation / Admin
# ==========================================

def execute_commleveltoggle(event)
  # Only allow server admins or developer to toggle
  unless event.user.permission?(:manage_server) || event.user.id == DEV_ID
    return mod_reply(event, "❌ *You need the Manage Server permission or be the developer to do this!*", is_ephemeral: true)
  end

  server_id = event.server.id
  enabled = DB.toggle_community_levelup(server_id)
  status = enabled ? 'enabled' : 'disabled'
  mod_reply(event, "🌐 Community level-up announcements are now **#{status}** for this server.")
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
