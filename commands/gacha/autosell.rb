# ==========================================
# COMMAND: autosell
# DESCRIPTION: Toggle automatic selling of commons you own 5+ of when pulling.
# CATEGORY: Gacha (Premium Only)
# ==========================================

def execute_autosell(event)
  uid = event.user.id

  unless is_premium?(event.bot, uid)
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Premium Only" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Auto-Sell is a **Premium** perk. Upgrade to stop hoarding commons like a digital pack rat." }
    ]}])
  end

  new_state = DB.toggle_autosell(uid)
  status = new_state ? "🟢 **ENABLED**" : "🔴 **DISABLED**"
  desc = new_state ? "When you pull a common you already own **5+** of, it'll auto-sell for **#{SELL_PRICES['common']}** #{EMOJI_STRINGS['s_coin']}. Less clutter, more coins." : "Auto-Sell deactivated. Your commons will pile up again. Hope you like hoarding."

  components = [{ type: 17, accent_color: new_state ? 0x00FF00 : 0xFF0000, components: [
    { type: 10, content: "## ♻️ Auto-Sell: #{status}" },
    { type: 14, spacing: 1 },
    { type: 10, content: "#{desc}#{mom_remark(uid, 'gacha')}" }
  ]}]
  send_cv2(event, components)
end

# ------------------------------------------
# TRIGGERS
# ------------------------------------------
$bot.command(:autosell, aliases: [:as],
  description: 'Toggle auto-sell for common dupes (Premium)',
  category: 'Gacha'
) do |event|
  execute_autosell(event)
  nil
end

$bot.application_command(:autosell) do |event|
  execute_autosell(event)
end
