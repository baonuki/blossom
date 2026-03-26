# ==========================================
# COMMAND: logtoggle
# DESCRIPTION: Enable or disable specific logging categories for the server.
# CATEGORY: Moderation
# ==========================================

# ------------------------------------------
# LOGIC: Toggle Execution
# ------------------------------------------
def execute_logtoggle(event, type)
  # 1. Security: Ensure the user has "Manage Server" permissions
  # Toggling logs is a high-level config change that shouldn't be accessible to junior mods.
  unless event.user.permission?(:manage_server) || DEV_IDS.include?(event.user.id)
    return event.respond(content: "#{EMOJI_STRINGS['x_']} *You need the Manage Server permission to do this!*", ephemeral: true)
  end

  # 2. Validation: Map user-friendly names to actual database columns
  valid_types = {
    'deletes' => 'log_deletes',
    'edits'   => 'log_edits',
    'mod'     => 'log_mod',
    'dms'     => 'dm_mods'
  }

  type = type&.downcase

  unless valid_types.key?(type)
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['confused']} Toggle What?" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Tell me what to toggle: `deletes`, `edits`, `mod`, or `dms`.\n`#{PREFIX}logtoggle <type>`" }
    ]}])
  end

  # 3. Database: Execute the toggle logic
  # DB.toggle_log_setting should flip the boolean value and return the new state.
  db_column = valid_types[type]
  is_now_on = DB.toggle_log_setting(event.server.id, db_column)

  # 4. UI: Determine the visual status indicator
  status = is_now_on ? "**ON** :green_circle:" : "**OFF** :red_circle:"

  # 5. Feedback: Confirm the update to the administrator
  send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
    { type: 10, content: "## :gear: Logging Updated" },
    { type: 14, spacing: 1 },
    { type: 10, content: "Logging for **#{type}** is now #{status}." }
  ]}])
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!logtoggle)
# ------------------------------------------
$bot.command(:logtoggle,
  description: 'Toggle logging for deletes, edits, or mod actions',
  category: 'Moderation'
) do |event, type|
  execute_logtoggle(event, type)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/logtoggle)
# ------------------------------------------
$bot.application_command(:logtoggle) do |event|
  # Capture the 'type' option from the Slash interaction
  execute_logtoggle(event, event.options['type'])
end
