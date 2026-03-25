# ==========================================
# COMMAND: post
# DESCRIPTION: Upload a social media post to earn quick engagement coins.
# CATEGORY: Economy
# ==========================================

# ------------------------------------------
# LOGIC: Post Execution
# ------------------------------------------
def execute_post(event)
  # 1. Initialization: Get user context and check premium status
  uid = event.user.id
  now = Time.now
  is_sub = is_premium?(event.bot, uid)
  last_used = DB.get_cooldown(uid, 'post')

  # 2. Cooldown Scaling: Subscribers get a 50% cooldown reduction
  active_cd = is_sub ? (POST_COOLDOWN / 2) : POST_COOLDOWN

  # 3. Validation: Check if the user is currently on a social media break
  if last_used && (now - last_used) < active_cd
    remaining = active_cd - (now - last_used)
    send_embed(event, 
      title: "#{EMOJIS['error']} Social Media Break", 
      description: "You're posting too fast! Don't get shadowbanned #{EMOJIS['nervous']}\nTry posting again in **#{format_time_delta(remaining)}**."
    )
  else
    # 4. Calculation: Roll for base reward and select a random platform
    reward = rand(POST_REWARD_RANGE)
    platform = POST_PLATFORMS.sample
    bonus_text = ""
    inv = DB.get_inventory(uid)

    # 5. Item Buffs: Check for 'Headset' (+25% reward boost)
    if inv['headset'] && inv['headset'] > 0
      reward = (reward * 1.25).to_i
      bonus_text += "\n*(🎧 Headset Boost: +25%)*"
    end

    # 6. Premium Bonus: Add a note (the 10% math is handled by award_coins)
    bonus_text += "\n*(💎 Subscriber Bonus: +10%)*" if is_sub

    # 7. Database: Record the cooldown and grant the coins
    # award_coins automatically applies the global premium multiplier
    final_reward = award_coins(event.bot, uid, reward)
    DB.set_cooldown(uid, 'post', now)

    # 8. UI: Construct the success Embed with the new balance
    send_embed(event, 
      title: "#{EMOJIS['like']} New Post Uploaded!", 
      description: "Your latest post on **#{platform}** got a lot of engagement! You earned **#{final_reward}** #{EMOJIS['s_coin']}.#{bonus_text}\n" \
                   "New balance: **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}."
    )
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!post)
# ------------------------------------------
bot.command(:post, 
  description: 'Post on social media for some quick coins!', 
  category: 'Economy'
) do |event|
  execute_post(event)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/post)
# ------------------------------------------
bot.application_command(:post) do |event|
  execute_post(event)
end