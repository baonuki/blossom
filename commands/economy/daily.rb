# ==========================================
# COMMAND: daily
# DESCRIPTION: Claim daily rewards, manage streaks, and grant bonuses.
# CATEGORY: Economy
# ==========================================

# ------------------------------------------
# LOGIC: Daily Reward Execution
# ------------------------------------------
def execute_daily(event)
  # 1. Initialization: Gather user context and premium status
  uid = event.user.id
  now = Time.now
  is_sub = is_premium?(event.bot, uid)
  bonus_text = "" # Container for extra reward descriptions
  
  # 2. Data Retrieval: Fetch current streak and last-used timestamp
  daily_info = DB.get_daily_info(uid)
  last_used = daily_info['at'] ? Time.parse(daily_info['at'].to_s) : nil
  current_streak = daily_info['streak'].to_i

  # 3. Validation: Cooldown Check (24-hour gate)
  if last_used && (now - last_used) < DAILY_COOLDOWN
    remaining = DAILY_COOLDOWN - (now - last_used)
    return send_embed(event, 
      title: "#{EMOJIS['coin']} Daily Reward", 
      description: "You already claimed your daily revenue! #{EMOJIS['worktired']}\nTry again in **#{format_time_delta(remaining)}**."
    )
  end

  # 4. Logic: Streak Calculation (Reset if > 48 hours since last claim)
  if last_used.nil? || (now - last_used) > (DAILY_COOLDOWN * 2)
    new_streak = 1
    streak_msg = "\n*(Streak reset! Claim within 48h to build it up!)*"
  else
    new_streak = current_streak + 1
    streak_msg = "\n🔥 **Streak:** #{new_streak} days!"
  end

  # 5. Calculation: Base Reward + Streak Bonus (+50 per day)
  reward = DAILY_REWARD + (new_streak * 50) 
  
  # 6. Logic: Premium & Prisma Rewards
  if is_sub
    base_prisma = rand(1..3)
    # Scaled Multiplier: +1x Prisma for every 7 days of streak
    streak_multiplier = 1 + (new_streak / 7)
    prisma_reward = base_prisma * streak_multiplier
    
    DB.add_prisma(uid, prisma_reward)
    bonus_text += "\n*(<:prisma:1486142162805723196> Subscriber Bonus: +10% Coins & +#{prisma_reward} Prisma!)*"
  end
  
  # 7. Logic: Inventory Boosts (Check for active Neon Sign)
  inv = DB.get_inventory(uid)
  if inv['neon sign'] && inv['neon sign'] > 0
    reward *= 2
    bonus_text += "\n*(✨ Neon Sign Boost: x2 Payout!)*"
  end

  # 8. Database: Final Coin Granting & Streak Persistence
  # award_coins handles the global +10% multiplier for premium users
  final_reward = award_coins(event.bot, uid, reward)
  DB.update_daily_claim(uid, new_streak, now)

  # 9. Progression: Achievement Milestone Checks
  check_achievement(event.channel, uid, 'streak_7')   if new_streak == 7
  check_achievement(event.channel, uid, 'streak_30')  if new_streak == 30
  check_achievement(event.channel, uid, 'streak_69')  if new_streak == 69
  check_achievement(event.channel, uid, 'streak_100') if new_streak == 100
  check_achievement(event.channel, uid, 'streak_365') if new_streak == 365
  
  # 10. UI: Send Final Confirmation Embed
  send_embed(
    event, 
    title: "#{EMOJIS['coin']} Daily Reward", 
    description: "You claimed **#{final_reward}** #{EMOJIS['s_coin']}!#{streak_msg}#{bonus_text}\n\n" \
                 "New balance: **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}."
  )
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!daily)
# ------------------------------------------
bot.command(:daily, 
  description: 'Claim your daily coin reward', 
  category: 'Economy'
) do |event|
  execute_daily(event)
  nil # Prevent double-response
end

# ------------------------------------------
# TRIGGER: Slash Command (/daily)
# ------------------------------------------
bot.application_command(:daily) do |event|
  execute_daily(event)
end