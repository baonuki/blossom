# ==========================================
# EVENT: Leaderboard Navigation
# DESCRIPTION: Listens for category selections on the /leaderboard
# command and handles the 3-second Discord deferment.
# ==========================================

bot.select_menu(custom_id: /^lb_menu_/) do |event|
  owner_id = event.custom_id.split('_').last.to_i

  if event.user.id != owner_id
    event.respond(content: "🌸 *This isn't your menu! Run your own `/leaderboard` command to browse.*", ephemeral: true)
    next
  end

  # Instantly pause the 3-second timeout so the DB has time to load!
  event.defer_update

  selected_page = event.values.first
  
  new_embed = generate_leaderboard_page(event.bot, event.server, selected_page)
  new_view = leaderboard_select_menu(owner_id, selected_page)

  # Push the edit through! (We use edit_response instead of update_message when deferred)
  event.edit_response(embeds: [new_embed], components: new_view)
end