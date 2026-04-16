# ==========================================
# COMMAND: friends
# DESCRIPTION: View friendship levels and affinity with other players.
# CATEGORY: Fun
# ==========================================

def execute_friends(event, target = nil)
  uid = event.user.id

  if target
    # View friendship with specific user
    target_id = target.id
    friendship = DB.get_friendship(uid, target_id)
    tier = friendship_tier(friendship['affinity'])
    bonus = friendship_bonus(friendship['affinity'])
    bonus_text = bonus > 0 ? "\n**Collab Bonus:** +#{(bonus * 100).to_i}% coins when you collab together!" : ""

    # Progress to next tier
    current_min = FRIENDSHIP_TIERS.select { |min, _| friendship['affinity'] >= min }.max_by { |min, _| min }&.first || 0
    next_tier = FRIENDSHIP_TIERS.select { |min, _| min > current_min }.min_by { |min, _| min }
    progress_text = next_tier ? "\n**Next Tier:** #{next_tier[1][:name]} at #{next_tier[0]} affinity (#{friendship['affinity']}/#{next_tier[0]})" : "\n\u{1F31F} **MAX TIER!**"

    send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['heart']} Friendship" },
      { type: 14, spacing: 1 },
      { type: 10, content: "**#{event.user.name}** & **#{target.name}**\n\n\u{1F495} **Tier:** #{tier}\n**Affinity:** #{friendship['affinity']} points#{bonus_text}#{progress_text}#{mom_remark(uid, 'social')}" }
    ]}])
  else
    # View friends list
    top = DB.get_top_friends(uid, 10)
    if top.empty?
      return send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['heart']} Friends" },
        { type: 14, spacing: 1 },
        { type: 10, content: "No friendships yet! Interact with other players \u2014 hug, trade, collab, gift \u2014 to build affinity.\n\nUse `#{PREFIX}friends @user` to check a specific friendship." }
      ]}])
    end

    list = top.map { |f|
      tier = friendship_tier(f['affinity'].to_i)
      "<@#{f['friend_id']}> \u2014 **#{tier}** (#{f['affinity']} \u{1F495})"
    }.join("\n")

    send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['heart']} Your Friends" },
      { type: 14, spacing: 1 },
      { type: 10, content: "#{list}\n\nAffinity grows from collabs, trades, gifts, and social interactions!#{mom_remark(uid, 'social')}" }
    ]}])
  end
end

$bot.command(:friends, aliases: [:friendship],
  description: 'View your friendships and affinity levels',
  category: 'Fun'
) do |event, *args|
  target = event.message.mentions.first rescue nil
  execute_friends(event, target)
  nil
end

$bot.application_command(:friends) do |event|
  target_id = event.options['user']
  target = target_id ? event.bot.user(target_id.to_i) : nil
  execute_friends(event, target)
end
