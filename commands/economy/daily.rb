# ==========================================
# COMMAND: daily
# DESCRIPTION: Claim daily rewards with a visual monthly login calendar.
# CATEGORY: Economy
# ==========================================

require 'date'

# ------------------------------------------
# HELPER: Render Monthly Calendar Grid
# ------------------------------------------
def render_calendar(year, month, claimed_days, today_day)
  month_name = Date::MONTHNAMES[month]
  first_day = Date.new(year, month, 1)
  days_in_month = Date.new(year, month, -1).day
  # Monday = 0, Sunday = 6 (ISO week)
  start_offset = first_day.cwday - 1

  header = "#{month_name} #{year}"
  grid = "```\n#{header.center(27)}\nMo  Tu  We  Th  Fr  Sa  Su\n"

  # Leading blanks
  grid += "    " * start_offset

  (1..days_in_month).each do |day|
    if claimed_days.include?(day)
      cell = " \u2588\u2588" # Filled block = claimed
    elsif day == today_day
      cell = " \u25B6\u25B6" # Arrow = today (claimable)
    elsif day < today_day
      cell = " \u00B7\u00B7" # Dot = missed
    else
      cell = "  --" # Dash = future
    end
    grid += cell

    col = (start_offset + day) % 7
    grid += "\n" if col == 0 && day < days_in_month
  end

  grid += "\n```"
  grid
end

