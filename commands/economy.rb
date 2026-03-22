# =========================
# ECONOMY COMMANDS
# =========================

def execute_balance(event, target_user)
  uid = target_user.id
  coins = DB.get_coins(uid)
  is_sub = is_premium?(event.bot, uid)
  daily_info = DB.get_daily_info(uid)

  badges = []
  badges << "#{EMOJIS['developer']} **Bot Developer**" if uid == DEV_ID
  badges << "💎 **Premium**" if is_sub
  
  header = badges.empty? ? "" : badges.join(" | ") + "\n\n"

  embed = Discordrb::Webhooks::Embed.new(
    title: "🌸 #{target_user.display_name}'s Balance",
    description: "#{header}**Coins:** #{coins} #{EMOJIS['s_coin']}\n🔥 **Daily Streak:** #{daily_info['streak']} Days\n\n*Click the buttons below to view your items and VTubers!*",
    color: 0xFFB6C1
  )

  view = Discordrb::Components::View.new
  view.row do |r|
    r.button(custom_id: "menu_home_#{uid}", label: 'Balance', style: :secondary, emoji: '💰', disabled: true)
    r.button(custom_id: "menu_inv_#{uid}", label: 'Inventory', style: :primary, emoji: '🎒')
    r.button(custom_id: "menu_vtubers_#{uid}", label: 'VTuber Totals', style: :success, emoji: '🌟')
  end

  if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
    event.respond(embeds: [embed], components: view)
  else
    event.channel.send_message(nil, false, embed, nil, nil, nil, view)
  end
end

bot.command(:balance, description: 'Show a user\'s coin balance, gacha stats, and inventory', category: 'Economy') do |event|
  execute_balance(event, event.message.mentions.first || event.user)
  nil
end

bot.application_command(:balance) do |event|
  target_id = event.options['user']
  target = target_id ? event.bot.user(target_id.to_i) : event.user
  execute_balance(event, target)
end

def execute_daily(event)
  uid = event.user.id
  now = Time.now
  is_sub = is_premium?(event.bot, uid)
  
  daily_info = DB.get_daily_info(uid)
  last_used = daily_info['at']
  current_streak = daily_info['streak']

  if last_used && (now - last_used) < DAILY_COOLDOWN
    remaining = DAILY_COOLDOWN - (now - last_used)
    return send_embed(event, title: "#{EMOJIS['coin']} Daily Reward", description: "You already claimed your daily #{EMOJIS['worktired']}\nTry again in **#{format_time_delta(remaining)}**.")
  end

  if last_used.nil? || (now - last_used) > (DAILY_COOLDOWN * 2)
    new_streak = 1
    streak_msg = "\n*(Streak reset! Claim within 48h to build it up!)*"
  else
    new_streak = current_streak + 1
    streak_msg = "\n🔥 **Streak:** #{new_streak} days!"
  end

  reward = DAILY_REWARD + (new_streak * 50) 
  bonus_text = streak_msg
  
  inv = DB.get_inventory(uid)
  if inv['neon sign'] && inv['neon sign'] > 0
    reward *= 2
    bonus_text += "\n*(✨ Neon Sign Boost: x2 Payout!)*"
  end

  bonus_text += "\n*(💎 Subscriber Bonus: +10%)*" if is_sub

  final_reward = award_coins(event.bot, uid, reward)
  DB.update_daily_claim(uid, new_streak, now)
  
  send_embed(event, title: "#{EMOJIS['coin']} Daily Reward", description: "You claimed **#{final_reward}** #{EMOJIS['s_coin']}!#{bonus_text}\nNew balance: **#{DB.get_coins(uid)}**.")
end

bot.command(:daily, description: 'Claim your daily coin reward', category: 'Economy') { |e| execute_daily(e); nil }
bot.application_command(:daily) { |e| execute_daily(e) }

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

