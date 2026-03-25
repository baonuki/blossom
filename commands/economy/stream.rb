def execute_stream(event)
  uid = event.user.id
  now = Time.now
  last_used = DB.get_cooldown(uid, 'stream')
  is_sub = is_premium?(event.bot, uid)

  active_cd = is_sub ? (STREAM_COOLDOWN / 2) : STREAM_COOLDOWN

  if last_used && (now - last_used) < active_cd
    remaining = active_cd - (now - last_used)
    send_embed(event, title: "#{EMOJIS['stream']} Stream Offline", description: "You just finished streaming! Your voice needs a break #{EMOJIS['drink']}\nTry going live again in **#{format_time_delta(remaining)}**.")
  else
    reward = rand(STREAM_REWARD_RANGE)
    game = STREAM_GAMES.sample
    bonus_text = ""
    inv = DB.get_inventory(uid)
    
    if inv['mic'] && inv['mic'] > 0
      reward = (reward * 1.10).to_i
      bonus_text += "\n*(🎙️ Studio Mic Boost: +10%)*"
    end

    bonus_text += "\n*(💎 Subscriber Bonus: +10%)*" if is_sub

    final_reward = award_coins(event.bot, uid, reward)
    DB.set_cooldown(uid, 'stream', now)
    check_achievement(event.channel, event.user.id, 'first_stream')
    send_embed(event, title: "#{EMOJIS['stream']} Stream Ended", description: "You had a great stream playing **#{game}** and earned **#{final_reward}** #{EMOJIS['s_coin']}!#{bonus_text}\nNew balance: **#{DB.get_coins(uid)}**.")
  end
end

bot.command(:stream, description: 'Go live and earn some coins!', category: 'Economy') { |e| execute_stream(e); nil }
bot.application_command(:stream) { |e| execute_stream(e) }