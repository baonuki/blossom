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
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['confused']} Who??" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You don't have **#{search_name}** in your collection.\n" \
                   "Hit `/summon` to try your luck or `/buy` if you're feeling rich." }
    ]}])
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
          when 'rare'      then EMOJI_STRINGS['neonsparkle']
          else '⭐'
          end
          
  # 5. UI: Construct the description based on ownership levels
  desc = "You've got **#{count}** standard copies of this one.\n"
  if ascended > 0
    desc += "#{EMOJI_STRINGS['neonsparkle']} **Plus #{ascended} Shiny Ascended copies!! Flexing on chat rn.** #{EMOJI_STRINGS['neonsparkle']}"
  end
  # Easter egg: Envvy is Blossom's creator (mom)
  desc += "\n\n*That's my mom, by the way. Yeah, THE Envvy. She literally made me. So like... be normal about it.*" if owned_name == 'Envvy'

  # 6. Messaging: Send the finalized spotlight Embed
  send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
    { type: 10, content: "## #{emoji} #{owned_name} (#{rarity.capitalize})" },
    { type: 14, spacing: 1 },
    { type: 10, content: desc },
    { type: 14, spacing: 1 },
    { type: 12, items: [{ media: { url: char_data[:gif] } }] }
  ]}])
end

# ------------------------------------------
# TRIGGERS: Prefix & Slash Support
# ------------------------------------------
$bot.command(:view,
  description: 'Look at a specific character you own',
  category: 'Gacha'
) do |event, *name_args|
  char_name = name_args.join(' ').strip
  if char_name.empty?
    send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['confused']} View Who??" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Tell me which character you wanna see, chat.\n\n**Usage:** `#{PREFIX}view <character name>`\n*Example:* `#{PREFIX}view Envvy`" }
    ]}])
    next
  end
  execute_view(event, char_name)
  nil # Suppress default return
end

$bot.application_command(:view) do |event|
  execute_view(event, event.options['character'])
end