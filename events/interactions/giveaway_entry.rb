# ==========================================
# EVENT: Giveaway Entry
# DESCRIPTION: Listens for users clicking the "Join Giveaway" button
# and safely adds them to the database pool, preventing duplicates.
# ==========================================

$bot.button(custom_id: /^gw_/) do |event|
  # The custom_id acts as the unique identifier for the specific giveaway
  gw_id = event.custom_id
  
  # Verification: Check if the giveaway is still actively running in the database
  active = DB.get_active_giveaways.any? { |gw| gw['id'] == gw_id }
  unless active
    event.respond(content: "#{EMOJI_STRINGS['error']} *That giveaway is over! You missed it, bestie.*", ephemeral: true)
    next
  end

  # Attempt to add the user to the entrant pool 
  # (The database method should return 'false' if they violate a UNIQUE constraint)
  success = DB.add_giveaway_entrant(gw_id, event.user.id)
  
  # Provide private feedback based on the database result
  if success
    event.respond(content: "#{EMOJI_STRINGS['surprise']} *You're in! Good luck, you'll need it~*", ephemeral: true)
  else
    event.respond(content: "🍀 *Chill, you already entered! Spamming won't help~*", ephemeral: true)
  end
end