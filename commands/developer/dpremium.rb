# ==========================================
# COMMAND: dpremium (Developer Only)
# DESCRIPTION: Unified premium management. Give or remove lifetime premium.
# CATEGORY: Developer
# ==========================================

DPREMIUM_USAGE = "**Usage:**\n" \
                 "`dpremium give @user` — Grant lifetime premium\n" \
                 "`dpremium remove @user` — Revoke lifetime premium"

def execute_dpremium(event, action, target_user)
  # 1. Security: Developer-Only
  unless DEV_IDS.include?(event.user.id)
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Permission Denied" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Only my creator can manage premium status." }
    ]}])
  end

  # 2. Validation: Action
  if action.nil?
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['confused']} How Does This Work?" },
      { type: 14, spacing: 1 },
      { type: 10, content: DPREMIUM_USAGE }
    ]}])
  end

  unless %w[give remove].include?(action.downcase)
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['confused']} Invalid Action" },
      { type: 14, spacing: 1 },
      { type: 10, content: "**#{action}** isn't valid. Use `give` or `remove`.\n\n#{DPREMIUM_USAGE}" }
    ]}])
  end

  # 3. Validation: Target
  if target_user.nil?
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['confused']} Who??" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Mention someone.\n\n#{DPREMIUM_USAGE}" }
    ]}])
  end

  case action.downcase
  when 'give'
    DB.set_lifetime_premium(target_user.id, true)
    send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['neonsparkle']} Lifetime Premium Granted!" },
      { type: 14, spacing: 1 },
      { type: 10, content: "**#{target_user.display_name}** has been permanently upgraded!\n10% coin boost, half cooldowns, boosted gacha luck — the works." }
    ]}])

  when 'remove'
    DB.set_lifetime_premium(target_user.id, false)
    send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
      { type: 10, content: "## 🥀 Premium Revoked" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Lifetime Premium removed from **#{target_user.display_name}**." }
    ]}])
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!dpremium)
# ------------------------------------------
$bot.command(:dpremium,
  description: 'Manage lifetime premium — give or remove (Dev Only)',
  category: 'Developer'
) do |event, action, mention|
  execute_dpremium(event, action, event.message.mentions.first)
  nil
end
