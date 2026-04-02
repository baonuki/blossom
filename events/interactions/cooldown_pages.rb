# ==========================================
# EVENT: Cooldown Page Navigation
# DESCRIPTION: Handles prev/next buttons on the cooldown display.
# ==========================================

$bot.button(custom_id: /^cd_(prev|next)_\d+$/) do |event|
  match = event.custom_id.match(/^cd_(prev|next)_(\d+)$/)
  direction = match[1]
  uid = match[2].to_i

  # Only the owner can page through their cooldowns
  if event.user.id != uid
    event.respond(content: "#{EMOJI_STRINGS['x_']} *Those aren't your timers.*", ephemeral: true)
    next
  end

  current = COOLDOWN_PAGES[uid] || 0
  new_page = direction == 'next' ? current + 1 : current - 1
  new_page = new_page.clamp(0, 2)
  COOLDOWN_PAGES[uid] = new_page

  components = render_cooldown_page(event, uid, new_page)
  update_cv2(event, components)
end
