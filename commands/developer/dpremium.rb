# ==========================================
# COMMAND: dpremium (Developer Only)
# DESCRIPTION: Unified premium management. Give or remove lifetime premium.
# CATEGORY: Developer
# ==========================================

DPREMIUM_USAGE = "**Usage:**\n" \
                 "`dpremium give @user` or `dpremium give <user_id>` — Grant lifetime premium\n" \
                 "`dpremium remove @user` or `dpremium remove <user_id>` — Revoke lifetime premium"

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
      { type: 10, content: "Mention someone or give me a user ID.\n\n#{DPREMIUM_USAGE}" }
    ]}])
  end

  # Resolve display name (may be nil if user isn't cached)
  display_name = target_user.respond_to?(:display_name) ? target_user.display_name : target_user.username
  target_id = target_user.id

  case action.downcase
  when 'give'
    DB.set_lifetime_premium(target_id, true)
    CACHE.invalidate(:premium, target_id)
    send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['neonsparkle']} Lifetime Premium Granted!" },
      { type: 14, spacing: 1 },
      { type: 10, content: "**#{display_name}** (`#{target_id}`) has been permanently upgraded!\n10% coin boost, half cooldowns, boosted gacha luck — the works.#{mom_remark(event.user.id, 'dev')}" }
    ]}])

  when 'remove'
    DB.set_lifetime_premium(target_id, false)
    CACHE.invalidate(:premium, target_id)
    send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
      { type: 10, content: "## 🥀 Premium Revoked" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Lifetime Premium removed from **#{display_name}** (`#{target_id}`).#{mom_remark(event.user.id, 'dev')}" }
    ]}])
  end
end

# ------------------------------------------
# HELPER: Resolve a user from mention or raw ID
# ------------------------------------------
def resolve_dpremium_target(event, raw_arg)
  # First try mentions
  mentioned = event.message.mentions.first
  return mentioned if mentioned

  # Then try raw user ID
  return nil if raw_arg.nil?
  clean_id = raw_arg.gsub(/\D/, '')
  return nil if clean_id.empty?

  begin
    event.bot.user(clean_id.to_i)
  rescue
    nil
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!dpremium)
# ------------------------------------------
$bot.command(:dpremium, aliases: [:dp],
  description: 'Manage lifetime premium — give or remove (Dev Only)',
  category: 'Developer'
) do |event, action, raw_target|
  target_user = resolve_dpremium_target(event, raw_target)
  execute_dpremium(event, action, target_user)
  nil
end
