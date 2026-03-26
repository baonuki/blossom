# ==========================================
# COMMAND: dcoin (Developer Only)
# DESCRIPTION: Unified coin management. Add, remove, or set a user's balance.
# CATEGORY: Developer
# ==========================================

DCOIN_USAGE = "**Usage:**\n" \
              "`dcoin add @user <amount>` — Add coins\n" \
              "`dcoin remove @user <amount>` — Remove coins (won't go below 0)\n" \
              "`dcoin set @user <amount>` — Force-set balance"

def execute_dcoin(event, action, target_user, amount)
  # 1. Security: Developer-Only
  unless DEV_IDS.include?(event.user.id)
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Permission Denied" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Only my creator can use this." }
    ]}])
  end

  # 2. Validation: Action
  if action.nil?
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['confused']} How Does This Work?" },
      { type: 14, spacing: 1 },
      { type: 10, content: DCOIN_USAGE }
    ]}])
  end

  unless %w[add remove set].include?(action.downcase)
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['confused']} Invalid Action" },
      { type: 14, spacing: 1 },
      { type: 10, content: "**#{action}** isn't valid. Use `add`, `remove`, or `set`.\n\n#{DCOIN_USAGE}" }
    ]}])
  end

  # 3. Validation: Target
  if target_user.nil?
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['confused']} Who??" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Mention someone.\n\n#{DCOIN_USAGE}" }
    ]}])
  end

  # 4. Validation: Amount
  if amount.nil? || amount == 0
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['confused']} How Much?" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Give me a number.\n\n#{DCOIN_USAGE}" }
    ]}])
  end

  uid = target_user.id

  case action.downcase
  when 'add'
    DB.add_coins(uid, amount.abs)
    send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['developer']} Developer Override" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Added **#{amount.abs}** #{EMOJI_STRINGS['s_coin']} to #{target_user.mention}.\nNew balance: **#{DB.get_coins(uid)}** #{EMOJI_STRINGS['s_coin']}" }
    ]}])

  when 'remove'
    current = DB.get_coins(uid)
    actual = [amount.abs, current].min
    DB.add_coins(uid, -actual)
    send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['developer']} Developer Override" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Removed **#{actual}** #{EMOJI_STRINGS['s_coin']} from #{target_user.mention}.\nNew balance: **#{DB.get_coins(uid)}** #{EMOJI_STRINGS['s_coin']}" }
    ]}])

  when 'set'
    DB.set_coins(uid, amount.abs)
    send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['developer']} Developer Override" },
      { type: 14, spacing: 1 },
      { type: 10, content: "#{target_user.mention}'s balance forcefully set to **#{DB.get_coins(uid)}** #{EMOJI_STRINGS['s_coin']}." }
    ]}])
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!dcoin)
# ------------------------------------------
$bot.command(:dcoin,
  description: 'Manage user coins — add, remove, or set (Dev Only)',
  category: 'Developer'
) do |event, action, mention, amount|
  target = event.message.mentions.first
  execute_dcoin(event, action, target, amount.nil? ? nil : amount.to_i)
  nil
end
