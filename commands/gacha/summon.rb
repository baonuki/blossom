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
  inv_array = DB.get_inventory(uid)
  inv = inv_array.each_with_object({}) { |item, h| h[item['item_id']] = item['quantity'] }
  is_sub = is_premium?(event.bot, uid)
  
  # Cooldown is 10 minutes (600s) unless they have the Gacha Pass (5 mins / 300s)
  cooldown_duration = (inv['gacha pass'] && inv['gacha pass'] > 0) ? 300 : 600
  last_used = DB.get_cooldown(uid, 'summon')

  # 2. Validation: Check if the portal is still recharging
  used_pill = false
  if last_used && (now - last_used) < cooldown_duration
    if inv['stamina pill'] && inv['stamina pill'] > 0
      DB.remove_inventory(uid, 'stamina pill', 1)
      used_pill = true
      check_achievement(event.channel, uid, 'use_pill')
    else
      ready_time = (last_used + cooldown_duration).to_i
      return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['drink']} Portal Recharging" },
        { type: 14, spacing: 1 },
        { type: 10, content: "Chill, chat. The portal's still recharging.\nTry again <t:#{ready_time}:R>. Go touch grass or something." }
      ]}])
    end
  end

  # 3. Validation: Economy Check
  if DB.get_coins(uid) < SUMMON_COST
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['info']} Summon" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You need **#{SUMMON_COST}** #{EMOJI_STRINGS['s_coin']} to open the portal. You've got **#{DB.get_coins(uid)}**. Go grind, broke boy." }
    ]}])
  end

  # 4. Transaction: Deduct cost and prepare the banner
  DB.add_coins(uid, -SUMMON_COST)
  active_banner = get_current_banner
  used_manipulator = false

  # 5. RNG Logic: Check for 'RNG Manipulator' usage
  pity_triggered = false
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

  # 5b. Pity System: Premium users get a guaranteed Legendary/Goddess after 30 pulls without one
  if is_sub
    if rarity == :legendary || rarity == :goddess
      DB.reset_pity(uid)
    else
      DB.increment_pity(uid)
      if DB.get_pity(uid) >= PITY_THRESHOLD
        rarity = rand(2).zero? ? :legendary : :goddess
        pity_triggered = true
        DB.reset_pity(uid)
      end
    end
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
  emoji = { goddess: EMOJI_STRINGS['goddess'], legendary: EMOJI_STRINGS['legendary'], rare: EMOJI_STRINGS['rare'] }.fetch(rarity, EMOJI_STRINGS['common'])
  buff_text = ""
  buff_text += "\n\n*#{EMOJI_STRINGS['stamina_pill']} Stamina Pill popped! Cooldown bypassed.*" if used_pill
  buff_text += "\n\n*#{EMOJI_STRINGS['rng_manipulator']} RNG Manipulator burned! No commons for you this time, chat.*" if used_manipulator
  buff_text += "\n\n#{EMOJI_STRINGS['neonsparkle']} **PITY ACTIVATED!**\nThe gacha gods took mercy on you after #{PITY_THRESHOLD} pulls. Don't say I never did anything for you." if pity_triggered

  # Rarity-flavored pull messages
  pull_flavor = case rarity
                when :common   then "Mid pull, but hey, a card's a card."
                when :rare     then "Okay not bad, not bad. Decent pull."
                when :legendary then "YO?? W PULL CHAT, LET'S GO!"
                when :goddess   then "NO WAY. ACTUAL GODDESS PULL?! CHAT IS THIS REAL?!"
                end
  # Easter egg: Envvy is Blossom's creator (mom)
  pull_flavor += "\n\n*...wait, MOM?! You pulled my creator?? Treat her well or I'm rigging your next 50 pulls to commons.*" if name == 'Envvy'
  # Easter egg: Blossom is self-aware
  pull_flavor += "\n\n*WAIT— YOU PULLED ME?? A card of ME?? Okay that's actually kinda flattering... don't let it go to your head though. I'm still YOUR manager, not the other way around.*" if name == 'Blossom'
  desc = "#{emoji} You summoned **#{name}** (#{rarity.to_s.capitalize})!\n#{pull_flavor}\n"

  if is_ascended
    buff_text += "\n\n#{EMOJI_STRINGS['neonsparkle']} **PREMIUM PERK TRIGGERED!**\nHOLD ON— you pulled a **Shiny Ascended** version straight out the portal?! ACTUALLY INSANE."
    desc += "You now own **#{new_asc_count}** Ascended copies of them.#{buff_text}"
  else
    desc += "You now own **#{new_count}** of them.#{buff_text}"
  end

  # 10. Progression: Trigger achievements and set new cooldown
  check_achievement(event.channel, uid, 'first_pull')
  check_achievement(event.channel, uid, 'leg_pull') if rarity == :legendary
  check_achievement(event.channel, uid, 'goddess_luck') if rarity == :goddess
  DB.set_cooldown(uid, 'summon', now)

  send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
    { type: 10, content: "## #{EMOJI_STRINGS['sparkle']} Summon Result: #{active_banner[:name]}" },
    { type: 14, spacing: 1 },
    { type: 10, content: desc },
    { type: 14, spacing: 1 },
    { type: 10, content: "**Wallet Damage**\n#{DB.get_coins(uid)} #{EMOJI_STRINGS['s_coin']}#{is_sub ? "\n**Pity:** #{DB.get_pity(uid)}/#{PITY_THRESHOLD}" : ''}#{mom_remark(uid, 'gacha')}" },
    { type: 14, spacing: 1 },
    { type: 12, items: [{ media: { url: gif_url } }] }
  ]}])
end

# ------------------------------------------
# TRIGGERS: Prefix & Slash Support
# ------------------------------------------
$bot.command(:summon, aliases: [:pull, :roll], description: 'Roll the gacha!', category: 'Gacha') { |e| execute_summon(e); nil }
$bot.application_command(:summon) { |e| execute_summon(e) }