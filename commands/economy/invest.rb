# ==========================================
# COMMAND: invest / portfolio / withdraw
# DESCRIPTION: Premium-only passive income system. Invest coins for hourly returns.
# CATEGORY: Economy
# ==========================================

# ------------------------------------------
# LOGIC: Invest Coins
# ------------------------------------------
def execute_invest(event, amount_str)
  uid = event.user.id

  # Premium gate
  unless is_premium?(event.bot, uid)
    return send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['prisma']} Premium Perk" },
      { type: 14, spacing: 1 },
      { type: 10, content: "The investment portfolio is a **Blossom Premium** feature! You need a subscription to play the market, chat.\n\nCheck out `/premium` to see what you're missing." }
    ]}])
  end

  # Check for existing investment
  existing = DB.get_investment(uid)
  if existing
    value = calculate_investment_value(existing['principal'], existing['invested_at'])
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['s_coin']} Investment Portfolio" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You already have an active investment! Withdraw first before starting a new one.\n\n**Principal:** #{existing['principal']} #{EMOJI_STRINGS['s_coin']}\n**Current Value:** #{value[:total]} #{EMOJI_STRINGS['s_coin']} *(+#{value[:profit]} profit)*\n**Time Invested:** #{format_time_delta(value[:hours] * 3600)}" }
    ]}])
  end

  # Parse and validate amount
  amount = amount_str.to_s.gsub(/[,_]/, '').to_i
  if amount < INVEST_MIN
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['s_coin']} Investment Portfolio" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Minimum investment is **#{INVEST_MIN}** #{EMOJI_STRINGS['s_coin']}. You gotta have money to make money, chat." }
    ]}])
  end

  coins = DB.get_coins(uid)
  if coins < amount
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['s_coin']} Investment Portfolio" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You only have **#{coins}** #{EMOJI_STRINGS['s_coin']} — can't invest what you don't have. Massive skill issue." }
    ]}])
  end

  # Deduct coins and create investment
  DB.add_coins(uid, -amount)
  DB.create_investment(uid, amount)

  components = [{ type: 17, accent_color: 0x00FF00, components: [
    { type: 10, content: "## #{EMOJI_STRINGS['rich']} Investment Created!" },
    { type: 14, spacing: 1 },
    { type: 10, content: "Invested **#{amount}** #{EMOJI_STRINGS['s_coin']} into the Neon Arcade portfolio!\n\n**Rate:** 0.5% per hour (compounding)\n**Max Return:** 2x your investment (#{amount * 2} #{EMOJI_STRINGS['s_coin']})\n\nUse `#{PREFIX}portfolio` to check your gains or `#{PREFIX}withdraw` to cash out anytime.\n\nRemaining Balance: **#{DB.get_coins(uid)}** #{EMOJI_STRINGS['s_coin']}.#{mom_remark(uid, 'economy')}" }
  ]}]
  send_cv2(event, components)
end

