# ==========================================
# COMMAND: tipsetup
# DESCRIPTION: Configure daily tip/fact channel.
# CATEGORY: Admin
# ==========================================

def execute_tipsetup(event, channel_id = nil)
  unless event.user.permission?(:administrator, event.channel) || DEV_IDS.include?(event.user.id)
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Access Denied" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You need Admin perms to set up daily tips." }
    ]}])
  end

  if channel_id.nil? || channel_id == 0
    # Check current state
    current = DB.get_tip_channel(event.server.id)
    if current
      DB.set_tip_channel(event.server.id, nil)
      return send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
        { type: 10, content: "## \u{1F4A1} Daily Tips Disabled" },
        { type: 14, spacing: 1 },
        { type: 10, content: "Daily tips turned off. Use `#{PREFIX}tipsetup #channel` to re-enable.#{mom_remark(event.user.id, 'admin')}" }
      ]}])
    end
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['confused']} Tip Setup" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Set a channel for daily Blossom tips!\n`#{PREFIX}tipsetup #channel` \u2014 Enable\n`#{PREFIX}tipsetup` \u2014 Disable (if already set)" }
    ]}])
  end

  DB.set_tip_channel(event.server.id, channel_id)
  send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: [
    { type: 10, content: "## \u{1F4A1} Daily Tips Enabled!" },
    { type: 14, spacing: 1 },
    { type: 10, content: "I'll post a daily tip or fun fact in <##{channel_id}> every day. You're welcome.#{mom_remark(event.user.id, 'admin')}" }
  ]}])
end

$bot.command(:tipsetup,
  description: 'Set daily tip channel (Admin Only)',
  category: 'Admin'
) do |event, channel_mention|
  channel_id = channel_mention ? channel_mention.gsub(/[<#>]/, '').to_i : nil
  execute_tipsetup(event, channel_id)
  nil
end

$bot.application_command(:tipsetup) do |event|
  channel_id = event.options['channel'] ? event.options['channel'].to_i : nil
  execute_tipsetup(event, channel_id)
end
