def execute_work(event)
  uid = event.user.id
  now = Time.now
  last_used = DB.get_cooldown(uid, 'work')
  is_sub = is_premium?(event.bot, uid)
  
  active_cd = is_sub ? (WORK_COOLDOWN / 2) : WORK_COOLDOWN

  if last_used && (now - last_used) < active_cd
    remaining = active_cd - (now - last_used)
    send_embed(event, title: "#{EMOJIS['work']} Work", description: "You are tired #{EMOJIS['worktired']}\nTry working again in **#{format_time_delta(remaining)}**.")
  else
    amount = rand(WORK_REWARD_RANGE)
    bonus_text = ""
    inv = DB.get_inventory(uid)

    if inv['keyboard'] && inv['keyboard'] > 0
      amount = (amount * 1.25).to_i
      bonus_text += "\n*(⌨️ Keyboard Boost: +25%)*"
    end

    bonus_text += "\n*(💎 Subscriber Bonus: +10%)*" if is_sub

    final_amount = award_coins(event.bot, uid, amount)
    DB.set_cooldown(uid, 'work', now)
    send_embed(event, title: "#{EMOJIS['work']} Work", description: "You worked hard and earned **#{final_amount}** #{EMOJIS['s_coin']}!#{bonus_text}\nNew balance: **#{DB.get_coins(uid)}**.")
  end
end

bot.command(:work, description: 'Work for some coins', category: 'Economy') { |e| execute_work(e); nil }
bot.application_command(:work) { |e| execute_work(e) }