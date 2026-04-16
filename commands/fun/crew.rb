# ==========================================
# COMMAND: crew
# DESCRIPTION: Global crew system — create, manage, and compete.
# CATEGORY: Fun
# ==========================================

def execute_crew(event, action = nil, *args)
  uid = event.user.id

  case action&.downcase
  when nil, 'info'
    # Show crew info
    crew = DB.get_user_crew(uid)
    unless crew
      return send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
        { type: 10, content: "## \u{1F465} Crews" },
        { type: 14, spacing: 1 },
        { type: 10, content: "You're not in a crew! Create one or get invited.\n\n`#{PREFIX}crew create <name> <tag>` \u2014 Create a crew (#{CREW_CREATE_COST} coins)\n`#{PREFIX}crew leaderboard` \u2014 View top crews" }
      ]}])
    end

    members = DB.get_crew_members(crew['id'])
    member_list = members.map { |m|
      role_icon = case m['role']
                  when 'leader' then "\u{1F451}"
                  when 'officer' then "\u2B50"
                  else "\u{1F465}"
                  end
      "#{role_icon} <@#{m['user_id']}>"
    }.join("\n")

    xp_needed = crew['crew_level'] * CREW_XP_PER_LEVEL
    xp_bar_pct = ((crew['crew_xp'].to_f % CREW_XP_PER_LEVEL) / CREW_XP_PER_LEVEL * 100).round

    send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
      { type: 10, content: "## \u{1F465} #{crew['name']} [#{crew['tag']}]" },
      { type: 14, spacing: 1 },
      { type: 10, content: "**Level:** #{crew['crew_level']} | **XP:** #{crew['crew_xp']} | **Members:** #{members.size}/#{CREW_MAX_MEMBERS}\n**Perk:** +#{(CREW_COIN_BONUS * 100).to_i}% coins for all members\n\n#{member_list}#{mom_remark(uid, 'general')}" }
    ]}])

  when 'create'
    name = args[0]
    tag = args[1]

    if DB.get_user_crew(uid)
      return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} Already In a Crew" },
        { type: 14, spacing: 1 },
        { type: 10, content: "Leave your current crew first with `#{PREFIX}crew leave`." }
      ]}])
    end

    unless name && tag && name.length >= 3 && name.length <= 30 && tag.length >= 2 && tag.length <= 5
      return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['confused']} Crew Creation" },
        { type: 14, spacing: 1 },
        { type: 10, content: "Usage: `#{PREFIX}crew create <name> <tag>`\n**Name:** 3-30 characters\n**Tag:** 2-5 characters (displayed as [TAG])\n**Cost:** #{CREW_CREATE_COST} coins" }
      ]}])
    end

    coins = DB.get_coins(uid)
    if coins < CREW_CREATE_COST
      return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} Not Enough Coins" },
        { type: 14, spacing: 1 },
        { type: 10, content: "Creating a crew costs **#{CREW_CREATE_COST}** #{EMOJI_STRINGS['s_coin']}. You have **#{coins}**." }
      ]}])
    end

    begin
      DB.add_coins(uid, -CREW_CREATE_COST)
      crew_id = DB.create_crew(name, tag, uid)
      send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: [
        { type: 10, content: "## \u{1F389} Crew Created!" },
        { type: 14, spacing: 1 },
        { type: 10, content: "**#{name}** [#{tag.upcase}] is now live!\n\nYou're the leader. Invite members with `#{PREFIX}crew invite @user`.\nAll members get a **+#{(CREW_COIN_BONUS * 100).to_i}% coin bonus** on earnings!#{mom_remark(uid, 'general')}" }
      ]}])
    rescue PG::UniqueViolation
      DB.add_coins(uid, CREW_CREATE_COST) # Refund
      send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} Name/Tag Taken" },
        { type: 14, spacing: 1 },
        { type: 10, content: "That crew name or tag is already taken. Try something different!" }
      ]}])
    end

  when 'invite'
    crew = DB.get_user_crew(uid)
    unless crew && %w[leader officer].include?(crew['role'])
      return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} Permission Denied" },
        { type: 14, spacing: 1 },
        { type: 10, content: "Only crew leaders and officers can invite members." }
      ]}])
    end

    if DB.get_crew_count(crew['id']) >= CREW_MAX_MEMBERS
      return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} Crew Full" },
        { type: 14, spacing: 1 },
        { type: 10, content: "Your crew is at max capacity (#{CREW_MAX_MEMBERS} members)." }
      ]}])
    end

    target = event.message.mentions.first rescue nil
    target ||= event.bot.user(args[0].to_i) rescue nil if args[0]
    unless target
      return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['confused']} Invite Who?" },
        { type: 14, spacing: 1 },
        { type: 10, content: "Mention a user to invite: `#{PREFIX}crew invite @user`" }
      ]}])
    end

    if DB.get_user_crew(target.id)
      return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} Already In a Crew" },
        { type: 14, spacing: 1 },
        { type: 10, content: "That player is already in a crew." }
      ]}])
    end

    invite_key = "#{crew['id']}_#{target.id}"
    ACTIVE_CREW_INVITES[invite_key] = { crew_id: crew['id'], inviter_id: uid, expires_at: Time.now + 120 }

    send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
      { type: 10, content: "## \u{1F465} Crew Invite" },
      { type: 14, spacing: 1 },
      { type: 10, content: "#{target.mention}, you've been invited to join **#{crew['name']}** [#{crew['tag']}]!\n\nThis invite expires in **2 minutes**." },
      { type: 14, spacing: 1 },
      { type: 1, components: [
        { type: 2, style: 3, label: "Accept", custom_id: "crew_accept_#{invite_key}" },
        { type: 2, style: 4, label: "Decline", custom_id: "crew_decline_#{invite_key}" }
      ]}
    ]}])

  when 'leave'
    crew = DB.get_user_crew(uid)
    unless crew
      return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} No Crew" },
        { type: 14, spacing: 1 },
        { type: 10, content: "You're not in a crew." }
      ]}])
    end

    if crew['role'] == 'leader'
      return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} You're the Leader" },
        { type: 14, spacing: 1 },
        { type: 10, content: "Leaders must transfer ownership first (`#{PREFIX}crew promote @user`) or disband (`#{PREFIX}crew disband`)." }
      ]}])
    end

    DB.remove_crew_member(crew['id'], uid)
    send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
      { type: 10, content: "## \u{1F465} Left Crew" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You left **#{crew['name']}**. Solo player vibes.#{mom_remark(uid, 'general')}" }
    ]}])

  when 'kick'
    crew = DB.get_user_crew(uid)
    unless crew && %w[leader officer].include?(crew['role'])
      return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} Permission Denied" },
        { type: 14, spacing: 1 },
        { type: 10, content: "Only leaders and officers can kick members." }
      ]}])
    end

    target = event.message.mentions.first rescue nil
    target ||= event.bot.user(args[0].to_i) rescue nil if args[0]
    return unless target

    target_crew = DB.get_user_crew(target.id)
    unless target_crew && target_crew['id'] == crew['id']
      return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} Not In Your Crew" },
        { type: 14, spacing: 1 },
        { type: 10, content: "That player isn't in your crew." }
      ]}])
    end

    DB.remove_crew_member(crew['id'], target.id)
    send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
      { type: 10, content: "## \u{1F465} Member Kicked" },
      { type: 14, spacing: 1 },
      { type: 10, content: "#{target.mention} has been removed from **#{crew['name']}**.#{mom_remark(uid, 'admin')}" }
    ]}])

  when 'promote'
    crew = DB.get_user_crew(uid)
    unless crew && crew['role'] == 'leader'
      return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} Leaders Only" },
        { type: 14, spacing: 1 },
        { type: 10, content: "Only the crew leader can promote members." }
      ]}])
    end

    target = event.message.mentions.first rescue nil
    return unless target

    target_crew = DB.get_user_crew(target.id)
    unless target_crew && target_crew['id'] == crew['id']
      return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} Not In Your Crew" },
        { type: 14, spacing: 1 },
        { type: 10, content: "That player isn't in your crew." }
      ]}])
    end

    # Transfer leadership
    DB.transfer_crew_leader(crew['id'], target.id)
    send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: [
      { type: 10, content: "## \u{1F451} Leadership Transferred" },
      { type: 14, spacing: 1 },
      { type: 10, content: "#{target.mention} is now the leader of **#{crew['name']}**!" }
    ]}])

  when 'disband'
    crew = DB.get_user_crew(uid)
    unless crew && crew['role'] == 'leader'
      return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} Leaders Only" },
        { type: 14, spacing: 1 },
        { type: 10, content: "Only the leader can disband the crew." }
      ]}])
    end

    DB.disband_crew(crew['id'])
    send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## \u{1F465} Crew Disbanded" },
      { type: 14, spacing: 1 },
      { type: 10, content: "**#{crew['name']}** has been disbanded. Everyone's a free agent now.#{mom_remark(uid, 'general')}" }
    ]}])

  when 'leaderboard', 'lb'
    top = DB.get_top_crews(10)
    if top.empty?
      return send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
        { type: 10, content: "## \u{1F465} Crew Leaderboard" },
        { type: 14, spacing: 1 },
        { type: 10, content: "No crews exist yet! Be the first with `#{PREFIX}crew create`." }
      ]}])
    end

    lb_text = top.each_with_index.map { |c, i|
      medal = case i when 0 then "\u{1F947}" when 1 then "\u{1F948}" when 2 then "\u{1F949}" else "**#{i+1}.**" end
      "#{medal} **#{c['name']}** [#{c['tag']}] \u2014 Level #{c['crew_level']} (#{c['crew_xp']} XP)"
    }.join("\n")

    send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
      { type: 10, content: "## \u{1F3C6} Crew Leaderboard" },
      { type: 14, spacing: 1 },
      { type: 10, content: lb_text }
    ]}])

  else
    send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
      { type: 10, content: "## \u{1F465} Crew Commands" },
      { type: 14, spacing: 1 },
      { type: 10, content: "`#{PREFIX}crew` \u2014 View your crew\n`#{PREFIX}crew create <name> <tag>` \u2014 Create a crew (#{CREW_CREATE_COST} coins)\n`#{PREFIX}crew invite @user` \u2014 Invite a player\n`#{PREFIX}crew leave` \u2014 Leave your crew\n`#{PREFIX}crew kick @user` \u2014 Remove a member\n`#{PREFIX}crew promote @user` \u2014 Transfer leadership\n`#{PREFIX}crew disband` \u2014 Delete your crew\n`#{PREFIX}crew leaderboard` \u2014 Top crews" }
    ]}])
  end
end

$bot.command(:crew,
  description: 'Create and manage your crew!',
  category: 'Fun'
) do |event, action, *args|
  execute_crew(event, action, *args)
  nil
end

$bot.application_command(:crew) do |event|
  execute_crew(event, event.options['action'])
end
