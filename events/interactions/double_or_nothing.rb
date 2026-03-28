# ==========================================
# EVENT: Double or Nothing (Premium Arcade Perk)
# DESCRIPTION: Handles the DoN button on arcade wins.
# 50/50 to double your winnings or lose them all.
# ==========================================

$bot.button(custom_id: /^don_/) do |event|
  parts = event.custom_id.split('_')
  owner_uid = parts[1].to_i
  winnings = parts[2].to_i

  # Only the original player can press the button
  if event.user.id != owner_uid
    next event.respond(content: "#{EMOJI_STRINGS['x_']} Hands off, that's not your gamble.", ephemeral: true)
  end

  # Check they still have the coins at stake
  if DB.get_coins(owner_uid) < winnings
    next event.respond(content: "#{EMOJI_STRINGS['nervous']} You don't even have **#{winnings}** #{EMOJI_STRINGS['s_coin']} anymore... can't double what you already spent, chat.", ephemeral: true)
  end

  if rand(2).zero?
    # WIN — double the winnings
    DB.add_coins(owner_uid, winnings)

    event.update_message(
      content: '', flags: CV2_FLAG,
      components: [{ type: 17, accent_color: 0x00FF00, components: [
        { type: 10, content: "## 🎲 Double or Nothing — **DOUBLED!**" },
        { type: 14, spacing: 1 },
        { type: 10, content: "#{EMOJI_STRINGS['neonsparkle']} ACTUALLY CLUTCHED IT?! You doubled up and snagged another **#{winnings}** #{EMOJI_STRINGS['s_coin']}!\nNew Balance: **#{DB.get_coins(owner_uid)}** #{EMOJI_STRINGS['s_coin']}" }
      ]}]
    )
  else
    # LOSS — lose the winnings
    DB.add_coins(owner_uid, -winnings)

    event.update_message(
      content: '', flags: CV2_FLAG,
      components: [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## 🎲 Double or Nothing — **NOTHING!**" },
        { type: 14, spacing: 1 },
        { type: 10, content: "LOL GREEDY. You got absolutely NOTHING. **#{winnings}** #{EMOJI_STRINGS['s_coin']} evaporated. Should've walked away, chat.\nNew Balance: **#{DB.get_coins(owner_uid)}** #{EMOJI_STRINGS['s_coin']}" }
      ]}]
    )
  end
end
