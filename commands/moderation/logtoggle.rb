def execute_logtoggle(event, type)
  unless event.user.permission?(:manage_server) || event.user.id == DEV_ID
    return mod_reply(event, "❌ *You need the Manage Server permission to do this!*", is_ephemeral: true)
  end

  valid_types = { 'deletes' => 'log_deletes', 'edits' => 'log_edits', 'mod' => 'log_mod', 'dms' => 'dm_mods' }
  type = type&.downcase

  unless valid_types.key?(type)
    return mod_reply(event, "⚠️ *Please specify what you want to toggle: `deletes`, `edits`, `mod`, or `dms`.*", is_ephemeral: true)
  end

  db_column = valid_types[type]
  is_now_on = DB.toggle_log_setting(event.server.id, db_column)
  status = is_now_on ? "**ON** 🟢" : "**OFF** 🔴"

  mod_reply(event, "⚙️ **Logging Updated**\nLogging for **#{type}** is now #{status}.")
end

bot.command(:logtoggle, description: 'Toggle logging for deletes, edits, or mod actions') do |event, type|
  execute_logtoggle(event, type)
  nil
end

bot.application_command(:logtoggle) do |event|
  execute_logtoggle(event, event.options['type'])
end