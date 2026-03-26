# ==========================================
# COMMAND: setxp (Admin Only)
# DESCRIPTION: Unified XP/Level management. Add, remove, or set XP and levels.
# CATEGORY: Admin
# ==========================================

SETXP_USAGE = "**Usage:**\n" \
              "`setxp add @user <amount>` — Add XP\n" \
              "`setxp remove @user <amount>` — Remove XP\n" \
              "`setxp set @user <amount>` — Set total XP\n" \
              "`setxp level @user <level>` — Set level directly"

# ------------------------------------------
# LOGIC: Unified XP/Level Modification
# ------------------------------------------
def execute_setxp(event, action, target_user, amount)
  # 1. Validation: Ensure command is used in a Guild
  unless event.server
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Server Only" },
      { type: 14, spacing: 1 },
      { type: 10, content: "This only works in a server, chat." }
    ]}])
  end

  # 2. Security: Permission Check (Admins or Developer Only)
  unless event.user.permission?(:administrator, event.channel) || DEV_IDS.include?(event.user.id)
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Access Denied" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You need Admin perms for this one, chief." }
    ]}])
  end

  # 3. Validation: Action must be provided
  if action.nil?
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['confused']} How Does This Work?" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Okay, I'll spell it out for you~\n\n#{SETXP_USAGE}" }
    ]}])
  end

  # 4. Validation: Must have valid action
  unless %w[add remove set level].include?(action.downcase)
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['confused']} Invalid Action" },
      { type: 14, spacing: 1 },
      { type: 10, content: "**#{action}** isn't a thing, chat. Try `add`, `remove`, `set`, or `level`.\n\n#{SETXP_USAGE}" }
    ]}])
  end

  # 5. Validation: Ensure a target user exists
  if target_user.nil?
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['confused']} Who??" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You forgot to mention someone. I can't just add XP to the void.\n\n#{SETXP_USAGE}" }
    ]}])
  end

  # 6. Validation: Amount check
  if amount.nil? || amount == 0
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['confused']} How Much?" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Give me a number, chat. How much XP?\n\n#{SETXP_USAGE}" }
    ]}])
  end

  sid = event.server.id
  uid = target_user.id
  user = DB.get_user_xp(sid, uid)

  case action.downcase
  when 'add'
    new_xp = user['xp'] + amount.abs
    new_level = user['level']
    needed = new_level * 100
    while new_xp >= needed
      new_xp -= needed
      new_level += 1
      needed = new_level * 100
    end
    DB.update_user_xp(sid, uid, new_xp, new_level, user['last_xp_at'])
    send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['developer']} Admin Override" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Added **#{amount.abs}** XP to #{target_user.mention}.\nThey're now **Level #{new_level}** with **#{new_xp}** XP." }
    ]}])

  when 'remove'
    new_xp = user['xp'] - amount.abs
    new_level = user['level']
    while new_xp < 0 && new_level > 1
      new_level -= 1
      new_xp += new_level * 100
    end
    new_xp = [new_xp, 0].max
    DB.update_user_xp(sid, uid, new_xp, new_level, user['last_xp_at'])
    send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['developer']} Admin Override" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Removed **#{amount.abs}** XP from #{target_user.mention}.\nThey're now **Level #{new_level}** with **#{new_xp}** XP." }
    ]}])

  when 'set'
    total_xp = amount.abs
    new_level = 1
    remaining = total_xp
    needed = new_level * 100
    while remaining >= needed
      remaining -= needed
      new_level += 1
      needed = new_level * 100
    end
    DB.update_user_xp(sid, uid, remaining, new_level, user['last_xp_at'])
    send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['developer']} Admin Override" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Set #{target_user.mention}'s total XP to **#{amount.abs}**.\nThat puts them at **Level #{new_level}** with **#{remaining}** XP." }
    ]}])

  when 'level'
    new_level = [amount.abs, 1].max
    DB.update_user_xp(sid, uid, user['xp'], new_level, user['last_xp_at'])
    send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['developer']} Admin Override" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Set #{target_user.mention}'s level to **#{new_level}**. XP progress preserved." }
    ]}])
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!setxp)
# ------------------------------------------
$bot.command(:setxp,
  description: 'Manage user XP/Level — add, remove, set, or level (Admin Only)',
  category: 'Admin'
) do |event, action, mention, amount|
  target = event.message.mentions.first
  execute_setxp(event, action, target, amount.nil? ? nil : amount.to_i)
  nil
end

# ------------------------------------------
# TRIGGER: Slash Command (/setxp)
# ------------------------------------------
$bot.application_command(:setxp) do |event|
  target = event.bot.user(event.options['user'].to_i)
  execute_setxp(event, event.options['action'], target, event.options['amount'])
end
