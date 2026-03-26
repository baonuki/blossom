# ==========================================
# COMMAND: bomb (Admin Only)
# DESCRIPTION: Unified bomb management. Enable or disable random bomb drops.
# CATEGORY: Admin
# ==========================================

# ------------------------------------------
# LOGIC: Bomb Toggle Execution
# ------------------------------------------
def execute_bomb_admin(event, action, channel_id = nil)
  # 1. Security: Permission Check (Admins or Developer Only)
  unless event.user.permission?(:administrator, event.channel) || DEV_IDS.include?(event.user.id)
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Access Denied" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You need Admin perms to mess with bombs, chat." }
    ]}])
  end

  sid = event.server.id

  if action.nil?
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['confused']} What Do I Do?" },
      { type: 14, spacing: 1 },
      { type: 10, content: "What do you want me to do? Use `enable` or `disable`.\n`#{PREFIX}bomb enable #channel` or `#{PREFIX}bomb disable`" }
    ]}])
  end

  case action.downcase
  when 'enable', 'on'
    # Validation: Need a channel to drop bombs in
    if channel_id.nil? || channel_id == 0
      return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['confused']} Enable WHERE?" },
        { type: 14, spacing: 1 },
        { type: 10, content: "Mention a channel!\n`#{PREFIX}bomb enable #channel`" }
      ]}])
    end

    target_channel = event.bot.channel(channel_id, event.server)
    if target_channel.nil?
      return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} Invalid Channel" },
        { type: 14, spacing: 1 },
        { type: 10, content: "That channel doesn't exist. Try again, chat." }
      ]}])
    end

    threshold = rand(BOMB_MIN_MESSAGES..BOMB_MAX_MESSAGES)
    SERVER_BOMB_CONFIGS[sid] = {
      'enabled' => true,
      'channel_id' => channel_id,
      'message_count' => 0,
      'last_user_id' => nil,
      'threshold' => threshold
    }
    DB.save_bomb_config(sid, true, channel_id, threshold, 0)

    send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['bomb']} Bomb Drops Enabled!" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Bombs are now live in <##{channel_id}>! Chat at your own risk~" }
    ]}])

  when 'disable', 'off'
    if SERVER_BOMB_CONFIGS[sid]
      SERVER_BOMB_CONFIGS[sid]['enabled'] = false
      DB.save_bomb_config(sid, false, SERVER_BOMB_CONFIGS[sid]['channel_id'], 0, 0)
    end

    send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['bomb']} Bomb Drops Disabled" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Bomb drops disabled. The arcade is safe... for now." }
    ]}])

  else
    send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['confused']} Invalid Action" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Use `enable` or `disable`, chat.\n`#{PREFIX}bomb enable #channel` or `#{PREFIX}bomb disable`" }
    ]}])
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!bomb)
# ------------------------------------------
$bot.command(:bomb,
  description: 'Enable or disable bomb drops (Admin Only)',
  category: 'Admin'
) do |event, action, channel_mention|
  channel_id = channel_mention ? channel_mention.gsub(/[<#>]/, '').to_i : nil
  execute_bomb_admin(event, action, channel_id)
  nil
end

# ------------------------------------------
# TRIGGER: Slash Command (/bomb)
# ------------------------------------------
$bot.application_command(:bomb) do |event|
  channel_id = event.options['channel'] ? event.options['channel'].to_i : nil
  execute_bomb_admin(event, event.options['action'], channel_id)
end
