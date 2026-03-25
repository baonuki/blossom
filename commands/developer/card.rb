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
  unless event.user.id == DEV_ID
    return send_embed(event, 
      title: "❌ Access Denied", 
      description: "This command is restricted to the Bot Developer."
    )
  end

  # 2. Validation: Ensure a target user was provided
  unless target_user
    return send_embed(event, 
      title: "⚠️ Error", 
      description: "You must mention a user to modify their collection."
    )
  end

  # 3. Search: Locate the character within the rarity pools
  # This uses the helper method to find the correct data even with partial names.
  found_data = find_character_in_pools(name_query)
  unless found_data
    return send_embed(event, 
      title: "⚠️ Character Not Found", 
      description: "I couldn't find `#{name_query}` in the pools."
    )
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
    send_embed(event, 
      title: "🎁 Card Added", 
      description: "Added **#{real_name}** to #{target_user.mention}'s collection!"
    )

  # --- REMOVE REGULAR CARD ---
  when 'remove', 'take'
    DB.remove_character(uid, real_name, 1)
    send_embed(event, 
      title: "🗑️ Card Removed", 
      description: "Removed one copy of **#{real_name}** from #{target_user.mention}."
    )

  # --- GRANT ASCENDED VERSION ---
  when 'giveascended', 'give✨', 'addascended'
    # Direct DB execution to handle the specific 'ascended' column logic
    DB.instance_variable_get(:@db).execute(
      "INSERT INTO collections (user_id, character_name, rarity, count, ascended) 
       VALUES (?, ?, ?, 0, 1) 
       ON CONFLICT(user_id, character_name) 
       DO UPDATE SET ascended = ascended + 1", 
      [uid, real_name, rarity]
    )
    send_embed(event, 
      title: "✨ Ascended Card Granted", 
      description: "Successfully granted an **Ascended #{real_name}** to #{target_user.mention}!"
    )

  # --- REMOVE ASCENDED VERSION ---
  when 'takeascended', 'take✨', 'removeascended'
    # Logic to decrement the ascended star count without dropping below zero
    DB.instance_variable_get(:@db).execute(
      "UPDATE collections SET ascended = MAX(0, ascended - 1) 
       WHERE user_id = ? AND character_name = ?", 
      [uid, real_name]
    )
    send_embed(event, 
      title: "♻️ Ascended Card Removed", 
      description: "Removed one ✨ star from #{target_user.mention}'s **#{real_name}**."
    )

  # --- FALLBACK ---
  else
    send_embed(event, 
      title: "⚠️ Invalid Action", 
      description: "Use `add`, `remove`, `giveascended`, or `takeascended`."
    )
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!card)
# ------------------------------------------
bot.command(:card, 
  min_args: 3, 
  description: 'Manage user cards (Dev Only)', 
  usage: '!card <add/remove/giveascended/takeascended> @user <Character Name>'
) do |event, action, target, *char_name|
  # Join character name array to handle names with spaces (e.g. "Raiden Shogun")
  execute_card(event, action, event.message.mentions.first, char_name.join(' '))
  nil
end

# ------------------------------------------
# TRIGGER: Slash Command (/card)
# ------------------------------------------
bot.application_command(:card) do |event|
  # Fetch target user object and pass the Slash options to the executor
  target = event.bot.user(event.options['user'].to_i)
  execute_card(event, event.options['action'], target, event.options['character'])
end