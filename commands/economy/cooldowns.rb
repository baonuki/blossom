# ==========================================
# COMMAND: cooldowns
# DESCRIPTION: Displays a paginated countdown for all commands with timers.
# CATEGORY: Economy / Utility
# ==========================================

# Page definitions: [page_title, [[name, type, cooldown_or_special], ...]]
# Built dynamically per-user since cooldowns depend on premium/items

def build_cooldown_pages(uid, event)
  inv_array = DB.get_inventory(uid)
  inv = inv_array.each_with_object({}) { |item, h| h[item['item_id']] = item['quantity'] }
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
  fish_cd = is_sub ? FISH_COOLDOWN_PREMIUM : FISH_COOLDOWN

  reps_used = DB.reps_given_today(uid)
  max_reps = is_sub ? 3 : 1
  rep_status = reps_used >= max_reps ? "Maxed (#{reps_used}/#{max_reps})" : "**#{max_reps - reps_used}** left"

  streak_text = daily_info['streak'] > 0 ? "\n🔥 **Streak:** #{daily_info['streak']} Days" : ""
  reminder_text = daily_info['channel'] ? " · 🔔 Reminder ON" : ""

  [
    {
      title: '💰 Content & Income',
      fields: [
        { name: 'work', value: check_cd.call('work', work_cd) },
        { name: 'stream', value: check_cd.call('stream', stream_cd) },
        { name: 'post', value: check_cd.call('post', post_cd) },
        { name: 'summon', value: check_cd.call('summon', summon_duration) }
      ]
    },
    {
      title: '🕹️ Activities & Social',
      fields: [
        { name: 'collab', value: check_cd.call('collab', COLLAB_COOLDOWN) },
        { name: 'fish', value: check_cd.call('fish', fish_cd) },
        { name: 'spin', value: check_cd.call('spin', SPIN_COOLDOWN) },
        { name: 'rep', value: rep_status }
      ]
    },
    {
      title: '📅 Daily & Reminders',
      fields: [
        { name: 'daily', value: check_cd.call('daily', DAILY_COOLDOWN, daily_info['at']) }
      ],
      extra: "#{streak_text}#{reminder_text}"
    }
  ]
end

def render_cooldown_page(event, uid, page_num)
  pages = build_cooldown_pages(uid, event)
  page_num = page_num.clamp(0, pages.size - 1)
  page = pages[page_num]

  cd_lines = page[:fields].map { |f| "**#{f[:name]}:** #{f[:value]}" }.join("\n")
  extra = page[:extra] || ""

  inner = [
    { type: 10, content: "## #{EMOJI_STRINGS['info']} #{event.user.display_name}'s Cooldowns" },
    { type: 14, spacing: 1 },
    { type: 10, content: "#{page[:title]}#{extra}#{mom_remark(uid, 'economy')}" },
    { type: 14, spacing: 1 },
    { type: 10, content: cd_lines },
    { type: 14, spacing: 1 },
    { type: 10, content: "-# Page #{page_num + 1} / #{pages.size}" },
    { type: 14, spacing: 1 },
    { type: 1, components: [
      { type: 2, custom_id: "cd_prev_#{uid}", label: '◀', style: 2, disabled: page_num == 0 },
      { type: 2, custom_id: "cd_page_#{uid}", label: "#{page_num + 1}/#{pages.size}", style: 2, disabled: true },
      { type: 2, custom_id: "cd_next_#{uid}", label: '▶', style: 2, disabled: page_num == pages.size - 1 }
    ]}
  ]

  [{ type: 17, accent_color: NEON_COLORS.sample, components: inner }]
end

# Store current page per user
COOLDOWN_PAGES = {}

def execute_cooldowns(event)
  uid = event.user.id
  COOLDOWN_PAGES[uid] = 0
  components = render_cooldown_page(event, uid, 0)
  send_cv2(event, components)
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!cooldowns)
# ------------------------------------------
$bot.command(:cooldowns, aliases: [:cd, :timers],
  description: 'Check your active timers for economy commands',
  category: 'Economy'
) do |event|
  execute_cooldowns(event)
  nil
end

# ------------------------------------------
# TRIGGER: Slash Command (/cooldowns)
# ------------------------------------------
$bot.application_command(:cooldowns) do |event|
  execute_cooldowns(event)
end
