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
    return send_embed(event, 
      title: "#{EMOJIS['error']} Ascension Failed", 
      description: "You don't own any copies of **#{search_name}**!"
    )
  end

  # 3. Validation: Quantity Check (Requirement: 5 Copies)
  if user_chars[owned_name]['count'] < 5
    return send_embed(event, 
      title: "#{EMOJIS['nervous']} Not Enough Copies", 
      description: "You need **5 copies** of #{owned_name} to ascend them. You only have **#{user_chars[owned_name]['count']}**."
    )
  end

  # 4. Validation: Economy Check (Requirement: 5,000 Coins)
  ascension_cost = 5000
  if DB.get_coins(uid) < ascension_cost
    return send_embed(event, 
      title: "#{EMOJIS['nervous']} Insufficient Funds", 
      description: "The ritual costs **#{ascension_cost}** #{EMOJIS['s_coin']}. You currently have **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}."
    )
  end

  # 5. Database: Deduct the ritual cost and perform the character transformation
  # Note: DB.ascend_character should handle removing the 5 copies and adding the 1 Shiny version.
  DB.add_coins(uid, -ascension_cost)
  DB.ascend_character(uid, owned_name)

  # 6. Progression: Check if this triggers the 'ascension' achievement milestone
  check_achievement(event.channel, event.user.id, 'ascension')

  # 7. UI: Send the success Embed with the "Shiny" announcement
  send_embed(event, 
    title: "#{EMOJIS['neonsparkle']} Ascension Complete! #{EMOJIS['neonsparkle']}", 
    description: "You paid **#{ascension_cost}** #{EMOJIS['s_coin']} and fused 5 copies of **#{owned_name}** together!\n\n" \
                 "They have been reborn as a **Shiny Ascended** character. View them in your `/collection`!",
    color: 0xFFD700 # Gold/Ascension theme
  )
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!ascend)
# ------------------------------------------
bot.command(:ascend, 
  description: 'Fuse 5 duplicate characters into a Shiny Ascended version!', 
  min_args: 1, 
  category: 'Gacha'
) do |event, *name_args|
  # Join all arguments to support multi-word character names
  execute_ascend(event, name_args.join(' '))
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/ascend)
# ------------------------------------------
bot.application_command(:ascend) do |event|
  # Capture the character name from the Slash option
  execute_ascend(event, event.options['character'])
end