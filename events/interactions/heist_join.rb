# ==========================================
# INTERACTION: Heist Join Button
# DESCRIPTION: Handles players joining an active heist.
# ==========================================

$bot.button(custom_id: /^heist_join_\d+$/) do |event|
  sid = event.custom_id.split('_').last.to_i
  uid = event.user.id

  heist = ACTIVE_HEISTS[sid]
  unless heist
    event.respond(content: "This heist has already ended!", ephemeral: true)
    next
  end

  # Check if join window is still open
  if (Time.now - heist[:started_at]) > HEIST_JOIN_WINDOW
    event.respond(content: "Too late! The join window has closed.", ephemeral: true)
    next
  end

  # Check if already joined
  if heist[:participants].include?(uid)
    event.respond(content: "You're already in the crew! Sit tight.", ephemeral: true)
    next
  end

  heist[:participants] << uid
  player_count = heist[:participants].size

  event.respond(content: "\u{1F3AD} **#{event.user.name}** joined the heist! (**#{player_count}** crew member#{player_count == 1 ? '' : 's'})", ephemeral: false)
end
