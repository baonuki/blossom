# ==========================================
# COMMAND: cooldowns
# DESCRIPTION: Displays a live countdown for all income-generating commands.
# CATEGORY: Economy / Utility
# ==========================================

# ------------------------------------------
# LOGIC: Cooldown Display Execution
# ------------------------------------------
def execute_cooldowns(event)
  # 1. Initialization: Fetch user ID and their current status/inventory
  uid = event.user.id
  inv = DB.get_inventory(uid)
  is_sub = is_premium?(event.bot, uid)
  daily_info = DB.get_daily_info(uid)
  
  # 2. The Helper: A Lambda function to handle time-math and Discord timestamps
  # This avoids repeating the "if last_used" logic for every single command.
  check_cd = ->(type, cooldown_duration, last_used_override = nil) do
    last_used = last_used_override || DB.get_cooldown(uid, type)
    if last_used && (Time.now - last_used) < cooldown_duration
      ready_time = last_used + cooldown_duration
      "Ready <t:#{ready_time.to_i}:R>" # Returns a relative Discord timestamp
    else
      "**Ready!**"
    end
  end

  # 3. Dynamic Scaling: Apply "Premium" buffs (50% faster timers)
  work_cd = is_sub ? (WORK_COOLDOWN / 2) : WORK_COOLDOWN
  stream_cd = is_sub ? (STREAM_COOLDOWN / 2) : STREAM_COOLDOWN
  post_cd = is_sub ? (POST_COOLDOWN / 2) : POST_COOLDOWN

  # 4. Item Buffs: Check for 'Gacha Pass' to reduce summon wait time
  summon_duration = (inv['gacha pass'] && inv['gacha pass'] > 0) ? 300 : 600

  # 5. Field Construction: Build the data array for the Embed
  cd_fields = [
    { name: 'daily', value: check_cd.call('daily', DAILY_COOLDOWN, daily_info['at']), inline: true },
    { name: 'work', value: check_cd.call('work', work_cd), inline: true },
    { name: 'stream', value: check_cd.call('stream', stream_cd), inline: true },
    { name: 'post', value: check_cd.call('post', post_cd), inline: true },
    { name: 'collab', value: check_cd.call('collab', COLLAB_COOLDOWN), inline: true },
    { name: 'summon', value: check_cd.call('summon', summon_duration), inline: true } 
  ]

  # 6. UI Logic: Prepare extra context for Daily Streaks and Reminders
  streak_text = daily_info['streak'] > 0 ? "\n🔥 **Daily Streak:** #{daily_info['streak']} Days" : ""
  reminder_text = daily_info['channel'] ? "\n🔔 **Auto-Reminder:** ON" : ""

  # 7. Messaging: Send the finalized summary Embed
  send_embed(
    event, 
    title: "#{EMOJIS['info']} #{event.user.display_name}'s Cooldowns", 
    description: "Here are your current economy timers:#{streak_text}#{reminder_text}", 
    fields: cd_fields
  )
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!cooldowns)
# ------------------------------------------
bot.command(:cooldowns, 
  description: 'Check your active timers for economy commands', 
  category: 'Economy'
) do |event|
  execute_cooldowns(event)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/cooldowns)
# ------------------------------------------
bot.application_command(:cooldowns) do |event|
  execute_cooldowns(event)
end