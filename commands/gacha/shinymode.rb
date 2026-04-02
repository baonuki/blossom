# ==========================================
# COMMAND: shinymode
# DESCRIPTION: Toggle Shiny Hunting Mode — 2x summon cost, 2% shiny chance.
# CATEGORY: Gacha (Premium Only)
# ==========================================

def execute_shinymode(event)
  uid = event.user.id

  unless is_premium?(event.bot, uid)
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Premium Only" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Shiny Hunting Mode is a **Premium** perk. You want the sparkle? Pay the price." }
    ]}])
  end

  new_state = DB.toggle_shiny_mode(uid)
  status = new_state ? "🟢 **ENABLED**" : "🔴 **DISABLED**"

  if new_state
    desc = "#{EMOJI_STRINGS['neonsparkle']} Shiny Hunting Mode is **LIVE**.\n\n" \
           "Summon cost is now **#{SUMMON_COST * 2}** #{EMOJI_STRINGS['s_coin']} (doubled).\n" \
           "Shiny Ascended chance boosted from **1%** to **2%**.\n\n" \
           "*High risk, high sparkle. Good luck, hunter.*"
  else
    desc = "Shiny Hunting Mode deactivated. Back to normal summon costs and standard 1% shiny rates.\n\n*Playing it safe? Understandable.*"
  end

  components = [{ type: 17, accent_color: new_state ? 0xFFD700 : 0x808080, components: [
    { type: 10, content: "## #{EMOJI_STRINGS['neonsparkle']} Shiny Mode: #{status}" },
    { type: 14, spacing: 1 },
    { type: 10, content: "#{desc}#{mom_remark(uid, 'gacha')}" }
  ]}]
  send_cv2(event, components)
end

# ------------------------------------------
# TRIGGERS
# ------------------------------------------
$bot.command(:shinymode, aliases: [:shiny, :shinyhunt],
  description: 'Toggle Shiny Hunting Mode — 2x cost, 2% shiny (Premium)',
  category: 'Gacha'
) do |event|
  execute_shinymode(event)
  nil
end

$bot.application_command(:shinymode) do |event|
  execute_shinymode(event)
end
