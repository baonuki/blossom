# ==========================================
# COMMAND: blacklist (Developer Only)
# DESCRIPTION: Toggles a user's ability to interact with the bot globally.
# CATEGORY: Developer / Security
# ==========================================

# ------------------------------------------
# LOGIC: Blacklist Execution
# ------------------------------------------
def execute_blacklist(event, target_input)
  # 1. Security: Strict Developer-Only Check
  unless DEV_IDS.include?(event.user.id)
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Permission Denied" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Only the bot developer can use this command." }
    ]}])
  end

  # 2. Validation: Ensure a target was provided
  if target_input.nil? || target_input.to_s.strip.empty?
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['confused']} Usage" },
      { type: 14, spacing: 1 },
      { type: 10, content: "`#{PREFIX}blacklist @user` or `#{PREFIX}blacklist <user_id>`" }
    ]}])
  end

  # 3. Extract ID: Handles User objects, Mention strings ("<@123>"), and raw ID strings ("123")
  # Discord Snowflakes are between 15 and 21 digits.
  uid = if target_input.respond_to?(:id)
          target_input.id
        else
          target_input.to_s.scan(/\d{15,21}/).first&.to_i
        end

  # Failsafe if no valid 15-21 digit ID was found
  if uid.nil? || uid.zero?
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['confused']} Invalid Target" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Could not find a valid Discord User ID. Please provide a mention or ID." }
    ]}])
  end

  # 4. Safety Check: Prevent the developer from locking themselves out
  if DEV_IDS.include?(uid)
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Self-Blacklist Blocked" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You cannot blacklist yourself." }
    ]}])
  end

  # 5. Database: Toggle the blacklist status in the PostgreSQL 'blacklist' table
  # This returns true if they were added, or false if they were removed.
  is_now_blacklisted = DB.toggle_blacklist(uid)

  # 6. System Action & UI: Apply the change to the bot's live "ignore" list
  # Discord automatically formats <@id> into a user ping in the client!
  mention_tag = "<@#{uid}>"

  if is_now_blacklisted
    # Tell the discordrb client to stop processing any events from this user ID
    event.bot.ignore_user(uid)

    # Wipe their entire footprint — coins, prisma, collection, achievements,
    # crew membership, marriages, the lot. Counts come back per-table so we
    # can show a summary in the embed.
    purge_counts = DB.purge_user_data(uid) || {}
    total_purged = purge_counts.values.sum
    purge_summary = if total_purged.positive?
                      tables_hit = purge_counts.count { |_, n| n.positive? }
                      "\n\n**Wiped from the database:** #{total_purged} row#{total_purged == 1 ? '' : 's'} across #{tables_hit} table#{tables_hit == 1 ? '' : 's'}."
                    else
                      "\n\n*(No existing data found to wipe.)*"
                    end

    send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## 🚫 User Blacklisted" },
      { type: 14, spacing: 1 },
      { type: 10, content: "#{mention_tag} has been added to the blacklist. I will now ignore all messages and commands from them.#{purge_summary}#{mom_remark(event.user.id, 'dev')}" }
    ]}])
  else
    # Remove the user ID from the bot's internal ignore list
    event.bot.unignore_user(uid)

    send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: [
      { type: 10, content: "## ✅ User Forgiven" },
      { type: 14, spacing: 1 },
      { type: 10, content: "#{mention_tag} has been removed from the blacklist. They are free to interact again.#{mom_remark(event.user.id, 'dev')}" }
    ]}])
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!blacklist)
# ------------------------------------------
$bot.command(:blacklist, aliases: [:bl],
  description: 'Toggle blacklist for a user (Dev Only)',
  category: 'Developer'
) do |event, target_arg|
  
  if target_arg.nil? || target_arg.strip.empty?
    send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['confused']} Usage" },
      { type: 14, spacing: 1 },
      { type: 10, content: "`#{PREFIX}blacklist @user` or `#{PREFIX}blacklist <user_id>`" }
    ]}])
    next
  end

  # Pass the raw argument to the method so it can regex parse the ID out
  execute_blacklist(event, target_arg)
  nil # Prevent double-response
end