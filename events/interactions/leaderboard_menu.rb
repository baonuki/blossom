# ==========================================
# EVENT: Leaderboard Navigation
# DESCRIPTION: Listens for category selections on the /leaderboard command.
#
# Defensive design: every Discord API call here is wrapped in a rescue so
# transient interaction state errors (most commonly the 40060 "Interaction
# has already been acknowledged" — which can show up if Discord double-
# delivers an interaction, if the bot is temporarily double-running, or if
# the user fires multiple clicks in quick succession) do NOT bubble up as
# unhandled exceptions. The user-facing UX still works because edit_response
# uses the webhook channel and remains valid even when the initial ack was
# already taken by a prior call.
# ==========================================

$bot.select_menu(custom_id: /^lb_menu_/) do |event|
  owner_id = event.custom_id.split('_').last.to_i

  if event.user.id != owner_id
    begin
      event.respond(content: "🌸 *This isn't your menu! Run your own `/leaderboard` command to browse.*", ephemeral: true)
    rescue StandardError => e
      Discordrb::LOGGER.warn("[LB MENU] non-owner respond failed: #{e.class}: #{e.message}")
    end
    next
  end

  # Pause the 3-second timeout. If Discord says it's already acked, that's
  # fine — edit_response below will still work as a webhook follow-up.
  begin
    event.defer_update
  rescue StandardError => e
    Discordrb::LOGGER.debug("[LB MENU] defer_update skipped (interaction already handled): #{e.class}: #{e.message}")
  end

  selected_page = event.values.first

  begin
    new_embed = generate_leaderboard_page(event.bot, event.server, selected_page)
    new_view  = leaderboard_select_menu(owner_id, selected_page)
    event.edit_response(embeds: [new_embed], components: new_view)
  rescue StandardError => e
    Discordrb::LOGGER.error("[LB MENU] edit_response failed: #{e.class}: #{e.message}")
  end
end
