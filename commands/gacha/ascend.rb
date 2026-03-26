# ==========================================
# COMMAND: ascend
# DESCRIPTION: Spend duplicates and coins to upgrade a character to Shiny status.
# CATEGORY: Gacha
# ==========================================

# ------------------------------------------
# LOGIC: Character Ascension Execution
# ------------------------------------------
def execute_ascend(event, search_name)
  # 1. Initialization: Normalize the search string for database lookups
  uid = event.user.id
  search_name = search_name.downcase.strip
  user_chars = DB.get_collection(uid)
  
  # 2. Validation: Case-insensitive search to find the exact character name
  owned_name = user_chars.keys.find { |k| k.downcase == search_name }

  unless owned_name
    return send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Ascension Failed" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You don't even HAVE **#{search_name}**. Can't ascend thin air, chat." }
    ]}])
  end

  # 3. Validation: Quantity Check (Requirement: 5 Copies)
  if user_chars[owned_name]['count'] < 5
    return send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['nervous']} Not Enough Copies" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You need **5 copies** of #{owned_name} to ascend. You've got **#{user_chars[owned_name]['count']}**. Keep pulling, copium andy." }
    ]}])
  end

  # 4. Validation: Economy Check (Requirement: 5,000 Coins)
  ascension_cost = 5000
  if DB.get_coins(uid) < ascension_cost
    return send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['nervous']} Broke Alert" },
      { type: 14, spacing: 1 },
      { type: 10, content: "The ascension ritual costs **#{ascension_cost}** coins. You've got **#{DB.get_coins(uid)}**. Go farm, broke boy." }
    ]}])
  end

  # 5. Database: Deduct the ritual cost and perform the character transformation
  # Note: DB.ascend_character should handle removing the 5 copies and adding the 1 Shiny version.
  DB.add_coins(uid, -ascension_cost)
  DB.ascend_character(uid, owned_name)

  # 6. Progression: Check if this triggers the 'ascension' achievement milestone
  check_achievement(event.channel, event.user.id, 'ascension')

  # 7. UI: Send the success CV2 message with the "Shiny" announcement
  send_cv2(event, [{ type: 17, accent_color: 0xFFD700, components: [
    { type: 10, content: "## #{EMOJI_STRINGS['neonsparkle']} ASCENSION COMPLETE #{EMOJI_STRINGS['neonsparkle']}" },
    { type: 14, spacing: 1 },
    { type: 10, content: "You dropped **#{ascension_cost}** coins and sacrificed 5 copies of **#{owned_name}** to the Neon Arcade gods.\n\nThey've been reborn as a **Shiny Ascended** character. POG. Check your `/collection`!" }
  ]}])
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!ascend)
# ------------------------------------------
$bot.command(:ascend,
  description: 'Fuse 5 duplicate characters into a Shiny Ascended version!',
  category: 'Gacha'
) do |event, *name_args|
  char_name = name_args.join(' ').strip
  if char_name.empty?
    send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['confused']} Ascend Who??" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You forgot to tell me which character to ascend, chat.\n\n**Usage:** `#{PREFIX}ascend <character name>`\n*Example:* `#{PREFIX}ascend Gawr Gura`" }
    ]}])
    next
  end
  execute_ascend(event, char_name)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/ascend)
# ------------------------------------------
$bot.application_command(:ascend) do |event|
  # Capture the character name from the Slash option
  execute_ascend(event, event.options['character'])
end