# ==========================================
# COMMAND: view
# DESCRIPTION: View a specific character from your collection in detail.
# CATEGORY: Gacha
# ==========================================

# ------------------------------------------
# LOGIC: Character View Execution
# ------------------------------------------
def execute_view(event, search_name)
  # 1. Initialization: Normalize search input and fetch collection
  uid = event.user.id
  search_name = search_name.strip
  user_chars = DB.get_collection(uid)
  
  # 2. Validation: Case-insensitive search to see if the user owns the character
  # We check both standard count and ascended status.
  owned_name = user_chars.keys.find { |k| k.downcase == search_name.downcase }
  
  unless owned_name && (user_chars[owned_name]['count'] > 0 || user_chars[owned_name]['ascended'].to_i > 0)
    return send_embed(event, 
      title: "#{EMOJIS['confused']} Character Not Found", 
      description: "You don't own **#{search_name}** yet!\n" \
                   "Use `/summon` to roll for them, or `/buy` to get them from the shop."
    )
  end
  
  # 3. Data Retrieval: Fetch rarity and visual assets from the global pools
  result = find_character_in_pools(owned_name)
  char_data = result[:char]
  rarity    = result[:rarity]
  count     = user_chars[owned_name]['count']
  ascended  = user_chars[owned_name]['ascended'].to_i
  
  # 4. UI: Determine the rarity-specific emoji
  emoji = case rarity
          when 'goddess'   then '💎'
          when 'legendary' then '🌟'
          when 'rare'      then '✨'
          else '⭐'
          end
          
  # 5. UI: Construct the description based on ownership levels
  desc = "You currently own **#{count}** standard copies of this character.\n"
  if ascended > 0
    desc += "#{EMOJIS['neonsparkle']} **You own #{ascended} Shiny Ascended copies!** #{EMOJIS['neonsparkle']}"
  end

  # 6. Messaging: Send the finalized spotlight Embed
  send_embed(
    event, 
    title: "#{emoji} #{owned_name} (#{rarity.capitalize})", 
    description: desc, 
    image: char_data[:gif] # Displays the character's active GIF
  )
end

# ------------------------------------------
# TRIGGERS: Prefix & Slash Support
# ------------------------------------------
bot.command(:view, 
  description: 'Look at a specific character you own', 
  min_args: 1, 
  category: 'Gacha'
) do |event, *name_args|
  # Join args to support names like "Gawr Gura"
  execute_view(event, name_args.join(' '))
  nil # Suppress default return
end

bot.application_command(:view) do |event|
  execute_view(event, event.options['character'])
end