def execute_work(event)
  uid = event.user.id
  now = Time.now
  last_used = DB.get_cooldown(uid, 'work')
  is_sub = is_premium?(event.bot, uid)
  
  active_cd = is_sub ? (WORK_COOLDOWN / 2) : WORK_COOLDOWN

  if last_used && (now - last_used) < active_cd
    remaining = active_cd - (now - last_used)
    send_embed(event, title: "#{EMOJIS['work']} Work", description: "You are tired #{EMOJIS['worktired']}\nTry working again in **#{format_time_delta(remaining)}**.")
  else
    amount = rand(WORK_REWARD_RANGE)
    bonus_text = ""
    inv = DB.get_inventory(uid)

    if inv['keyboard'] && inv['keyboard'] > 0
      amount = (amount * 1.25).to_i
      bonus_text += "\n*(⌨️ Keyboard Boost: +25%)*"
    end

    bonus_text += "\n*(💎 Subscriber Bonus: +10%)*" if is_sub

    final_amount = award_coins(event.bot, uid, amount)
    DB.set_cooldown(uid, 'work', now)
    send_embed(event, title: "#{EMOJIS['work']} Work", description: "You worked hard and earned **#{final_amount}** #{EMOJIS['s_coin']}!#{bonus_text}\nNew balance: **#{DB.get_coins(uid)}**.")
  end
end

bot.command(:work, description: 'Work for some coins', category: 'Economy') { |e| execute_work(e); nil }
bot.application_command(:work) { |e| execute_work(e) }

def execute_stream(event)
  uid = event.user.id
  now = Time.now
  last_used = DB.get_cooldown(uid, 'stream')
  is_sub = is_premium?(event.bot, uid)

  active_cd = is_sub ? (STREAM_COOLDOWN / 2) : STREAM_COOLDOWN

  if last_used && (now - last_used) < active_cd
    remaining = active_cd - (now - last_used)
    send_embed(event, title: "#{EMOJIS['stream']} Stream Offline", description: "You just finished streaming! Your voice needs a break #{EMOJIS['drink']}\nTry going live again in **#{format_time_delta(remaining)}**.")
  else
    reward = rand(STREAM_REWARD_RANGE)
    game = STREAM_GAMES.sample
    bonus_text = ""
    inv = DB.get_inventory(uid)
    
    if inv['mic'] && inv['mic'] > 0
      reward = (reward * 1.10).to_i
      bonus_text += "\n*(🎙️ Studio Mic Boost: +10%)*"
    end

    bonus_text += "\n*(💎 Subscriber Bonus: +10%)*" if is_sub

    final_reward = award_coins(event.bot, uid, reward)
    DB.set_cooldown(uid, 'stream', now)
    send_embed(event, title: "#{EMOJIS['stream']} Stream Ended", description: "You had a great stream playing **#{game}** and earned **#{final_reward}** #{EMOJIS['s_coin']}!#{bonus_text}\nNew balance: **#{DB.get_coins(uid)}**.")
  end
end

bot.command(:stream, description: 'Go live and earn some coins!', category: 'Economy') { |e| execute_stream(e); nil }
bot.application_command(:stream) { |e| execute_stream(e) }

def execute_post(event)
  uid = event.user.id
  now = Time.now
  last_used = DB.get_cooldown(uid, 'post')
  is_sub = is_premium?(event.bot, uid)

  active_cd = is_sub ? (POST_COOLDOWN / 2) : POST_COOLDOWN

  if last_used && (now - last_used) < active_cd
    remaining = active_cd - (now - last_used)
    send_embed(event, title: "#{EMOJIS['error']} Social Media Break", description: "You're posting too fast! Don't get shadowbanned #{EMOJIS['nervous']}\nTry posting again in **#{format_time_delta(remaining)}**.")
  else
    reward = rand(POST_REWARD_RANGE)
    platform = POST_PLATFORMS.sample
    bonus_text = ""
    inv = DB.get_inventory(uid)

    if inv['headset'] && inv['headset'] > 0
      reward = (reward * 1.25).to_i
      bonus_text += "\n*(🎧 Headset Boost: +25%)*"
    end

    bonus_text += "\n*(💎 Subscriber Bonus: +10%)*" if is_sub

    final_reward = award_coins(event.bot, uid, reward)
    DB.set_cooldown(uid, 'post', now)
    send_embed(event, title: "#{EMOJIS['like']} New Post Uploaded!", description: "Your latest post on **#{platform}** got a lot of engagement! You earned **#{final_reward}** #{EMOJIS['s_coin']}.#{bonus_text}\nNew balance: **#{DB.get_coins(uid)}**.")
  end
