# ==========================================
# COMMAND: work
# DESCRIPTION: Perform a standard work task to earn a base coin reward.
# CATEGORY: Economy
# ==========================================

# ------------------------------------------
# LOGIC: Work Execution
# ------------------------------------------
def execute_work(event)
  # 1. Initialization: Get user ID and current premium status
  uid = event.user.id
  now = Time.now
  is_sub = is_premium?(event.bot, uid)
  last_used = DB.get_cooldown(uid, 'work')
  
  # 2. Cooldown Scaling: Subscribers receive a 50% reduction in wait time
  active_cd = is_sub ? (WORK_COOLDOWN / 2) : WORK_COOLDOWN

  # 3. Validation: Check if the user is still on their rest period
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
            { type: 10, content: "## #{EMOJI_STRINGS['work']} Work" },
            { type: 14, spacing: 1 },
            { type: 10, content: "You're tired already?? Go take a nap or something.\nCome back in **#{format_time_delta(remaining)}**." }
          ]
        }
      ]
      return send_cv2(event, components)
    end
  end

  # 4. Calculation: Roll for the base reward range
  amount = rand(WORK_REWARD_RANGE)
  bonus_text = ""
  inv_array = DB.get_inventory(uid)
  inv = inv_array.each_with_object({}) { |item, h| h[item['item_id']] = item['quantity'] }

  # 5. Item Buffs: Check for 'Keyboard' (+25% reward boost)
  if inv['keyboard'] && inv['keyboard'] > 0
    amount = (amount * 1.25).to_i
    bonus_text += "\n*(⌨️ Keyboard Boost: +25%)*"
  end

  # 6. Premium Note: The 10% global boost is handled inside award_coins
  bonus_text += "\n*(#{EMOJI_STRINGS['prisma']} Subscriber Bonus: +10%)*" if is_sub

  # 6b. Gamer Fuel notification
  bonus_text += "\n*(#{EMOJI_STRINGS['gamer_fuel']} Gamer Fuel burned! Cooldown bypassed.)*" if used_fuel

  # 7. Database: Record the cooldown and grant the final reward
  # award_coins handles the final math and global premium multipliers.
  final_amount = award_coins(event.bot, uid, amount)
  DB.set_cooldown(uid, 'work', now)

  # 8. Achievements & Tracking
  check_achievement(event.channel, uid, 'first_work')
  check_wealth_achievements(event.channel, uid)
  track_challenge(uid, 'coins_earned', final_amount)

  # 9. UI: Send the success CV2 with the updated balance
  components = [
    {
      type: 17,
      accent_color: 0x00FF00,
      components: [
        { type: 10, content: "## #{EMOJI_STRINGS['youtube']} Work" },
        { type: 14, spacing: 1 },
        { type: 10, content: "Not bad, chat. You ground out **#{final_amount}** #{EMOJI_STRINGS['s_coin']}. The hustle is real.#{bonus_text}\nBalance: **#{DB.get_coins(uid)}** #{EMOJI_STRINGS['s_coin']}.#{mom_remark(uid, 'economy')}" }
      ]
    }
  ]
  send_cv2(event, components)
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!work)
# ------------------------------------------
$bot.command(:work, aliases: [:w],
  description: 'Work for some coins', 
  category: 'Economy'
) do |event|
  execute_work(event)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/work)
# ------------------------------------------
$bot.application_command(:work) do |event|
  execute_work(event)
end