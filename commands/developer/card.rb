# ==========================================
# COMMAND: card (Developer Only)
# DESCRIPTION: Manually add, remove, or ascend character cards in a user's collection.
# CATEGORY: Developer / Gacha Management
# ==========================================

# ------------------------------------------
# LOGIC: Card Modification Execution
# ------------------------------------------
def execute_card(event, action, target_user, name_query)
  # 1. Security: Strict Developer-Only Check
  unless DEV_IDS.include?(event.user.id)
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Access Denied" },
      { type: 14, spacing: 1 },
      { type: 10, content: "This command is restricted to the Bot Developer." }
    ]}])
  end

  # 2. Validation: Ensure a target user was provided
  unless target_user
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['error']} Error" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You must mention a user to modify their collection." }
    ]}])
  end

  # 3. Search: Locate the character within the rarity pools
  # This uses the helper method to find the correct data even with partial names.
  found_data = find_character_in_pools(name_query)
  unless found_data
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['error']} Character Not Found" },
      { type: 14, spacing: 1 },
      { type: 10, content: "I couldn't find `#{name_query}` in the pools." }
    ]}])
  end

  # 4. Data Extraction: Capture the standardized name and rarity
  real_name = found_data[:char][:name]
  rarity = found_data[:rarity]
  uid = target_user.id

  # 5. Branching Logic: Handle the requested modification type
  case action.downcase
  
  # --- ADD REGULAR CARD ---
  when 'add', 'give'
    DB.add_character(uid, real_name, rarity, 1)
    send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['surprise']} Card Added" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Added **#{real_name}** to #{target_user.mention}'s collection!" }
    ]}])

  # --- REMOVE REGULAR CARD ---
  when 'remove', 'take'
    DB.remove_character(uid, real_name, 1)
    send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: [
      { type: 10, content: "## 🗑️ Card Removed" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Removed one copy of **#{real_name}** from #{target_user.mention}." }
    ]}])

  # --- GRANT ASCENDED VERSION ---
  when 'giveascended', 'addascended'
    # Direct DB execution to handle the specific 'ascended' column logic
    DB.instance_variable_get(:@db).execute(
      "INSERT INTO collections (user_id, character_name, rarity, count, ascended)
       VALUES (?, ?, ?, 0, 1)
       ON CONFLICT(user_id, character_name)
       DO UPDATE SET ascended = ascended + 1",
      [uid, real_name, rarity]
    )
    send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['neonsparkle']} Ascended Card Granted" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Successfully granted an **Ascended #{real_name}** to #{target_user.mention}!" }
    ]}])

  # --- REMOVE ASCENDED VERSION ---
  when 'takeascended', 'removeascended'
    # Logic to decrement the ascended star count without dropping below zero
    DB.instance_variable_get(:@db).execute(
      "UPDATE collections SET ascended = MAX(0, ascended - 1)
       WHERE user_id = ? AND character_name = ?",
      [uid, real_name]
    )
    send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: [
      { type: 10, content: "## ♻️ Ascended Card Removed" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Removed one #{EMOJI_STRINGS['neonsparkle']} star from #{target_user.mention}'s **#{real_name}**." }
    ]}])

  # --- FALLBACK ---
  else
    send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['error']} Invalid Action" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Use `add`, `remove`, `giveascended`, or `takeascended`." }
    ]}])
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!card)
# ------------------------------------------
$bot.command(:card,
  description: 'Manage user cards (Dev Only)',
  category: 'Developer'
) do |event, action, target, *char_name|
  if action.nil? || target.nil? || char_name.empty?
    send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['confused']} Usage" },
      { type: 14, spacing: 1 },
      { type: 10, content: "`#{PREFIX}card <action> @user <character name>`\n\n**Actions:** `add`, `remove`, `giveascended`, `takeascended`\n*Example:* `#{PREFIX}card add @user Gawr Gura`" }
    ]}])
    next
  end
  execute_card(event, action, event.message.mentions.first, char_name.join(' '))
  nil
end