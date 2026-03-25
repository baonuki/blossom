# ==========================================
# EVENT: Collection Pagination & Sorting
# DESCRIPTION: Listens for dropdown selections (rarity filters) 
# and button clicks (page navigation) on the /collection menu.
# ==========================================

# Handler for the Dropdown Menu (Sorting by Rarity)
bot.select_menu(custom_id: /^colsel_/) do |event|
  # Split the custom ID. Expected format: colsel_123456789
  _, owner_id = event.custom_id.split('_')

  if event.user.id.to_s != owner_id
    event.respond(content: "🌸 *This isn't your collection!*", ephemeral: true)
    next
  end

  selected_rarity = event.values.first 
  col = DB.get_collection(event.user.id)

  # Pass the new rarity filter back to the builder, resetting to Page 1
  build_collection_page(event, event.user, col, selected_rarity, 1, is_edit: true)
end

# Handler for the Next/Prev Buttons (Page Flipping)
bot.button(custom_id: /^colbtn_/) do |event|
  # Split the custom ID. Expected format: colbtn_123456789_2_rare
  _, owner_id, page_str, rarity = event.custom_id.split('_', 4)

  if event.user.id.to_s != owner_id
    event.respond(content: "🌸 *This isn't your collection!*", ephemeral: true)
    next
  end

  target_page = page_str.to_i
  col = DB.get_collection(event.user.id)

  # Pass the current rarity filter and the newly requested page to the builder
  build_collection_page(event, event.user, col, rarity, target_page, is_edit: true)
end