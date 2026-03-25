# ==========================================
# EVENT: Shop Navigation Hub
# DESCRIPTION: Listens for button clicks to navigate between
# the Home, Catalog, and Black Market pages of the shop.
# ==========================================

# Handler for flipping pages in the Shop Catalog
bot.button(custom_id: /^shop_catalog_(\d+)_(\d+)$/) do |event|
  match_data = event.custom_id.match(/^shop_catalog_(\d+)_(\d+)$/)
  uid  = match_data[1].to_i
  page = match_data[2].to_i
  
  # Security Check: Ensure users can't click buttons on someone else's menu
  if event.user.id != uid
    event.respond(content: "🌸 *You cannot use someone else's shop menu! Type `/shop` to open your own.*", ephemeral: true)
    next
  end

  # Generate the requested catalog page and update the message
  new_embed, new_view = build_shop_catalog(uid, page)
  event.update_message(content: nil, embeds: [new_embed], components: new_view)
end

# Handler for returning to the main Shop Home screen
bot.button(custom_id: /^shop_home_(\d+)$/) do |event|
  uid = event.custom_id.match(/^shop_home_(\d+)$/)[1].to_i
  
  if event.user.id != uid
    event.respond(content: "🌸 *You cannot use someone else's shop menu!*", ephemeral: true)
    next
  end

  new_embed, new_view = build_shop_home(uid)
  event.update_message(content: nil, embeds: [new_embed], components: new_view)
end

# Handler for opening the secretive Black Market page
bot.button(custom_id: /^shop_blackmarket_(\d+)$/) do |event|
  begin
    uid = event.custom_id.match(/^shop_blackmarket_(\d+)$/)[1].to_i
    
    if event.user.id != uid
      event.respond(content: "🌸 *You cannot use someone else's shop menu!*", ephemeral: true)
      next
    end

    new_embed, new_view = build_blackmarket_page(uid)
    event.update_message(content: nil, embeds: [new_embed], components: new_view)
  rescue => e
    # Catch any missing item data errors if the black market config breaks
    puts "!!! [ERROR] in Black Market Button !!!"
    puts e.message
  end
end