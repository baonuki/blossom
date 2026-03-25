# ==========================================
# COMMAND: summon
# DESCRIPTION: Roll the gacha to obtain VTuber cards.
# CATEGORY: Gacha
# ==========================================

# ------------------------------------------
# LOGIC: Gacha Summon Execution
# ------------------------------------------
def execute_summon(event)
  # 1. Initialization: Get user context and check for "Gacha Pass" perk
  uid = event.user.id
  now = Time.now
  inv = DB.get_inventory(uid)
  is_sub = is_premium?(event.bot, uid)
  
  # Cooldown is 10 minutes (600s) unless they have the Gacha Pass (5 mins / 300s)
  cooldown_duration = (inv['gacha pass'] && inv['gacha pass'] > 0) ? 300 : 600
  last_used = DB.get_cooldown(uid, 'summon')

  # 2. Validation: Check if the portal is still recharging
  if last_used && (now - last_used) < cooldown_duration
    ready_time = (last_used + cooldown_duration).to_i
    embed = Discordrb::Webhooks::Embed.new(
      title: "#{EMOJIS['drink']} Portal Recharging", 
      description: "Your gacha energy is depleted!\nThe portal will be ready <t:#{ready_time}:R>.", 
      color: 0xFF0000
    )
    return event.is_a?(Discordrb::Events::ApplicationCommandEvent) ? event.respond(embeds: [embed]) : event.channel.send_message(nil, false, embed, nil, nil, event.message)
  end

  # 3. Validation: Economy Check
  if DB.get_coins(uid) < SUMMON_COST
    return send_embed(event, 
      title: "#{EMOJIS['info']} Summon", 
      description: "You need **#{SUMMON_COST}** #{EMOJIS['s_coin']} to summon.\nYou currently have **#{DB.get_coins(uid)}**."
    )
  end

  # 4. Transaction: Deduct cost and prepare the banner
  DB.add_coins(uid, -SUMMON_COST)
  active_banner = get_current_banner
  used_manipulator = false

  # 5. RNG Logic: Check for 'RNG Manipulator' usage
  if inv['rng manipulator'] && inv['rng manipulator'] > 0
    DB.remove_inventory(uid, 'rng manipulator', 1)
    used_manipulator = true
    
    # Manipulator guarantees Rare or higher
    roll = rand(31)
    if roll < 25
      rarity = :rare
    elsif roll < 30
      rarity = :legendary
    else
      rarity = :goddess
    end
  else
    # Standard Roll using the global helper
    rarity = roll_rarity(is_sub)
  end

  # 6. Character Selection: Pick a random VTuber from the rarity tier
  pulled_char = active_banner[:characters][rarity].sample
  name = pulled_char[:name]
  gif_url = pulled_char[:gif]
  
  # 7. Premium Perk: 1% chance for subscribers to pull an instant Shiny Ascended version
  is_ascended = (is_sub && rand(100) < 1)

  if is_ascended
    # Instant Ascension grants 5 base copies and triggers the transformation
    DB.add_character(uid, name, rarity.to_s, 5)
    DB.ascend_character(uid, name)
  else
    DB.add_character(uid, name, rarity.to_s, 1)
  end
  
  # 8. Post-Pull Retrieval: Fetch updated stats for the UI
  user_chars = DB.get_collection(uid)
  new_count = user_chars[name]['count']
  new_asc_count = user_chars[name]['ascended'].to_i

  # 9. UI: Final Embed Construction
  emoji = { goddess: '💎', legendary: '🌟', rare: '✨' }.fetch(rarity, '⭐')
  buff_text = used_manipulator ? "\n\n*🔮 RNG Manipulator consumed! Common pulls bypassed.*" : ""
  desc = "#{emoji} You summoned **#{name}** (#{rarity.to_s.capitalize})!\n"
  
  if is_ascended
    buff_text += "\n\n#{EMOJIS['neonsparkle']} **PREMIUM PERK TRIGGERED!**\nYou pulled a **Shiny Ascended** version right out of the portal!"
    desc += "You now own **#{new_asc_count}** Ascended copies of them.#{buff_text}"
  else
    desc += "You now own **#{new_count}** of them.#{buff_text}"
  end

  # 10. Progression: Trigger achievements and set new cooldown
  check_achievement(event.channel, uid, 'first_pull')
  check_achievement(event.channel, uid, 'goddess_luck') if rarity == :goddess
  DB.set_cooldown(uid, 'summon', now)

  send_embed(event, 
    title: "#{EMOJIS['sparkle']} Summon Result: #{active_banner[:name]}", 
    description: desc, 
    fields: [{ name: 'Remaining Balance', value: "#{DB.get_coins(uid)} #{EMOJIS['s_coin']}", inline: true }], 
    image: gif_url
  )
end

# ------------------------------------------
# TRIGGERS: Prefix & Slash Support
# ------------------------------------------
bot.command(:summon, description: 'Roll the gacha!', category: 'Gacha') { |e| execute_summon(e); nil }
bot.application_command(:summon) { |e| execute_summon(e) }