# ==========================================
# COMMAND: remindme
# DESCRIPTION: Toggles a notification for when your daily reward is ready.
# CATEGORY: Economy / Utility
# ==========================================

# ------------------------------------------
# LOGIC: Reminder Toggle Execution
# ------------------------------------------
def execute_remindme(event)
  # 1. Initialization: Get user ID and the current channel ID
  uid = event.user.id
  channel_id = event.channel.id

  # 2. Data Retrieval: Check if the user already has a reminder channel set
  daily_info = DB.get_daily_info(uid)
  is_currently_on = !daily_info['channel'].nil?
  
  # 3. Branching Logic: Toggle the reminder status
  if is_currently_on
    # --- TURN OFF ---
    # Passing nil clears the channel ID in the database
    DB.toggle_daily_reminder(uid, nil)

    components = [
      {
        type: 17,
        accent_color: 0xFF0000,
        components: [
          { type: 10, content: "## 🔔 Daily Reminder" },
          { type: 14, spacing: 1 },
          { type: 10, content: "Fine, I'll stop bugging you. Daily reminder is **OFF**. Don't come crying to me when you break your streak though.#{mom_remark(uid, 'general')}" }
        ]
      }
    ]
    send_cv2(event, components)
  else
    # --- TURN ON ---
    # Store the current channel ID so Blossom knows where to send the ping
    DB.toggle_daily_reminder(uid, channel_id)

    components = [
      {
        type: 17,
        accent_color: 0x00FF00,
        components: [
          { type: 10, content: "## 🔔 Daily Reminder" },
          { type: 14, spacing: 1 },
          { type: 10, content: "Daily reminder is **ON**! I'll ping you right here in #{event.channel.mention} when your reward is ready. Consider me your personal alarm clock — you're welcome.#{mom_remark(uid, 'general')}" }
        ]
      }
    ]
    send_cv2(event, components)
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!remindme)
# ------------------------------------------
$bot.command(:remindme, aliases: [:remind],
  description: 'Toggle your daily reward reminder', 
  category: 'Economy'
) do |event|
  execute_remindme(event)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/remindme)
# ------------------------------------------
$bot.application_command(:remindme) do |event|
  execute_remindme(event)
end