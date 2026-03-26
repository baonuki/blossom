# ==========================================
# COMMAND: blacklist (Developer Only)
# DESCRIPTION: Toggles a user's ability to interact with the bot globally.
# CATEGORY: Developer / Security
# ==========================================

# ------------------------------------------
# LOGIC: Blacklist Execution
# ------------------------------------------
def execute_blacklist(event, target_user)
  # 1. Security: Strict Developer-Only Check
  unless DEV_IDS.include?(event.user.id)
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Permission Denied" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Only the bot developer can use this command." }
    ]}])
  end

  # 2. Validation: Ensure a target user was provided
  if target_user.nil?
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['confused']} Usage" },
      { type: 14, spacing: 1 },
      { type: 10, content: "`#{PREFIX}blacklist @user`" }
    ]}])
  end

  # 3. Safety Check: Prevent the developer from locking themselves out
  uid = target_user.id
  if DEV_IDS.include?(uid)
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Self-Blacklist Blocked" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You cannot blacklist yourself." }
    ]}])
  end

  # 4. Database: Toggle the blacklist status in the PostgreSQL 'blacklist' table
  # This returns true if they were added, or false if they were removed.
  is_now_blacklisted = DB.toggle_blacklist(uid)

  # 5. System Action & UI: Apply the change to the bot's live "ignore" list
  if is_now_blacklisted
    # Tell the discordrb client to stop processing any events from this user ID
    event.bot.ignore_user(uid)
    
    send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## 🚫 User Blacklisted" },
      { type: 14, spacing: 1 },
      { type: 10, content: "#{target_user.mention} has been added to the blacklist. I will now ignore all messages and commands from them." }
    ]}])
  else
    # Remove the user ID from the bot's internal ignore list
    event.bot.unignore_user(uid)

    send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: [
      { type: 10, content: "## ✅ User Forgiven" },
      { type: 14, spacing: 1 },
      { type: 10, content: "#{target_user.mention} has been removed from the blacklist. They are free to interact again." }
    ]}])
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!blacklist)
# ------------------------------------------
$bot.command(:blacklist,
  description: 'Toggle blacklist for a user (Dev Only)',
  category: 'Developer'
) do |event, mention|
  if mention.nil?
    send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['confused']} Usage" },
      { type: 14, spacing: 1 },
      { type: 10, content: "`#{PREFIX}blacklist @user`" }
    ]}])
    next
  end
  execute_blacklist(event, event.message.mentions.first)
  nil # Prevent double-response
end