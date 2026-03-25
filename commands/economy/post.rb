def execute_post(event)
  uid = event.user.id
  now = Time.now
  last_used = DB.get_cooldown(uid, 'post')
  is_sub = is_premium?(event.bot, uid)

  active_cd = is_sub ? (POST_COOLDOWN / 2) : POST_COOLDOWN

  if last_used && (now - last_used) < active_cd
    remaining = active_cd - (now - last_used)
    send_embed(event, title: "#{EMOJIS['error']} Social Media Break", description: "You're posting too fast! Don't get shadowbanned #{EMOJIS['nervous']}\nTry posting again in **#{format_time_delta(remaining)}**.")
  else
    reward = rand(POST_REWARD_RANGE)
    platform = POST_PLATFORMS.sample
    bonus_text = ""
    inv = DB.get_inventory(uid)

    if inv['headset'] && inv['headset'] > 0
      reward = (reward * 1.25).to_i
      bonus_text += "\n*(🎧 Headset Boost: +25%)*"
    end

    bonus_text += "\n*(💎 Subscriber Bonus: +10%)*" if is_sub

    final_reward = award_coins(event.bot, uid, reward)
    DB.set_cooldown(uid, 'post', now)
    send_embed(event, title: "#{EMOJIS['like']} New Post Uploaded!", description: "Your latest post on **#{platform}** got a lot of engagement! You earned **#{final_reward}** #{EMOJIS['s_coin']}.#{bonus_text}\nNew balance: **#{DB.get_coins(uid)}**.")
  end
end

bot.command(:post, description: 'Post on social media for some quick coins!', category: 'Economy') { |e| execute_post(e); nil }
bot.application_command(:post) { |e| execute_post(e) }