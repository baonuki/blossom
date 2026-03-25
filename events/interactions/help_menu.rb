# ==========================================
# EVENT: Help Menu Hub
# DESCRIPTION: Listens for category selections on the /help dropdown.
# ==========================================

bot.select_menu(custom_id: /^help_menu_/) do |event|
  owner_id = event.custom_id.split('_').last

  if event.user.id.to_s != owner_id
    event.respond(content: "🌸 *This isn't your menu! Run your own `#{PREFIX}help` command to explore.*", ephemeral: true)
    next
  end

  selected_category = event.values.first
  new_embed = generate_category_embed(event.bot, event.user, selected_category)
  view = help_select_menu(owner_id) 

  event.update_message(embeds: [new_embed], components: view)
end