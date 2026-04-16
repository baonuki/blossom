# ==========================================
# COMMAND: boss / bosssetup
# DESCRIPTION: Monthly boss battle with global HP. All participants earn Prisma on defeat.
# CATEGORY: Arcade / Admin
# ==========================================

require 'date'

def get_or_create_boss
  now = Time.now
  boss = DB.get_current_boss(now.month, now.year)
  return boss if boss

  # Spawn a new boss for this month
  name = BOSS_NAMES.sample
  boss_id = DB.create_boss(name, BOSS_HP, now.month, now.year)
  DB.get_current_boss(now.month, now.year)
end

def execute_boss(event)
  boss = get_or_create_boss
  uid = event.user.id
  is_sub = is_premium?(event.bot, uid)

  # HP bar
  hp_pct = (boss['current_hp'].to_f / boss['max_hp'] * 100).round(1)
  filled = (hp_pct / 5).round
  bar = "\u{1F7E5}" * filled + "\u2B1B" * (20 - filled)

  # Player's participation
  participant = DB.get_boss_participant(boss['id'], uid)
  player_info = if participant
    last_atk = Time.parse(participant['last_attack'].to_s)
    cooldown_left = BOSS_ATTACK_COOLDOWN - (Time.now - last_atk)
    cd_text = cooldown_left > 0 ? "Cooldown: **#{format_time_delta(cooldown_left)}**" : "\u2705 Ready to attack!"
    "**Your Damage:** #{participant['total_damage']} | #{cd_text}"
  else
    "\u2705 Ready to attack!"
  end

  if boss['defeated']
    components = [{ type: 17, accent_color: 0x00FF00, components: [
      { type: 10, content: "## \u{1F480} #{boss['boss_name']} \u2014 DEFEATED!" },
      { type: 14, spacing: 1 },
      { type: 10, content: "The **#{boss['boss_name']}** has been vanquished! All participants earned **#{BOSS_DEFEAT_PRISMA}** #{EMOJI_STRINGS['prisma']}!\n\nA new boss will appear next month." },
      { type: 14, spacing: 1 },
      { type: 10, content: player_info }
    ]}]
    return send_cv2(event, components)
  end

  # Participant count
  participants = DB.get_boss_participants(boss['id'])
  total_participants = participants.size

  components = [{
    type: 17, accent_color: 0xFF1493,
    components: [
      { type: 10, content: "## \u{1F409} Boss Battle: #{boss['boss_name']}" },
      { type: 14, spacing: 1 },
      { type: 10, content: "#{bar}\n**HP:** #{boss['current_hp'].to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\\1,')} / #{boss['max_hp'].to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\\1,')} (#{hp_pct}%)" },
      { type: 14, spacing: 1 },
      { type: 10, content: "\u{1F5E1}\u{FE0F} **Fighters:** #{total_participants} | **Reward:** #{BOSS_DEFEAT_PRISMA} #{EMOJI_STRINGS['prisma']} on defeat\n**Damage:** #{is_sub ? "100-400 (Premium)" : "50-200"} per attack | **Cooldown:** 1 hour\n\n#{player_info}#{mom_remark(uid, 'arcade')}" },
      { type: 14, spacing: 1 },
      { type: 1, components: [
        { type: 2, style: 4, label: "\u2694\uFE0F Attack!", custom_id: "boss_attack_#{boss['id']}_#{uid}" }
      ]}
    ]
  }]
  send_cv2(event, components)
end

# ------------------------------------------
# ADMIN: Boss Channel Setup
# ------------------------------------------
def execute_bosssetup(event, channel_id)
  unless event.user.permission?(:administrator, event.channel) || DEV_IDS.include?(event.user.id)
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Access Denied" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You need Admin perms to configure boss battles." }
    ]}])
  end

  if channel_id.nil? || channel_id == 0
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['confused']} Which Channel?" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Tag a channel for boss battle announcements.\n`#{PREFIX}bosssetup #channel`" }
    ]}])
  end

  DB.set_boss_channel(event.server.id, channel_id)

  send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: [
    { type: 10, content: "## \u{1F409} Boss Battle Channel Set!" },
    { type: 14, spacing: 1 },
    { type: 10, content: "Boss defeat announcements will be posted to <##{channel_id}>.\n\nUse `#{PREFIX}boss` to view the current boss and attack!#{mom_remark(event.user.id, 'admin')}" }
  ]}])
end

# ------------------------------------------
# TRIGGERS
# ------------------------------------------
$bot.command(:boss,
  description: 'View and attack the monthly boss!',
  category: 'Arcade'
) do |event|
  execute_boss(event)
  nil
end

$bot.application_command(:boss) do |event|
  execute_boss(event)
end

$bot.command(:bosssetup,
  description: 'Set boss announcement channel (Admin Only)',
  category: 'Admin'
) do |event, channel_mention|
  channel_id = channel_mention ? channel_mention.gsub(/[<#>]/, '').to_i : nil
  execute_bosssetup(event, channel_id)
  nil
end

$bot.application_command(:bosssetup) do |event|
  channel_id = event.options['channel'] ? event.options['channel'].to_i : nil
  execute_bosssetup(event, channel_id)
end
