# ==========================================
# INTERACTION: Boss Attack Button
# DESCRIPTION: Handles boss attack clicks.
# ==========================================

$bot.button(custom_id: /^boss_attack_\d+_\d+$/) do |event|
  parts = event.custom_id.split('_')
  boss_id = parts[2].to_i
  owner_id = parts[3]

  # Only the command owner can use their attack button
  if event.user.id.to_s != owner_id
    event.respond(content: "This isn't your fight screen! Use `#{PREFIX}boss` to get your own.", ephemeral: true)
    next
  end

  uid = event.user.id
  is_sub = is_premium?(event.bot, uid)

  # Check boss still exists and isn't defeated
  now = Time.now
  boss = DB.get_current_boss(now.month, now.year)
  unless boss && boss['id'] == boss_id && !boss['defeated']
    update_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Boss Unavailable" },
      { type: 14, spacing: 1 },
      { type: 10, content: "This boss has already been defeated or doesn't exist!" }
    ]}])
    next
  end

  # Attack cooldown check
  participant = DB.get_boss_participant(boss_id, uid)
  if participant
    last_atk = Time.parse(participant['last_attack'].to_s)
    if (now - last_atk) < BOSS_ATTACK_COOLDOWN
      remaining = BOSS_ATTACK_COOLDOWN - (now - last_atk)
      update_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## \u{1F5E1}\u{FE0F} Attack Cooldown" },
        { type: 14, spacing: 1 },
        { type: 10, content: "You already attacked recently! Come back in **#{format_time_delta(remaining)}**." }
      ]}])
      next
    end
  end

  # Calculate and deal damage
  damage = is_sub ? rand(BOSS_DAMAGE_PREMIUM) : rand(BOSS_DAMAGE_RANGE)
  new_hp = DB.boss_attack(boss_id, uid, damage)
  track_challenge(uid, 'boss_attacks', 1)

  # Check for defeat
  if new_hp <= 0
    DB.boss_defeat(boss_id)

    # Award Prisma to all participants
    all_participants = DB.get_boss_participants(boss_id)
    all_participants.each do |p|
      DB.add_prisma(p['user_id'].to_i, BOSS_DEFEAT_PRISMA)
    end

    # Update the attacker's message
    update_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: [
      { type: 10, content: "## \u{1F480} #{boss['boss_name']} DEFEATED!" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You dealt the **FINAL BLOW** \u2014 **#{damage}** damage! \u{1F525}\n\nThe **#{boss['boss_name']}** has been destroyed!\n\n**#{all_participants.size}** fighters each earned **#{BOSS_DEFEAT_PRISMA}** #{EMOJI_STRINGS['prisma']}!\n\nA new boss will appear next month.#{mom_remark(uid, 'arcade')}" }
    ]}])

    # Announce in boss channel (all servers that have one set)
    begin
      # Try to announce in the server where the kill happened
      boss_channel_id = DB.get_boss_channel(event.server.id) if event.server
      if boss_channel_id
        channel = event.bot.channel(boss_channel_id)
        if channel
          channel.send_message(
            "## \u{1F480} THE #{boss['boss_name'].upcase} HAS BEEN SLAIN! #{EMOJI_STRINGS['neonsparkle']}\n\n" \
            "**#{event.user.name}** dealt the final blow!\n" \
            "**#{all_participants.size}** brave fighters each earned **#{BOSS_DEFEAT_PRISMA}** #{EMOJI_STRINGS['prisma']}!\n\n" \
            "A new boss will appear next month. GG, chat! \u{1F338}"
          )
        end
      end
    rescue => e
      puts "[BOSS ANNOUNCE] #{e.message}"
    end
  else
    # Normal attack
    hp_pct = (new_hp.to_f / boss['max_hp'] * 100).round(1)
    filled = (hp_pct / 5).round
    bar = "\u{1F7E5}" * filled + "\u2B1B" * (20 - filled)
    total_dmg = (participant ? participant['total_damage'].to_i : 0) + damage

    update_cv2(event, [{
      type: 17, accent_color: 0xFF1493,
      components: [
        { type: 10, content: "## \u{1F5E1}\u{FE0F} Attack! \u2014 #{damage} damage!" },
        { type: 14, spacing: 1 },
        { type: 10, content: "You struck the **#{boss['boss_name']}** for **#{damage}** damage!#{is_sub ? " *(Premium power!)*" : ""}\n\n#{bar}\n**HP:** #{new_hp.to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\\1,')} / #{boss['max_hp'].to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\\1,')} (#{hp_pct}%)\n\n**Your Total Damage:** #{total_dmg}\n**Next Attack:** #{format_time_delta(BOSS_ATTACK_COOLDOWN)}#{mom_remark(uid, 'arcade')}" }
      ]
    }])
  end
end
