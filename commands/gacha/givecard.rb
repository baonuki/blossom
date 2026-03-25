# ==========================================
# COMMAND: givecard
# DESCRIPTION: Transfer a VTuber card to another user.
# CATEGORY: Gacha
# ==========================================

# ------------------------------------------
# LOGIC: Card Transfer Execution
# ------------------------------------------
def execute_givecard(event, target, char_name)
  uid = event.user.id

  # 1. Validation: Target check
  # Prevents giving cards to yourself or trying to gift "nobody."
  if target.nil? || target.id == uid
    return send_embed(event, 
      title: "⚠️ Invalid Target", 
      description: "You need to mention another user to give a card to!"
    )
  end

  # 2. Validation: Input check
  if char_name.nil? || char_name.strip.empty?
    return send_embed(event, 
      title: "⚠️ Missing Character", 
      description: "Please specify the character you want to give."
    )
  end

  # 3. Data Search: Find the character in the global pools
  # This ensures we get the proper case-sensitive name and rarity.
  pool_data = find_character_in_pools(char_name)
  unless pool_data
    return send_embed(event, 
      title: "⚠️ Unknown Character", 
      description: "I couldn't find a character named **#{char_name}** in the pools."
    )
  end

  proper_name = pool_data[:char][:name]
  rarity = pool_data[:rarity]

  # 4. Ownership Check: Verify the giver actually owns the card
  # Note: This logic only checks for unascended (base) copies.
  giver_collection = DB.get_collection(uid)
  if giver_collection[proper_name].nil? || giver_collection[proper_name]['count'] <= 0
    return send_embed(event, 
      title: "❌ Missing Card", 
      description: "You don't own any unascended copies of **#{proper_name}** to give away!"
    )
  end

  # 5. Database Transaction: Transfer the card
  # This should decrement the giver's count and increment the receiver's.
  DB.give_card(uid, target.id, proper_name, rarity)

  # 6. UI: Select the rarity emoji for the announcement
  emoji = case rarity
          when 'goddess'   then '💎'
          when 'legendary' then '🌟'
          when 'rare'      then '✨'
          else '⭐'
          end

  # 7. Messaging: Send the success announcement Embed
  send_embed(
    event,
    title: "🎁 Card Transferred!",
    description: "#{event.user.mention} generously gave **#{proper_name}** to #{target.mention}! 🌸\n\n" \
                 "*(Rarity: #{rarity.capitalize} #{emoji})*"
  )
end

# ------------------------------------------
# TRIGGERS: Prefix & Slash Support
# ------------------------------------------
bot.command(:givecard, 
  description: 'Give a VTuber card to another user', 
  category: 'Gacha'
) do |event, mention, *char_parts|
  # Join char_parts to handle multi-word names (e.g., "Strawberry Milk")
  char_name = char_parts.join(' ')
  execute_givecard(event, event.message.mentions.first, char_name)
  nil # Suppress default return
end

bot.application_command(:givecard) do |event|
  target = event.bot.user(event.options['user'].to_i)
  char_name = event.options['character']
  execute_givecard(event, target, char_name)
end