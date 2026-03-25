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
    
    send_embed(event, 
      title: "🔔 Daily Reminder", 
      description: "I have turned **OFF** your daily reminder!"
    )
  else
    # --- TURN ON ---
    # Store the current channel ID so Blossom knows where to send the ping
    DB.toggle_daily_reminder(uid, channel_id)
    
    send_embed(event, 
      title: "🔔 Daily Reminder", 
      description: "I have turned **ON** your daily reminder! 🌸\n" \
                   "I will ping you right here in #{event.channel.mention} when your next daily is ready."
    )
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!remindme)
# ------------------------------------------
bot.command(:remindme, 
  description: 'Toggle your daily reward reminder', 
  category: 'Economy'
) do |event|
  execute_remindme(event)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/remindme)
# ------------------------------------------
bot.application_command(:remindme) do |event|
  execute_remindme(event)
end