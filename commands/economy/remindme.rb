def execute_remindme(event)
  uid = event.user.id
  channel_id = event.channel.id
  
  daily_info = DB.get_daily_info(uid)
  is_currently_on = !daily_info['channel'].nil?
  
  if is_currently_on
    DB.toggle_daily_reminder(uid, nil)
    send_embed(event, title: "🔔 Daily Reminder", description: "I have turned **OFF** your daily reminder!")
  else
    DB.toggle_daily_reminder(uid, channel_id)
    send_embed(event, title: "🔔 Daily Reminder", description: "I have turned **ON** your daily reminder! 🌸\nI will ping you right here in #{event.channel.mention} when your next daily is ready.")
  end
end

bot.command(:remindme, description: 'Toggle your daily reward reminder', category: 'Economy') { |e| execute_remindme(e); nil }
bot.application_command(:remindme) { |e| execute_remindme(e) }