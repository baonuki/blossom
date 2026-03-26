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
    return send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['error']} Invalid Target" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You gotta @ someone else, bestie. Can't gift cards to yourself, that's just sad." }
    ]}])
  end

  # 2. Validation: Input check
  if char_name.nil? || char_name.strip.empty?
    return send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['error']} Missing Character" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Give WHAT? You forgot to say which character, chat." }
    ]}])
  end

  # 3. Data Search: Find the character in the global pools
  # This ensures we get the proper case-sensitive name and rarity.
  pool_data = find_character_in_pools(char_name)
  unless pool_data
    return send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['error']} Unknown Character" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Who?? I don't know a VTuber called **#{char_name}**. Check your spelling, chat." }
    ]}])
  end

  proper_name = pool_data[:char][:name]
  rarity = pool_data[:rarity]

  # 4. Ownership Check: Verify the giver actually owns the card
  # Note: This logic only checks for unascended (base) copies.
  giver_collection = DB.get_collection(uid)
  if giver_collection[proper_name].nil? || giver_collection[proper_name]['count'] <= 0
    return send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Missing Card" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You don't have any base copies of **#{proper_name}** to give away. Can't be generous when you're broke, bestie." }
    ]}])
  end

  # 5. Database Transaction: Transfer the card
  DB.give_card(uid, target.id, proper_name, rarity)

  # 6. Achievements
  check_achievement(event.channel, uid, 'first_givecard')

  # 6. UI: Select the rarity emoji for the announcement
  emoji = case rarity
          when 'goddess'   then '💎'
          when 'legendary' then '🌟'
          when 'rare'      then EMOJI_STRINGS['neonsparkle']
          else '⭐'
          end

  # Easter egg: Envvy is Blossom's creator (mom)
  envvy_comment = proper_name == 'Envvy' ? "\n\n*Excuse me?? You're just GIVING my mom away?! #{target.mention}, you better take good care of her or we're gonna have problems.*" : ""

  # 7. Messaging: Send the success announcement CV2 message
  send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
    { type: 10, content: "## #{EMOJI_STRINGS['surprise']} Card Gifted!" },
    { type: 14, spacing: 1 },
    { type: 10, content: "#{event.user.mention} just handed over **#{proper_name}** to #{target.mention}! W friend tbh.\n\n*(Rarity: #{rarity.capitalize} #{emoji})*#{envvy_comment}" }
  ]}])
end

# ------------------------------------------
# TRIGGERS: Prefix & Slash Support
# ------------------------------------------
$bot.command(:givecard, 
  description: 'Give a VTuber card to another user', 
  category: 'Gacha'
) do |event, mention, *char_parts|
  # Join char_parts to handle multi-word names (e.g., "Strawberry Milk")
  char_name = char_parts.join(' ')
  execute_givecard(event, event.message.mentions.first, char_name)
  nil # Suppress default return
end

$bot.application_command(:givecard) do |event|
  target = event.bot.user(event.options['user'].to_i)
  char_name = event.options['character']
  execute_givecard(event, target, char_name)
end