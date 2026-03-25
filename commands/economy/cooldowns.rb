def execute_cooldowns(event)
  uid = event.user.id
  inv = DB.get_inventory(uid)
  is_sub = is_premium?(event.bot, uid)
  daily_info = DB.get_daily_info(uid)
  
  check_cd = ->(type, cooldown_duration, last_used_override = nil) do
    last_used = last_used_override || DB.get_cooldown(uid, type)
    if last_used && (Time.now - last_used) < cooldown_duration
      ready_time = last_used + cooldown_duration
      "Ready <t:#{ready_time.to_i}:R>"
    else
      "**Ready!**"
    end
  end

  work_cd = is_sub ? (WORK_COOLDOWN / 2) : WORK_COOLDOWN
  stream_cd = is_sub ? (STREAM_COOLDOWN / 2) : STREAM_COOLDOWN
  post_cd = is_sub ? (POST_COOLDOWN / 2) : POST_COOLDOWN
  summon_duration = (inv['gacha pass'] && inv['gacha pass'] > 0) ? 300 : 600

  cd_fields = [
    { name: 'daily', value: check_cd.call('daily', DAILY_COOLDOWN, daily_info['at']), inline: true },
    { name: 'work', value: check_cd.call('work', work_cd), inline: true },
    { name: 'stream', value: check_cd.call('stream', stream_cd), inline: true },
    { name: 'post', value: check_cd.call('post', post_cd), inline: true },
    { name: 'collab', value: check_cd.call('collab', COLLAB_COOLDOWN), inline: true },
    { name: 'summon', value: check_cd.call('summon', summon_duration), inline: true } 
  ]

  streak_text = daily_info['streak'] > 0 ? "\n🔥 **Daily Streak:** #{daily_info['streak']} Days" : ""
  reminder_text = daily_info['channel'] ? "\n🔔 **Auto-Reminder:** ON" : ""

  send_embed(
    event, 
    title: "#{EMOJIS['info']} #{event.user.display_name}'s Cooldowns", 
    description: "Here are your current economy timers:#{streak_text}#{reminder_text}", 
    fields: cd_fields
  )
end

bot.command(:cooldowns, description: 'Check your active timers for economy commands', category: 'Developer') { |e| execute_cooldowns(e); nil }
bot.application_command(:cooldowns) { |e| execute_cooldowns(e) }