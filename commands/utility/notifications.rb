# ==========================================
# COMMAND: notifications
# DESCRIPTION: Set how achievement notifications are delivered.
# CATEGORY: Utility
# ==========================================

NOTIFY_MODES = {
  'channel' => { label: 'Channel', desc: 'Achievements show up in the channel where you earned them.', emoji: '📢' },
  'dm'      => { label: 'DM', desc: 'Achievements are sent to your DMs privately.', emoji: '📩' },
  'silent'  => { label: 'Silent', desc: 'No notifications. You still earn achievements, they just stay quiet.', emoji: '🔇' }
}.freeze

def execute_notifications(event, mode = nil)
  uid = event.user.id
  current = DB.get_ach_notify(uid)

  if mode.nil?
    info = NOTIFY_MODES[current]
    components = [{ type: 17, accent_color: NEON_COLORS.sample, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['info']} Achievement Notifications" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Current mode: **#{info[:emoji]} #{info[:label]}**\n#{info[:desc]}\n\nTo change: `#{PREFIX}notifications <channel|dm|silent>`" }
    ]}]
    return send_cv2(event, components)
  end

  mode = mode.downcase
  unless NOTIFY_MODES.key?(mode)
    components = [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['error']} Invalid Mode" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Pick one: `channel`, `dm`, or `silent`.\nExample: `#{PREFIX}notifications dm`" }
    ]}]
    return send_cv2(event, components)
  end

  DB.set_ach_notify(uid, mode)
  info = NOTIFY_MODES[mode]

  components = [{ type: 17, accent_color: 0x00FF00, components: [
    { type: 10, content: "## #{EMOJI_STRINGS['checkmark']} Notifications Updated" },
    { type: 14, spacing: 1 },
    { type: 10, content: "Set to **#{info[:emoji]} #{info[:label]}**.\n#{info[:desc]}#{mom_remark(uid, 'utility')}" }
  ]}]
  send_cv2(event, components)
end

# ------------------------------------------
# TRIGGERS
# ------------------------------------------
$bot.command(:notifications, aliases: [:notify, :achnotify],
  description: 'Set achievement notification mode (channel/dm/silent)',
  category: 'Utility'
) do |event, mode|
  execute_notifications(event, mode)
  nil
end

$bot.application_command(:notifications) do |event|
  execute_notifications(event, event.options['mode'])
end
