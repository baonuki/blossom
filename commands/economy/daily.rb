def execute_daily(event)
  uid = event.user.id
  now = Time.now
  is_sub = is_premium?(event.bot, uid)
  
  daily_info = DB.get_daily_info(uid)
  last_used = daily_info['at']
  current_streak = daily_info['streak']

  if last_used && (now - last_used) < DAILY_COOLDOWN
    remaining = DAILY_COOLDOWN - (now - last_used)
    return send_embed(event, title: "#{EMOJIS['coin']} Daily Reward", description: "You already claimed your daily #{EMOJIS['worktired']}\nTry again in **#{format_time_delta(remaining)}**.")
  end

  if last_used.nil? || (now - last_used) > (DAILY_COOLDOWN * 2)
    new_streak = 1
    streak_msg = "\n*(Streak reset! Claim within 48h to build it up!)*"
  else
    new_streak = current_streak + 1
    streak_msg = "\n🔥 **Streak:** #{new_streak} days!"
  end

  reward = DAILY_REWARD + (new_streak * 50) 
  if is_sub
    base_prisma = rand(1..3)
    
    streak_multiplier = 1 + (new_streak / 7)
    prisma_reward = base_prisma * streak_multiplier
    
    DB.add_prisma(uid, prisma_reward)
    
    bonus_text += "\n*(<:prisma:1486142162805723196> Subscriber Bonus: +10% Coins & +#{prisma_reward} Prisma!)*"
  end
  
  inv = DB.get_inventory(uid)
  if inv['neon sign'] && inv['neon sign'] > 0
    reward *= 2
    bonus_text += "\n*(✨ Neon Sign Boost: x2 Payout!)*"
  end

  bonus_text += "\n*(💎 Subscriber Bonus: +10%)*" if is_sub

  final_reward = award_coins(event.bot, uid, reward)
  DB.update_daily_claim(uid, new_streak, now)

  check_achievement(event.channel, uid, 'streak_7') if new_streak >= 7
  check_achievement(event.channel, uid, 'streak_30') if new_streak >= 30
  check_achievement(event.channel, uid, 'streak_69') if new_streak >= 69
  check_achievement(event.channel, uid, 'streak_100') if new_streak >= 100
  check_achievement(event.channel, uid, 'streak_365') if new_streak >= 365
  
  send_embed(event, title: "#{EMOJIS['coin']} Daily Reward", description: "You claimed **#{final_reward}** #{EMOJIS['s_coin']}!#{bonus_text}\nNew balance: **#{DB.get_coins(uid)}**.")
end

bot.command(:daily, description: 'Claim your daily coin reward', category: 'Economy') { |e| execute_daily(e); nil }
bot.application_command(:daily) { |e| execute_daily(e) }