# ------------------------------------------
# LOGIC: View Portfolio
# ------------------------------------------
def execute_portfolio(event)
  uid = event.user.id

  unless is_premium?(event.bot, uid)
    return send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['prisma']} Premium Perk" },
      { type: 14, spacing: 1 },
      { type: 10, content: "The investment portfolio is a **Blossom Premium** feature!\n\nCheck out `/premium` to see what you're missing." }
    ]}])
  end

  investment = DB.get_investment(uid)
  unless investment
    return send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['s_coin']} Investment Portfolio" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You don't have an active investment. Use `#{PREFIX}invest <amount>` to start growing your coins!\n\n**Rate:** 0.5% per hour (compounding)\n**Min Investment:** #{INVEST_MIN} #{EMOJI_STRINGS['s_coin']}\n**Max Return:** 2x your principal" }
    ]}])
  end

  value = calculate_investment_value(investment['principal'], investment['invested_at'])
  max_total = investment['principal'] * 2
  progress_pct = ((value[:profit].to_f / (investment['principal'] * INVEST_PROFIT_CAP)) * 100).round(1)
  progress_pct = [progress_pct, 100.0].min

  # Visual progress bar
  filled = (progress_pct / 5).round
  bar = "\u2588" * filled + "\u2591" * (20 - filled)

  capped_msg = value[:profit] >= (investment['principal'] * INVEST_PROFIT_CAP).round ? "\n\n\u{1F4B0} **MAX PROFIT REACHED!** Withdraw to claim your gains!" : ""

  components = [{ type: 17, accent_color: 0x00BFFF, components: [
    { type: 10, content: "## #{EMOJI_STRINGS['rich']} Investment Portfolio" },
    { type: 14, spacing: 1 },
    { type: 10, content: "**Principal:** #{investment['principal']} #{EMOJI_STRINGS['s_coin']}\n**Profit:** +#{value[:profit]} #{EMOJI_STRINGS['s_coin']}\n**Current Value:** #{value[:total]} #{EMOJI_STRINGS['s_coin']} / #{max_total} #{EMOJI_STRINGS['s_coin']}\n**Time Invested:** #{format_time_delta(value[:hours] * 3600)}\n\n`[#{bar}]` #{progress_pct}%#{capped_msg}#{mom_remark(uid, 'economy')}" }
  ]}]
  send_cv2(event, components)
end

# ------------------------------------------
# LOGIC: Withdraw Investment
# ------------------------------------------
def execute_withdraw(event)
  uid = event.user.id

  unless is_premium?(event.bot, uid)
    return send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['prisma']} Premium Perk" },
      { type: 14, spacing: 1 },
      { type: 10, content: "The investment portfolio is a **Blossom Premium** feature!\n\nCheck out `/premium` to see what you're missing." }
    ]}])
  end

  investment = DB.get_investment(uid)
  unless investment
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['s_coin']} Investment Portfolio" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You don't have an active investment to withdraw. Use `#{PREFIX}invest <amount>` to start one!" }
    ]}])
  end

  value = calculate_investment_value(investment['principal'], investment['invested_at'])
  DB.delete_investment(uid)
  DB.add_coins(uid, value[:total])
  check_wealth_achievements(event.channel, uid)

  components = [{ type: 17, accent_color: 0x00FF00, components: [
    { type: 10, content: "## #{EMOJI_STRINGS['coins']} Investment Withdrawn!" },
    { type: 14, spacing: 1 },
    { type: 10, content: "Cashed out your investment!\n\n**Principal:** #{value[:principal]} #{EMOJI_STRINGS['s_coin']}\n**Profit Earned:** +#{value[:profit]} #{EMOJI_STRINGS['s_coin']}\n**Total Withdrawn:** #{value[:total]} #{EMOJI_STRINGS['s_coin']}\n**Time Invested:** #{format_time_delta(value[:hours] * 3600)}\n\nNew Balance: **#{DB.get_coins(uid)}** #{EMOJI_STRINGS['s_coin']}.#{mom_remark(uid, 'economy')}" }
  ]}]
  send_cv2(event, components)
end

# ------------------------------------------
# TRIGGERS: Prefix Commands
# ------------------------------------------
$bot.command(:invest,
  description: 'Invest coins for passive returns (Premium)',
  category: 'Economy'
) do |event, amount|
  execute_invest(event, amount)
  nil
end

$bot.command(:portfolio,
  description: 'View your investment portfolio (Premium)',
  category: 'Economy'
) do |event|
  execute_portfolio(event)
  nil
end

$bot.command(:withdraw,
  description: 'Withdraw your investment (Premium)',
  category: 'Economy'
) do |event|
  execute_withdraw(event)
  nil
end

# ------------------------------------------
# TRIGGERS: Slash Commands
# ------------------------------------------
$bot.application_command(:invest) do |event|
  amount = event.options['amount']
  execute_invest(event, amount)
end

$bot.application_command(:portfolio) do |event|
  execute_portfolio(event)
end

$bot.application_command(:withdraw) do |event|
  execute_withdraw(event)
end
