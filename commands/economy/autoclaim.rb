# ==========================================
# COMMAND: autoclaim
# DESCRIPTION: Toggle automatic daily reward claiming (Premium).
# CATEGORY: Economy
# ==========================================

def execute_autoclaim(event)
  uid = event.user.id

  # Premium gate
  unless is_premium?(event.bot, uid)
    return send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['prisma']} Premium Perk" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Auto-claim daily is a **Blossom Premium** feature! I'll collect your daily reward automatically so you never miss a day.\n\nCheck out `/premium` to see what you're missing." }
    ]}])
  end

  new_state = DB.toggle_autoclaim(uid)

  if new_state
    components = [{ type: 17, accent_color: 0x00FF00, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['checkmark']} Auto-Claim Daily" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Auto-claim is **ON**! I'll automatically collect your daily reward whenever it's ready. No more broken streaks — I gotchu.\n\nYou'll get a DM with your reward summary each time I claim for you.#{mom_remark(uid, 'economy')}" }
    ]}]
  else
    components = [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['checkmark']} Auto-Claim Daily" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Auto-claim is **OFF**. You're on your own now, don't forget to claim manually! If your streak dies, that's on you.#{mom_remark(uid, 'general')}" }
    ]}]
  end
  send_cv2(event, components)
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!autoclaim)
# ------------------------------------------
$bot.command(:autoclaim,
  description: 'Toggle automatic daily claiming (Premium)',
  category: 'Economy'
) do |event|
  execute_autoclaim(event)
  nil
end

# ------------------------------------------
# TRIGGER: Slash Command (/autoclaim)
# ------------------------------------------
$bot.application_command(:autoclaim) do |event|
  execute_autoclaim(event)
end
