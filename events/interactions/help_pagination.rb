# ==========================================
# EVENT: Help Menu Pagination
# DESCRIPTION: Listens for button clicks on the /help command menu
# and updates the original message with the requested page.
# NOTE: This handler is currently inactive as no buttons with
# the 'helpnav_' prefix are generated. It exists as a placeholder
# for future paginated help if needed. The help system currently
# uses a dropdown menu (help_menu.rb) instead of buttons.
# ==========================================

$bot.button(custom_id: /^helpnav_(\d+)_(\d+)$/) do |event|
  match_data = event.custom_id.match(/^helpnav_(\d+)_(\d+)$/)
  target_uid  = match_data[1].to_i
  target_page = match_data[2].to_i

  if event.user.id != target_uid
    event.respond(content: "🌸 *You can only flip the pages of your own help menu! Use `/help` to open yours.*", ephemeral: true)
    next
  end

  # Fallback: Show the Home page via the existing category embed system
  new_embed = generate_category_embed(event.bot, event.user, 'Home')
  new_view = help_select_menu(event.user.id)

  event.update_message(content: nil, embeds: [new_embed], components: new_view)
end
