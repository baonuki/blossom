def execute_slots(event, amount)
  uid = event.user.id

  if amount <= 0 || DB.get_coins(uid) < amount
    return send_embed(event, title: "#{EMOJIS['error']} Invalid Bet", description: "You don't have enough coins or entered an invalid amount!\nYou currently have **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}.")
  end

  DB.add_coins(uid, -amount)
  check_achievement(event.channel, event.user.id, 'slots_spin')

  slot_icons = ['🍒', '🍋', '🔔', '💎', '7️⃣']
  spin = [slot_icons.sample, slot_icons.sample, slot_icons.sample]

  if spin.uniq.size == 1
    winnings = amount * 5
    DB.add_coins(uid, winnings)
    send_embed(event, title: "🎰 Neon Slots", description: "[ #{spin.join(' | ')} ]\n\n**JACKPOT!** #{EMOJIS['sparkle']}\nYou won **#{winnings}** #{EMOJIS['s_coin']}!\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}")
  elsif spin.uniq.size == 2
    winnings = amount * 2
    DB.add_coins(uid, winnings)
    send_embed(event, title: "🎰 Neon Slots", description: "[ #{spin.join(' | ')} ]\n\nNice! You matched two and won **#{winnings}** #{EMOJIS['s_coin']}!\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}")
  else
    send_embed(event, title: "🎰 Neon Slots", description: "[ #{spin.join(' | ')} ]\n\nYou lost your bet... Better luck next spin. #{EMOJIS['worktired']}\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}")
  end
end

bot.command(:slots, description: 'Spin the neon slots!', category: 'Arcade') do |event, amount_str|
  if amount_str.nil?
    send_embed(event, title: "#{EMOJIS['confused']} Missing Arguments", description: "You need to drop some coins into the machine first!\n\n**Usage:** `#{PREFIX}slots <amount>`")
    next
  end
  execute_slots(event, amount_str.to_i)
  nil
end

bot.application_command(:slots) do |event|
  execute_slots(event, event.options['amount'])
end