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
  used_fuel = false
  if last_used && (now - last_used) < active_cd
    inv_array = DB.get_inventory(uid)
    inv = inv_array.each_with_object({}) { |item, h| h[item['item_id']] = item['quantity'] }
    if inv['gamer fuel'] && inv['gamer fuel'] > 0
      DB.remove_inventory(uid, 'gamer fuel', 1)
      used_fuel = true
      check_achievement(event.channel, uid, 'use_fuel')
    else
      remaining = active_cd - (now - last_used)
      components = [
        {
          type: 17,
          accent_color: 0xFF0000,
          components: [
            { type: 10, content: "## #{EMOJI_STRINGS['x_']} Social Media Break" },
            { type: 14, spacing: 1 },
            { type: 10, content: "Slow down, you're gonna get shadowbanned lol.\nPost again in **#{format_time_delta(remaining)}**." }
          ]
        }
      ]
      return send_cv2(event, components)
    end
  end

  # 4. Calculation: Roll for base reward and select a random platform
  reward = rand(POST_REWARD_RANGE)
  platform = POST_PLATFORMS.sample
  bonus_text = ""
  inv_array = DB.get_inventory(uid)
  inv = inv_array.each_with_object({}) { |item, h| h[item['item_id']] = item['quantity'] }

  # 5. Item Buffs: Check for 'Headset' (+25% reward boost)
  if inv['headset'] && inv['headset'] > 0
    reward = (reward * 1.25).to_i
    bonus_text += "\n*(🎧 Headset Boost: +25%)*"
  end

  # 6. Premium Bonus: Add a note (the 10% math is handled by award_coins)
  bonus_text += "\n*(#{EMOJI_STRINGS['prisma']} Subscriber Bonus: +10%)*" if is_sub

  # 6b. Gamer Fuel notification
  bonus_text += "\n*(#{EMOJI_STRINGS['gamer_fuel']} Gamer Fuel burned! Cooldown bypassed.)*" if used_fuel

  # 7. Database: Record the cooldown and grant the coins
  # award_coins automatically applies the global premium multiplier
  final_reward = award_coins(event.bot, uid, reward)
  DB.set_cooldown(uid, 'post', now)

  # 8. Achievements & Tracking
  check_achievement(event.channel, uid, 'first_post')
  check_wealth_achievements(event.channel, uid)
  track_challenge(uid, 'coins_earned', final_reward)

  # 9. UI: Construct the success CV2 with the new balance
  components = [
    {
      type: 17,
      accent_color: 0x00FF00,
      components: [
        { type: 10, content: "## #{EMOJI_STRINGS['twitter']} New Post Uploaded!" },
        { type: 14, spacing: 1 },
        { type: 10, content: "Your **#{platform}** post went kinda viral, nice flex. You earned **#{final_reward}** #{EMOJI_STRINGS['s_coin']}!#{bonus_text}\nBalance: **#{DB.get_coins(uid)}** #{EMOJI_STRINGS['s_coin']}.#{mom_remark(uid, 'economy')}" }
      ]
    }
  ]
  send_cv2(event, components)
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!post)
# ------------------------------------------
$bot.command(:post, aliases: [:p],
  description: 'Post on social media for some quick coins!', 
  category: 'Economy'
) do |event|
  execute_post(event)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/post)
# ------------------------------------------
$bot.application_command(:post) do |event|
  execute_post(event)
end