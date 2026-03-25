def execute_roulette(event, amount, bet)
  uid = event.user.id
  bet = bet.to_s.downcase.strip

  if amount <= 0 || DB.get_coins(uid) < amount
    return send_embed(event, title: "#{EMOJIS['error']} Invalid Bet", description: "You don't have enough coins or entered an invalid amount!")
  end

  red_numbers = [1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36]
  valid_bets = ['red', 'black', 'even', 'odd'] + (0..36).map(&:to_s)

  unless valid_bets.include?(bet)
    return send_embed(event, title: "#{EMOJIS['error']} Invalid Bet Type", description: "You can only bet on `red`, `black`, `even`, `odd`, or a number from `0` to `36`.")
  end

  DB.add_coins(uid, -amount)
  spin = rand(0..36)
  
  spin_color = 'green'
  if red_numbers.include?(spin)
    spin_color = 'red'
  elsif spin != 0
    spin_color = 'black'
  end

  is_even = (spin != 0 && spin.even?) ? 'even' : nil
  is_odd = (spin != 0 && spin.odd?) ? 'odd' : nil

  win = false
  payout = 0

  if bet == spin.to_s
    win = true; payout = amount * 36
  elsif bet == spin_color || bet == is_even || bet == is_odd
    win = true; payout = amount * 2 
  end

  color_emoji = spin_color == 'red' ? '🔴' : (spin_color == 'black' ? '⚫' : '🟢')

  if win
    DB.add_coins(uid, payout)
    send_embed(event, title: "🎰 Roulette Spin", description: "The dealer spins the wheel... It lands on **#{color_emoji} #{spin}**!\n\nYou bet on **#{bet}** and won **#{payout}** #{EMOJIS['s_coin']}!\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}")
  else
    send_embed(event, title: "🎰 Roulette Spin", description: "The dealer spins the wheel... It lands on **#{color_emoji} #{spin}**.\n\nYou bet on **#{bet}** and lost **#{amount}** #{EMOJIS['s_coin']}.\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}")
  end
end

bot.command(:roulette, description: 'Bet on the roulette wheel!', category: 'Arcade') do |event, amount_str, bet_str|
  if amount_str.nil? || bet_str.nil?
    send_embed(event, title: "#{EMOJIS['confused']} Missing Arguments", description: "Place your bets!\n\n**Usage:** `#{PREFIX}roulette <amount> <bet>`\n**Valid Bets:** `red`, `black`, `even`, `odd`, or a number `0-36`.")
    next
  end
  execute_roulette(event, amount_str.to_i, bet_str)
  nil
end

bot.application_command(:roulette) do |event|
  execute_roulette(event, event.options['amount'], event.options['bet'])
end