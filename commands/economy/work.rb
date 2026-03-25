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
  if last_used && (now - last_used) < active_cd
    remaining = active_cd - (now - last_used)
    send_embed(event, 
      title: "#{EMOJIS['work']} Work", 
      description: "You are tired #{EMOJIS['worktired']}\nTry working again in **#{format_time_delta(remaining)}**."
    )
  else
    # 4. Calculation: Roll for the base reward range
    amount = rand(WORK_REWARD_RANGE)
    bonus_text = ""
    inv = DB.get_inventory(uid)

    # 5. Item Buffs: Check for 'Keyboard' (+25% reward boost)
    if inv['keyboard'] && inv['keyboard'] > 0
      amount = (amount * 1.25).to_i
      bonus_text += "\n*(⌨️ Keyboard Boost: +25%)*"
    end

    # 6. Premium Note: The 10% global boost is handled inside award_coins
    bonus_text += "\n*(💎 Subscriber Bonus: +10%)*" if is_sub

    # 7. Database: Record the cooldown and grant the final reward
    # award_coins handles the final math and global premium multipliers.
    final_amount = award_coins(event.bot, uid, amount)
    DB.set_cooldown(uid, 'work', now)

    # 8. UI: Send the success Embed with the updated balance
    send_embed(event, 
      title: "#{EMOJIS['work']} Work", 
      description: "You worked hard and earned **#{final_amount}** #{EMOJIS['s_coin']}!#{bonus_text}\n" \
                   "New balance: **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}."
    )
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!work)
# ------------------------------------------
bot.command(:work, 
  description: 'Work for some coins', 
  category: 'Economy'
) do |event|
  execute_work(event)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/work)
# ------------------------------------------
bot.application_command(:work) do |event|
  execute_work(event)
end