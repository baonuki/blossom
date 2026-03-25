# ==========================================
# COMMAND: stream
# DESCRIPTION: Go live on your virtual stage to earn coins and engagement.
# CATEGORY: Economy
# ==========================================

# ------------------------------------------
# LOGIC: Stream Execution
# ------------------------------------------
def execute_stream(event)
  # 1. Initialization: Get user context and current premium status
  uid = event.user.id
  now = Time.now
  is_sub = is_premium?(event.bot, uid)
  last_used = DB.get_cooldown(uid, 'stream')

  # 2. Cooldown Scaling: Apply the 50% "Premium" reduction if applicable
  active_cd = is_sub ? (STREAM_COOLDOWN / 2) : STREAM_COOLDOWN

  # 3. Validation: Check if the user is still in "Post-Stream Recovery"
  if last_used && (now - last_used) < active_cd
    remaining = active_cd - (now - last_used)
    send_embed(event, 
      title: "#{EMOJIS['stream']} Stream Offline", 
      description: "You just finished streaming! Your voice needs a break #{EMOJIS['drink']}\nTry going live again in **#{format_time_delta(remaining)}**."
    )
  else
    # 4. Calculation: Roll for a random game and base reward
    reward = rand(STREAM_REWARD_RANGE)
    game = STREAM_GAMES.sample
    bonus_text = ""
    inv = DB.get_inventory(uid)
    
    # 5. Item Buffs: Check for 'Studio Mic' (+10% reward boost)
    if inv['mic'] && inv['mic'] > 0
      reward = (reward * 1.10).to_i
      bonus_text += "\n*(🎙️ Studio Mic Boost: +10%)*"
    end

    # 6. Premium Note: The 10% global boost is calculated inside award_coins
    bonus_text += "\n*(💎 Subscriber Bonus: +10%)*" if is_sub

    # 7. Database & Progression: Set cooldown and check for the 'first_stream' milestone
    # award_coins handles the final math and global premium multipliers.
    final_reward = award_coins(event.bot, uid, reward)
    DB.set_cooldown(uid, 'stream', now)
    check_achievement(event.channel, event.user.id, 'first_stream')

    # 8. UI: Send the success Embed with the final tally
    send_embed(event, 
      title: "#{EMOJIS['stream']} Stream Ended", 
      description: "You had a great stream playing **#{game}** and earned **#{final_reward}** #{EMOJIS['s_coin']}!#{bonus_text}\n" \
                   "New balance: **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}."
    )
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!stream)
# ------------------------------------------
bot.command(:stream, 
  description: 'Go live and earn some coins!', 
  category: 'Economy'
) do |event|
  execute_stream(event)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/stream)
# ------------------------------------------
bot.application_command(:stream) do |event|
  execute_stream(event)
end