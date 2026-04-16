# ==========================================
# COMMAND: heist (Admin Only)
# DESCRIPTION: Configure the hourly heist event channel.
# CATEGORY: Admin
# ==========================================

def execute_heist_admin(event, action, channel_id = nil)
  unless event.user.permission?(:administrator, event.channel) || DEV_IDS.include?(event.user.id)
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Access Denied" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You need Admin perms to set up heists, chat." }
    ]}])
  end

  sid = event.server.id

  if action.nil?
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['confused']} Heist Setup" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Set up or disable hourly heist events.\n`#{PREFIX}heist setup #channel` \u2014 Enable heists in a channel\n`#{PREFIX}heist disable` \u2014 Turn off heists" }
    ]}])
  end

  case action.downcase
  when 'setup', 'enable', 'on'
    if channel_id.nil? || channel_id == 0
      return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['confused']} Which Channel?" },
        { type: 14, spacing: 1 },
        { type: 10, content: "Tag a channel for heist events!\n`#{PREFIX}heist setup #channel`" }
      ]}])
    end

    target_channel = event.bot.channel(channel_id, event.server)
    unless target_channel
      return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} Invalid Channel" },
        { type: 14, spacing: 1 },
        { type: 10, content: "That channel doesn't exist. Try again with a real one." }
      ]}])
    end

    DB.set_heist_channel(sid, channel_id)

    send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: [
      { type: 10, content: "## \u{1F3E6} Heist Events Enabled!" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Hourly heist events will now spawn in <##{channel_id}>!\n\nEvery hour, a vault job opportunity appears. Players have **5 minutes** to join. Minimum **#{HEIST_MIN_PLAYERS} players** needed to start the heist.\n\nSuccess odds scale with participants. Premium users get a hacker bonus!#{mom_remark(event.user.id, 'admin')}" }
    ]}])

  when 'disable', 'off'
    DB.set_heist_channel(sid, nil)
    ACTIVE_HEISTS.delete(sid)

    send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
      { type: 10, content: "## \u{1F3E6} Heist Events Disabled" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Heist events are off. The vault is safe... for now.#{mom_remark(event.user.id, 'admin')}" }
    ]}])

  else
    send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['confused']} Invalid Action" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Use `setup` or `disable`. That's it.\n`#{PREFIX}heist setup #channel` or `#{PREFIX}heist disable`" }
    ]}])
  end
end

# ------------------------------------------
# TRIGGERS
# ------------------------------------------
$bot.command(:heist, aliases: [:heists],
  description: 'Set up hourly heist events (Admin Only)',
  category: 'Admin'
) do |event, action, channel_mention|
  channel_id = channel_mention ? channel_mention.gsub(/[<#>]/, '').to_i : nil
  execute_heist_admin(event, action, channel_id)
  nil
end

$bot.application_command(:heist) do |event|
  channel_id = event.options['channel'] ? event.options['channel'].to_i : nil
  execute_heist_admin(event, event.options['action'], channel_id)
end
