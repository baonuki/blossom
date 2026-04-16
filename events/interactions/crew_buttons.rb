# ==========================================
# INTERACTION: Crew Invite Accept/Decline
# DESCRIPTION: Handles crew invitation button clicks.
# ==========================================

$bot.button(custom_id: /^crew_accept_\d+_\d+$/) do |event|
  parts = event.custom_id.gsub('crew_accept_', '').split('_')
  crew_id = parts[0].to_i
  target_uid = parts[1].to_i

  if event.user.id != target_uid
    event.respond(content: "This invite isn't for you!", ephemeral: true)
    next
  end

  invite_key = "#{crew_id}_#{target_uid}"
  invite = ACTIVE_CREW_INVITES.delete(invite_key)

  unless invite && Time.now < invite[:expires_at]
    update_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Invite Expired" },
      { type: 14, spacing: 1 },
      { type: 10, content: "This invite has expired." }
    ]}])
    next
  end

  if DB.get_user_crew(target_uid)
    update_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Already In a Crew" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You're already in a crew! Leave first." }
    ]}])
    next
  end

  if DB.get_crew_count(crew_id) >= CREW_MAX_MEMBERS
    update_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Crew Full" },
      { type: 14, spacing: 1 },
      { type: 10, content: "The crew is at max capacity." }
    ]}])
    next
  end

  DB.add_crew_member(crew_id, target_uid)
  crew = DB.get_crew(crew_id)

  update_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: [
    { type: 10, content: "## \u{1F389} Welcome to the Crew!" },
    { type: 14, spacing: 1 },
    { type: 10, content: "#{event.user.mention} joined **#{crew['name']}** [#{crew['tag']}]!\n\nYou now get a **+#{(CREW_COIN_BONUS * 100).to_i}% coin bonus** on all earnings. \u{1F338}" }
  ]}])
end

$bot.button(custom_id: /^crew_decline_\d+_\d+$/) do |event|
  parts = event.custom_id.gsub('crew_decline_', '').split('_')
  target_uid = parts[1].to_i

  if event.user.id != target_uid
    event.respond(content: "This invite isn't for you!", ephemeral: true)
    next
  end

  invite_key = "#{parts[0]}_#{target_uid}"
  ACTIVE_CREW_INVITES.delete(invite_key)

  update_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
    { type: 10, content: "## \u{1F465} Invite Declined" },
    { type: 14, spacing: 1 },
    { type: 10, content: "#{event.user.mention} declined the crew invite. Solo life it is." }
  ]}])
end
