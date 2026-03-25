def execute_summon(event)
  uid = event.user.id
  now = Time.now
  last_used = DB.get_cooldown(uid, 'summon')
  inv = DB.get_inventory(uid)
  is_sub = is_premium?(event.bot, uid)
  cooldown_duration = (inv['gacha pass'] && inv['gacha pass'] > 0) ? 300 : 600

  if last_used && (now - last_used) < cooldown_duration
    ready_time = (last_used + cooldown_duration).to_i
    embed = Discordrb::Webhooks::Embed.new(title: "#{EMOJIS['drink']} Portal Recharging", description: "Your gacha energy is depleted!\nThe portal will be ready <t:#{ready_time}:R>.", color: 0xFF0000)
    if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
      return event.respond(embeds: [embed])
    else
      return event.channel.send_message(nil, false, embed, nil, nil, event.message)
    end
  end

  if DB.get_coins(uid) < SUMMON_COST
    return send_embed(event, title: "#{EMOJIS['info']} Summon", description: "You need **#{SUMMON_COST}** #{EMOJIS['s_coin']} to summon.\nYou currently have **#{DB.get_coins(uid)}**.")
  end

  DB.add_coins(uid, -SUMMON_COST)
  active_banner = get_current_banner
  
  used_manipulator = false
  inv = DB.get_inventory(uid)
  if inv['rng manipulator'] && inv['rng manipulator'] > 0
    DB.remove_inventory(uid, 'rng manipulator', 1)
    used_manipulator = true
    roll = rand(31)
    if roll < 25
      rarity = :rare
    elsif roll < 30
      rarity = :legendary
    else
      rarity = :goddess
    end
  else
    rarity = roll_rarity(is_sub)
  end

  pulled_char = active_banner[:characters][rarity].sample
  name = pulled_char[:name]
  gif_url = pulled_char[:gif]
  
  is_ascended = false
  is_ascended = true if is_sub && rand(100) < 1

  if is_ascended
    DB.add_character(uid, name, rarity.to_s, 5)
    DB.ascend_character(uid, name)
  else
    DB.add_character(uid, name, rarity.to_s, 1)
  end
  
  user_chars = DB.get_collection(uid)
  new_count = user_chars[name]['count']
  new_asc_count = user_chars[name]['ascended'].to_i

  rarity_label = rarity.to_s.capitalize
  emoji = case rarity
          when :goddess   then '💎'
          when :legendary then '🌟'
          when :rare      then '✨'
          else '⭐'
          end

  buff_text = used_manipulator ? "\n\n*🔮 RNG Manipulator consumed! Common pulls bypassed.*" : ""
  desc = "#{emoji} You summoned **#{name}** (#{rarity_label})!\n"
  
  if is_ascended
    buff_text += "\n\n#{EMOJIS['neonsparkle']} **PREMIUM PERK TRIGGERED!**\nYou pulled a **Shiny Ascended** version right out of the portal!"
    desc += "You now own **#{new_asc_count}** Ascended copies of them.#{buff_text}"
  else
    desc += "You now own **#{new_count}** of them.#{buff_text}"
  end

  check_achievement(event.channel, event.user.id, 'first_pull')
  check_achievement(event.channel, event.user.id, 'goddess_luck') if rarity.to_s == 'goddess'

  send_embed(event, title: "#{EMOJIS['sparkle']} Summon Result: #{active_banner[:name]}", description: desc, fields: [{ name: 'Remaining Balance', value: "#{DB.get_coins(uid)} #{EMOJIS['s_coin']}", inline: true }], image: gif_url)
  DB.set_cooldown(uid, 'summon', now)
end

bot.command(:summon, description: 'Roll the gacha!', category: 'Gacha') { |e| execute_summon(e); nil }
bot.application_command(:summon) { |e| execute_summon(e) }