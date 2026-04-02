# ==========================================
# COMMAND: giftlog
# DESCRIPTION: View your card gifting history.
# CATEGORY: Gacha
# ==========================================

RARITY_EMOJI_MAP = {
  'goddess'   => EMOJI_STRINGS['goddess'],
  'legendary' => EMOJI_STRINGS['legendary'],
  'rare'      => EMOJI_STRINGS['rare'],
  'common'    => EMOJI_STRINGS['common']
}.freeze

def execute_giftlog(event, page = 1)
  uid = event.user.id
  page = [page.to_i, 1].max

  data = DB.get_gift_log(uid, page)

  if data[:total] == 0
    return send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['info']} Gift Log" },
      { type: 14, spacing: 1 },
      { type: 10, content: "No gifts on record. You haven't given or received any cards yet. Go be social." }
    ]}])
  end

  lines = data[:rows].map do |row|
    emoji = RARITY_EMOJI_MAP[row['rarity']] || EMOJI_STRINGS['common']
    timestamp = "<t:#{Time.parse(row['gifted_at']).to_i}:d>"
    if row['giver_id'].to_i == uid
      "#{emoji} **#{row['character_name']}** → <@#{row['receiver_id']}> · #{timestamp}"
    else
      "#{emoji} **#{row['character_name']}** ← <@#{row['giver_id']}> · #{timestamp}"
    end
  end

  components = [{ type: 17, accent_color: NEON_COLORS.sample, components: [
    { type: 10, content: "## #{EMOJI_STRINGS['surprise']} Gift Log" },
    { type: 14, spacing: 1 },
    { type: 10, content: "→ = sent · ← = received\n\n#{lines.join("\n")}" },
    { type: 14, spacing: 1 },
    { type: 10, content: "Page **#{page}** / **#{[data[:pages], 1].max}** · #{data[:total]} total gifts#{mom_remark(uid, 'gacha')}" }
  ]}]
  send_cv2(event, components)
end

# ------------------------------------------
# TRIGGERS
# ------------------------------------------
$bot.command(:giftlog, aliases: [:gifts, :gifthistory],
  description: 'View your card gifting history',
  category: 'Gacha'
) do |event, page|
  execute_giftlog(event, page || 1)
  nil
end

$bot.application_command(:giftlog) do |event|
  execute_giftlog(event, event.options['page'] || 1)
end
