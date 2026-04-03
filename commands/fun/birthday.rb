# ==========================================
# COMMAND: birthday
# DESCRIPTION: Set your birthday for special rewards on your day!
# CATEGORY: Fun
# ==========================================

BIRTHDAY_REWARD = 1000

def execute_birthday(event, action, date_str)
  uid = event.user.id

  if action.nil? || action.downcase == 'view'
    bday = DB.get_birthday(uid)
    if bday
      month, day = bday.split('-').map(&:to_i)
      return send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
        { type: 10, content: "## 🎂 Your Birthday" },
        { type: 14, spacing: 1 },
        { type: 10, content: "Your birthday is set to **#{Date::MONTHNAMES[month]} #{day}**.\nYou'll get **#{BIRTHDAY_REWARD}** #{EMOJI_STRINGS['s_coin']} and a shoutout when it comes around!" }
      ]}])
    else
      return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## 🎂 Birthday" },
        { type: 14, spacing: 1 },
        { type: 10, content: "You haven't set your birthday yet!\n`#{PREFIX}birthday set MM/DD`" }
      ]}])
    end
  end

  if action.downcase == 'set'
    unless date_str && date_str.match?(%r{\A\d{1,2}/\d{1,2}\z})
      return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} Invalid Format" },
        { type: 14, spacing: 1 },
        { type: 10, content: "Use `MM/DD` format. Like `03/15` for March 15th." }
      ]}])
    end

    month, day = date_str.split('/').map(&:to_i)
    unless (1..12).include?(month) && (1..31).include?(day)
      return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} Invalid Date" },
        { type: 14, spacing: 1 },
        { type: 10, content: "That's not a real date. Month 1-12, day 1-31." }
      ]}])
    end

    # Check if they already have one set (can only set once)
    existing = DB.get_birthday(uid)
    if existing
      return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} Already Set" },
        { type: 14, spacing: 1 },
        { type: 10, content: "Your birthday is already set. No takebacks, no cap." }
      ]}])
    end

    mmdd = format('%02d-%02d', month, day)
    DB.set_birthday(uid, mmdd)

    send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: [
      { type: 10, content: "## 🎂 Birthday Set!" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Your birthday is now **#{Date::MONTHNAMES[month]} #{day}**! #{EMOJI_STRINGS['neonsparkle']}\nOn your special day you'll get **#{BIRTHDAY_REWARD}** #{EMOJI_STRINGS['s_coin']} and a shoutout!" }
    ]}])
  end
end

# ------------------------------------------
# TRIGGERS
# ------------------------------------------
$bot.command(:birthday, aliases: [:bday],
  description: 'Set or view your birthday!',
  category: 'Fun'
) do |event, action, date_str|
  execute_birthday(event, action, date_str)
  nil
end

$bot.application_command(:birthday) do |event|
  action = event.options['date'] ? 'set' : 'view'
  execute_birthday(event, action, event.options['date'])
end
