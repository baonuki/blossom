# ==========================================
# COMMAND: derase (Developer Only)
# DESCRIPTION: Removes a target character from all users and issues Prisma refunds.
# CATEGORY: Developer
# ==========================================

def execute_derase(event)
  unless DEV_IDS.include?(event.user.id)
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Permission Denied" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Only my creator can use this." }
    ]}])
  end

  target_character = 'Kyvrixon'
  prisma_per_copy = 100
  summary = DB.erase_character_globally(target_character, prisma_per_copy)

  send_cv2(event, [{ type: 17, accent_color: 0x00FF99, components: [
    { type: 10, content: "## #{EMOJI_STRINGS['developer']} Global Erase Complete" },
    { type: 14, spacing: 1 },
    { type: 10, content: "**Target:** #{target_character}\n**Users affected:** #{summary[:users]}\n**Copies removed:** #{summary[:copies_removed]}\n**Prisma refunded:** #{summary[:prisma_refunded]} (#{prisma_per_copy} each)#{mom_remark(event.user.id, 'dev')}" }
  ]}])
end

$bot.command(:derase,
  description: 'Remove Kyvrixon from all users and refund Prisma (Dev Only)',
  category: 'Developer'
) do |event|
  execute_derase(event)
  nil
end