end

bot.command(:post, description: 'Post on social media for some quick coins!', category: 'Economy') { |e| execute_post(e); nil }
bot.application_command(:post) { |e| execute_post(e) }

def execute_collab(event)
  uid = event.user.id
  now = Time.now
  last_used = DB.get_cooldown(uid, 'collab')

  if last_used && (now - last_used) < COLLAB_COOLDOWN
    remaining = COLLAB_COOLDOWN - (now - last_used)
    return send_embed(event, title: "#{EMOJIS['worktired']} Collab Burnout", description: "You're collaborating too much! Rest your voice.\nTry again in **#{format_time_delta(remaining)}**.")
  end

  DB.set_cooldown(uid, 'collab', now)
  expire_time = Time.now + 180 
  discord_timestamp = "<t:#{expire_time.to_i}:R>"
  
  collab_id = "collab_#{expire_time.to_i}_#{rand(10000)}"
  ACTIVE_COLLABS[collab_id] = uid 

  embed = Discordrb::Webhooks::Embed.new(
    title: "#{EMOJIS['stream']} Collab Request!",
    description: "#{event.user.mention} is looking for someone to do a collab stream with!\n\nPress the button below to join them! Request expires **#{discord_timestamp}**.",
    color: NEON_COLORS.sample
  )

  view = Discordrb::Components::View.new do |v|
    v.row { |r| r.button(custom_id: collab_id, label: 'Accept Collab', style: :success, emoji: '🤝') }
  end

  if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
    event.respond(content: "Starting collab request...", ephemeral: true)
    msg = event.channel.send_message(nil, false, embed, nil, nil, nil, view)
  else
    msg = event.channel.send_message(nil, false, embed, nil, nil, event.message, view)
  end

  Thread.new do
    sleep 180
    if ACTIVE_COLLABS.key?(collab_id)
      ACTIVE_COLLABS.delete(collab_id)
      failed_embed = Discordrb::Webhooks::Embed.new(title: "#{EMOJIS['x_']} Collab Cancelled", description: "Nobody was available to collab with #{event.user.mention} this time #{EMOJIS['confused']}...", color: 0x808080)
      msg.edit(nil, failed_embed, Discordrb::Components::View.new) if msg
    end
  end
end

bot.command(:collab, description: 'Ask the server to do a collab stream! (30m cooldown)', category: 'Economy') { |e| execute_collab(e); nil }
bot.application_command(:collab) { |e| execute_collab(e) }

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

def execute_bomb(event)
  unless event.user.id == DEV_ID
    return send_embed(event, title: "#{EMOJIS['x_']} Permission Denied", description: 'You need developer permissions to plant a bomb!')
  end

  expire_time = Time.now + 300
  discord_timestamp = "<t:#{expire_time.to_i}:R>"
  bomb_id = "bomb_#{expire_time.to_i}_#{rand(10000)}"
  ACTIVE_BOMBS[bomb_id] = true

  embed = Discordrb::Webhooks::Embed.new(
    title: "#{EMOJIS['bomb']} Bomb Planted!",
    description: "A bomb has been planted! It will explode **#{discord_timestamp}**!\nQuick, press the button to defuse it and earn a reward!",
    color: NEON_COLORS.sample
  )

  view = Discordrb::Components::View.new do |v|
    v.row { |r| r.button(custom_id: bomb_id, label: 'Defuse', style: :danger, emoji: '✂️') }
  end

  if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
    event.respond(content: "Bomb planted!", ephemeral: true)
    msg = event.channel.send_message(nil, false, embed, nil, nil, nil, view)
  else
    msg = event.channel.send_message(nil, false, embed, nil, nil, event.message, view)
  end

  Thread.new do
    sleep 300
    if ACTIVE_BOMBS[bomb_id]
      ACTIVE_BOMBS.delete(bomb_id)
      exploded_embed = Discordrb::Webhooks::Embed.new(title: "#{EMOJIS['bomb']} BOOM!", description: 'Nobody defused it in time... The bomb exploded!', color: 0x000000)
      msg.edit(nil, exploded_embed, Discordrb::Components::View.new) if msg
    end
  end
