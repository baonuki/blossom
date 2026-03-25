# ==========================================
# EVENT: Help Menu Pagination
# DESCRIPTION: Listens for button clicks on the /help command menu
# and updates the original message with the requested page.
# ==========================================

bot.button(custom_id: /^helpnav_(\d+)_(\d+)$/) do |event|
  # Extract the owner's user ID and the requested page number from the button's custom_id
  match_data = event.custom_id.match(/^helpnav_(\d+)_(\d+)$/)
  target_uid  = match_data[1].to_i
  target_page = match_data[2].to_i
  
  # Security Check: Ensure only the person who ran the command can flip the pages
  if event.user.id != target_uid
    event.respond(content: "🌸 *You can only flip the pages of your own help menu! Use `/help` to open yours.*", ephemeral: true)
    next
  end

  # Generate the new embed and view elements for the requested page
  new_embed, total_pages, current_page = generate_help_page(event.bot, event.user, target_page)
  new_view = help_view(target_uid, current_page, total_pages)
  
  # Seamlessly push the edit through to the existing message
  event.update_message(content: nil, embeds: [new_embed], components: new_view)
end