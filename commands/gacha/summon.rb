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

  # 3. Shiny Mode: Double cost if active
  shiny_mode = is_sub && DB.get_shiny_mode(uid)
  summon_cost = shiny_mode ? SUMMON_COST * 2 : SUMMON_COST

  # 4. Validation: Economy Check
  if DB.get_coins(uid) < summon_cost
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['info']} Summon" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You need **#{summon_cost}** #{EMOJI_STRINGS['s_coin']} to open the portal#{shiny_mode ? ' *(Shiny Mode 2x)*' : ''}. You've got **#{DB.get_coins(uid)}**. Go grind, broke boy." }
    ]}])
  end

  # 5. Transaction: Deduct cost and prepare the banner
  DB.add_coins(uid, -summon_cost)
  active_banner = get_user_banner(uid)
  used_manipulator = false
  is_event_pull = false

  # 5. Event Check: During event month, chance to pull an event character instead
  if Time.now.month == SPRING_CARNIVAL[:month] && rand(100) < EVENT_PULL_CHANCE && !active_banner.key?(:expires_at)
    event_chars = SPRING_CARNIVAL[:characters].values.flatten
    unless event_chars.empty?
      pulled_event = event_chars.sample
      event_rarity = SPRING_CARNIVAL[:characters].find { |_r, list| list.include?(pulled_event) }&.first
      if pulled_event && event_rarity
        is_event_pull = true
        rarity = event_rarity
        pulled_char = pulled_event
      end
    end
  end

  # 6. RNG Logic: Check for 'RNG Manipulator' usage (skip if event pull)
  pity_triggered = false
  unless is_event_pull
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

    # 6b. Pity System: Premium users get a guaranteed Legendary/Goddess after 30 pulls without one
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

    # 7. Character Selection: Pick a random VTuber from the rarity tier
    pulled_char = active_banner[:characters][rarity].sample
  end
  name = pulled_char[:name]
  gif_url = pulled_char[:gif]
  
  # 7. Premium Perk: Shiny Ascended chance (1% normal, 2% in Shiny Hunting Mode)
  shiny_chance = shiny_mode ? 2 : 1
  is_ascended = (is_sub && rand(100) < shiny_chance)

  if is_ascended
    # Instant Ascension grants 5 base copies and triggers the transformation
    DB.add_character(uid, name, rarity.to_s, 5)
    DB.ascend_character(uid, name)
  else
    DB.add_character(uid, name, rarity.to_s, 1)
  end
  
  # 8. Auto-Sell Check: Premium users with autosell enabled, commons they own 5+ of
  autosold = false
  autosold_coins = 0
  if !is_ascended && is_sub && DB.get_autosell(uid) && rarity == :common
    pre_count = DB.get_collection(uid)[name]
    if pre_count && pre_count['count'] >= 5
      autosold = true
      autosold_coins = SELL_PRICES['common']
      DB.remove_character(uid, name, 1)
      DB.add_coins(uid, autosold_coins)
    end
  end

  # 9. Post-Pull Retrieval: Fetch updated stats for the UI
  user_chars = DB.get_collection(uid)
  new_count = user_chars[name]['count']
  new_asc_count = user_chars[name]['ascended'].to_i

  # 9. UI: Final Embed Construction
  emoji = { goddess: EMOJI_STRINGS['goddess'], legendary: EMOJI_STRINGS['legendary'], rare: EMOJI_STRINGS['rare'] }.fetch(rarity, EMOJI_STRINGS['common'])
  buff_text = ""
  buff_text += "\n\n*#{EMOJI_STRINGS['stamina_pill']} Stamina Pill popped! Cooldown bypassed.*" if used_pill
  buff_text += "\n\n*#{EMOJI_STRINGS['rng_manipulator']} RNG Manipulator burned! No commons for you this time, chat.*" if used_manipulator
  buff_text += "\n\n🎪 **EVENT PULL!** You pulled a Spring Carnival character straight from the event portal!" if is_event_pull
  buff_text += "\n\n#{EMOJI_STRINGS['neonsparkle']} **PITY ACTIVATED!**\nThe gacha gods took mercy on you after #{PITY_THRESHOLD} pulls. Don't say I never did anything for you." if pity_triggered
  buff_text += "\n\n♻️ **AUTO-SOLD!** You already had 5+ of this common. Instant **+#{autosold_coins}** #{EMOJI_STRINGS['s_coin']}." if autosold
  buff_text += "\n\n#{EMOJI_STRINGS['neonsparkle']} *Shiny Hunting Mode active — 2x cost, 2x sparkle chance.*" if shiny_mode

  # Rarity-flavored pull messages
  pull_flavor = case rarity
                when :common   then "Mid pull, but hey, a card's a card."
                when :rare     then "Okay not bad, not bad. Decent pull."
                when :legendary then "YO?? W PULL CHAT, LET'S GO!"
                when :goddess   then "NO WAY. ACTUAL GODDESS PULL?! CHAT IS THIS REAL?!"
                end
  # Easter egg: Envvy is Blossom's creator (mom)
  pull_flavor += "\n\n*...wait, MOM'S PAST LIFE?! You pulled the legend herself. Treat her well or I'm rigging your next 50 pulls to commons.*" if name == 'Envvy'
  # Easter egg: baonuki is mom's current VTuber persona
  pull_flavor += "\n\n*BAONUKI?! That's my mama's current form, chat. Handle that card with respect or I'll personally curse your RNG.*" if name.downcase == 'baonuki'
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

  # Track pull count and check milestones
  total_pulls = DB.increment_pull_count(uid)
  check_achievement(event.channel, uid, 'summon_100') if total_pulls >= 100
  check_achievement(event.channel, uid, 'summon_500') if total_pulls >= 500
  check_achievement(event.channel, uid, 'summon_1000') if total_pulls >= 1000

  # Back-to-back: Two Rare+ pulls in a row
  last_rarity = DB.get_last_pull_rarity(uid)
  is_rare_plus = [:rare, :legendary, :goddess].include?(rarity)
  was_rare_plus = %w[rare legendary goddess].include?(last_rarity)
  check_achievement(event.channel, uid, 'back_to_back') if is_rare_plus && was_rare_plus
  DB.set_last_pull_rarity(uid, rarity.to_s)

  DB.set_cooldown(uid, 'summon', now)
  track_challenge(uid, 'cards_pulled', 1)

  send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
    { type: 10, content: "## #{EMOJI_STRINGS['neonsparkle']} Summon Result" },
    { type: 14, spacing: 1 },
    { type: 10, content: desc },
    { type: 14, spacing: 1 },
    { type: 10, content: "**Wallet Damage** (-#{summon_cost} #{EMOJI_STRINGS['s_coin']}#{shiny_mode ? ' Shiny Mode' : ''})\n#{DB.get_coins(uid)} #{EMOJI_STRINGS['s_coin']}#{is_sub ? "\n**Pity:** #{DB.get_pity(uid)}/#{PITY_THRESHOLD}" : ''}#{mom_remark(uid, 'gacha')}" },
    { type: 14, spacing: 1 },
    { type: 12, items: [{ media: { url: gif_url } }] }
  ]}])
end

# ------------------------------------------
# TRIGGERS: Prefix & Slash Support
# ------------------------------------------
$bot.command(:summon, aliases: [:pull, :roll], description: 'Roll the gacha!', category: 'Gacha') { |e| execute_summon(e); nil }
$bot.application_command(:summon) { |e| execute_summon(e) }