end

bot.command(:bomb, description: 'Plant a bomb that explodes in 5 minutes (Admin only)', category: 'Fun') { |e| execute_bomb(e); nil }
bot.application_command(:bomb) { |e| execute_bomb(e) }

def execute_coinlb(event)
  raw_top = DB.get_top_coins(50) 
  active_humans = []
  
  raw_top.each do |row|
    user_obj = event.bot.user(row['user_id'])
    if user_obj && !user_obj.bot_account?
      active_humans << row
      break if active_humans.size >= 10
    end
  end

  if active_humans.empty?
    send_embed(event, title: "#{EMOJIS['rich']} Wealth Leaderboard", description: 'The bank is currently empty!')
  else
    desc = active_humans.each_with_index.map do |row, index|
      user_obj = event.bot.user(row['user_id'])
      name = user_obj ? user_obj.username : "User #{row['user_id']}"
      "##{index + 1} — **#{name}**: **#{row['coins']}** #{EMOJIS['s_coin']}"
    end.join("\n")

    send_embed(event, title: "#{EMOJIS['rich']} Global Wealth Leaderboard", description: desc)
  end
end

bot.command(:coinlb, description: 'Show the richest users globally', category: 'Economy') { |e| execute_coinlb(e); nil }
bot.application_command(:coinlb) { |e| execute_coinlb(e) }

def execute_lottery(event, amount)
  uid = event.user.id
  amount = amount.to_i
  amount = 1 if amount <= 0

  cost = amount * 100
  balance = DB.get_coins(uid)

  if balance < cost
    return send_embed(event, title: "❌ Not Enough Coins", description: "You need **#{cost}** #{EMOJIS['s_coin']} for #{amount} tickets!\nYour Balance: **#{balance}**")
  end

  DB.add_coins(uid, -cost)
  DB.enter_lottery(uid, amount)
  
  stats = DB.get_lottery_stats(uid)
  pool = 100 + (stats[:total_tickets] * 100)

  send_embed(
    event, 
    title: "🎟️ Lottery Entered!", 
    description: "You bought **#{amount}** tickets! 🌸\n\n" \
                 "💰 **Current Prize Pool:** #{pool} #{EMOJIS['s_coin']}\n" \
                 "🎫 **Total Tickets Sold:** #{stats[:total_tickets]}\n" \
                 "👤 **Your Tickets:** #{stats[:user_tickets]}\n\n" \
                 "*Blossom will DM the winner at the top of the hour!*"
  )
end

bot.command(:lottery, description: 'Buy tickets for the hourly global lottery!') do |event, amount|
  execute_lottery(event, amount || 1)
  nil
end

bot.application_command(:lottery) do |event|
  execute_lottery(event, event.options['tickets'] || 1)
end

def execute_lotteryinfo(event)
  uid = event.user.id
  stats = DB.get_lottery_stats(uid)
  
  pool = 100 + (stats[:total_tickets] * 100)
  
  now = Time.now
  next_hour = Time.new(now.year, now.month, now.day, now.hour) + 3600
  
  send_embed(
    event,
    title: "🎟️ Global Lottery Status",
    description: "The winning ticket will be drawn **<t:#{next_hour.to_i}:R>**!\n\n" \
                 "💰 **Current Prize Pool:** #{pool} #{EMOJIS['s_coin']}\n" \
                 "🎫 **Total Tickets Sold:** #{stats[:total_tickets]}\n" \
                 "🌸 **Your Tickets:** #{stats[:user_tickets]}\n\n" \
                 "*Want to increase your odds? Use `b!lottery <amount>`!*"
  )
end

bot.command(:lotteryinfo, description: 'View current lottery stats and your tickets', category: 'Economy') do |event|
  execute_lotteryinfo(event)
  nil
end

bot.application_command(:lotteryinfo) do |event|
  execute_lotteryinfo(event)
end