# ------------------------------------------
# LOGIC: Daily Reward Execution
# ------------------------------------------
def execute_daily(event)
  uid = event.user.id
  now = Time.now
  today = Date.today
  is_sub = is_premium?(event.bot, uid)
  bonus_text = ""

  # Fetch current daily info (streak, last claim time)
  daily_info = DB.get_daily_info(uid)
  last_used = daily_info['at'] ? Time.parse(daily_info['at'].to_s) : nil
  current_streak = daily_info['streak'].to_i

  # Cooldown check (24-hour gate)
  if last_used && (now - last_used) < DAILY_COOLDOWN
    remaining = DAILY_COOLDOWN - (now - last_used)

    # Show calendar even on cooldown
    claimed_days = DB.get_calendar_claims(uid, today.year, today.month)
    claim_count = claimed_days.size
    calendar_grid = render_calendar(today.year, today.month, claimed_days, today.day)

    # Milestone progress
    m14 = [claim_count, CALENDAR_MILESTONE_14].min
    m28 = [claim_count, CALENDAR_MILESTONE_28].min
    milestone_text = "**Milestones:** #{m14}/#{CALENDAR_MILESTONE_14} (\u2605 Bonus) \u2502 #{m28}/#{CALENDAR_MILESTONE_28} (\u2605\u2605 Mega Bonus)"

    components = [{
      type: 17, accent_color: 0xFF0000,
      components: [
        { type: 10, content: "## #{EMOJI_STRINGS['s_coin']} Daily Login Calendar" },
        { type: 14, spacing: 1 },
        { type: 10, content: "You already grabbed your bag today, chill! Come back in **#{format_time_delta(remaining)}**." },
        { type: 14, spacing: 1 },
        { type: 10, content: calendar_grid },
        { type: 10, content: milestone_text }
      ]
    }]
    return send_cv2(event, components)
  end

  # Streak calculation (reset if > 48 hours since last claim)
  if last_used.nil? || (now - last_used) > (DAILY_COOLDOWN * 2)
    new_streak = 1
    streak_msg = "*(Streak gone, skill issue. Claim within 48h next time!)*"
  else
    new_streak = current_streak + 1
    streak_msg = "\u{1F525} **Streak:** #{new_streak} days!"
  end

  # Base reward + streak bonus
  reward = DAILY_REWARD + (new_streak * DAILY_STREAK_BONUS)

  # Premium & Prisma rewards
  if is_sub
    base_prisma = rand(1..3)
    streak_multiplier = 1 + (new_streak / 7)
    prisma_reward = base_prisma * streak_multiplier
    DB.add_prisma(uid, prisma_reward)
    bonus_text += "\n*(#{EMOJI_STRINGS['prisma']} Subscriber Bonus: +10% Coins & +#{prisma_reward} Prisma!)*"
  end

  # Marriage bonus
  marriage = DB.get_marriage(uid)
  if marriage
    reward += MARRIAGE_DAILY_BONUS
    bonus_text += "\n*(#{EMOJI_STRINGS['rainbowheart']} Marriage Bonus: +#{MARRIAGE_DAILY_BONUS} coins!)*"
  end

  # Happy hour indicator
  if happy_hour_active?
    hh_mult = is_sub ? "3x" : "2x"
    bonus_text += "\n*(#{EMOJI_STRINGS['neonsparkle']} HAPPY HOUR: #{hh_mult} Coin Boost Active!)*"
  end

  # Inventory boosts (Neon Sign = x2)
  inv_array = DB.get_inventory(uid)
  inv = inv_array.each_with_object({}) { |item, h| h[item['item_id']] = item['quantity'] }
  if inv['neon sign'] && inv['neon sign'] > 0
    reward *= 2
    bonus_text += "\n*(#{EMOJI_STRINGS['neonsparkle']} Neon Sign Boost: x2 Payout!)*"
  end

  # Grant coins & update DB
  final_reward = award_coins(event.bot, uid, reward)
  DB.update_daily_claim(uid, new_streak, now)
  DB.add_calendar_claim(uid, today)

  # Calendar data for this month
  claimed_days = DB.get_calendar_claims(uid, today.year, today.month)
  claim_count = claimed_days.size
  calendar_grid = render_calendar(today.year, today.month, claimed_days, today.day)

  # Milestone checks & rewards
  milestone_msg = ""
  if claim_count == CALENDAR_MILESTONE_14
    milestone_bonus = is_sub ? CALENDAR_MILESTONE_14_PREMIUM : CALENDAR_MILESTONE_14_REWARD
    award_coins(event.bot, uid, milestone_bonus)
    milestone_msg += "\n\n\u2B50 **14-Day Milestone!** Bonus: **+#{milestone_bonus}** #{EMOJI_STRINGS['s_coin']}!"
  end
  if claim_count == CALENDAR_MILESTONE_28
    milestone_bonus = is_sub ? CALENDAR_MILESTONE_28_PREMIUM : CALENDAR_MILESTONE_28_REWARD
    award_coins(event.bot, uid, milestone_bonus)
    milestone_msg += "\n\n\u{1F31F} **28-Day Milestone!** Bonus: **+#{milestone_bonus}** #{EMOJI_STRINGS['s_coin']}!"
    if is_sub
      DB.add_prisma(uid, CALENDAR_MILESTONE_28_PRISMA)
      milestone_msg += " *(+#{CALENDAR_MILESTONE_28_PRISMA} #{EMOJI_STRINGS['prisma']}!)*"
    end
  end

  # Milestone progress bar
  m14 = [claim_count, CALENDAR_MILESTONE_14].min
  m28 = [claim_count, CALENDAR_MILESTONE_28].min
  milestone_progress = "**Milestones:** #{m14}/#{CALENDAR_MILESTONE_14} (\u2605 Bonus) \u2502 #{m28}/#{CALENDAR_MILESTONE_28} (\u2605\u2605 Mega Bonus)"

  # Achievement checks
  check_achievement(event.channel, uid, 'streak_7')   if new_streak == 7
  check_achievement(event.channel, uid, 'streak_30')  if new_streak == 30
  check_achievement(event.channel, uid, 'streak_69')  if new_streak == 69
  check_achievement(event.channel, uid, 'streak_100') if new_streak == 100
  check_achievement(event.channel, uid, 'streak_365') if new_streak == 365
  check_wealth_achievements(event.channel, uid)
  track_challenge(uid, 'daily_claims', 1)

  # Build response
  components = [{
    type: 17, accent_color: 0x00FF00,
    components: [
      { type: 10, content: "## #{EMOJI_STRINGS['checkmark']} Daily Login Calendar" },
      { type: 14, spacing: 1 },
      { type: 10, content: "GG, chat! You snagged **#{final_reward}** #{EMOJI_STRINGS['s_coin']}!\n#{streak_msg}#{bonus_text}" },
      { type: 14, spacing: 1 },
      { type: 10, content: calendar_grid },
      { type: 10, content: "#{milestone_progress}#{milestone_msg}" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Balance: **#{DB.get_coins(uid)}** #{EMOJI_STRINGS['s_coin']}.#{mom_remark(uid, 'economy')}" }
    ]
  }]
  send_cv2(event, components)
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!daily)
# ------------------------------------------
$bot.command(:daily, aliases: [:d],
  description: 'Claim your daily coin reward',
  category: 'Economy'
) do |event|
  execute_daily(event)
  nil
end

# ------------------------------------------
# TRIGGER: Slash Command (/daily)
# ------------------------------------------
$bot.application_command(:daily) do |event|
  execute_daily(event)
end
