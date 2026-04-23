# ==========================================
# COMMAND: view
# DESCRIPTION: View any character's details — owned or not.
# CATEGORY: Gacha
# ==========================================

# ------------------------------------------
# LOGIC: Character View Execution
# ------------------------------------------
def execute_view(event, search_name)
  # 1. Initialization
  uid = event.user.id
  search_name = search_name.strip

  # 2. Search: Find the character in any pool (owned or not)
  result = find_character_in_pools(search_name, include_event: true)

  unless result
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['confused']} Who??" },
      { type: 14, spacing: 1 },
      { type: 10, content: "I don't know any VTuber named **#{search_name}**. Check the spelling or try `/collection` to see who's available." }
    ]}])
  end

  char_data = result[:char]
  rarity    = result[:rarity]
  char_name = char_data[:name]

  # 3. Ownership check
  user_chars = DB.get_collection(uid)
  owned_name = user_chars.keys.find { |k| k.downcase == char_name.downcase }
  owned = owned_name && (user_chars[owned_name]['count'] > 0 || user_chars[owned_name]['ascended'].to_i > 0)

  # 4. UI: Rarity emoji
  emoji = case rarity
          when 'goddess'   then EMOJI_STRINGS['goddess']
          when 'legendary' then EMOJI_STRINGS['legendary']
          when 'rare'      then EMOJI_STRINGS['rare']
          else EMOJI_STRINGS['common']
          end

  # 5. Banner / source info
  banner_info = find_character_banner(char_name)

  # 6. Build description based on ownership
  if owned
    count    = user_chars[owned_name]['count']
    ascended = user_chars[owned_name]['ascended'].to_i

    desc = "You've got **#{count}** standard copies of this one.\n"
    if ascended > 0
      desc += "#{EMOJI_STRINGS['neonsparkle']} **Plus #{ascended} Shiny Ascended copies!! Flexing on chat rn.** #{EMOJI_STRINGS['neonsparkle']}\n"
    end

    # Rarity-based commentary
    commentary = case rarity
                 when 'goddess'
                   [
                     "A Goddess?? In YOUR collection?? Okay, maybe you ARE built different.",
                     "Literally divine and just sitting in your inventory. Wild.",
                     "Chat, this person has a GODDESS. I'm not even mad, that's impressive.",
                     "Top-tier pull secured. The gacha gods smiled on you for once."
                   ]
                 when 'legendary'
                   [
                     "Legendary pull! Not bad, not bad. You're climbing the ranks, chat.",
                     "Ooh, a Legendary. Giving main character energy fr.",
                     "Solid flex. A Legendary is nothing to sneeze at, chat.",
                     "Now THAT'S a pull worth showing off. Legendary status, baby."
                   ]
                 when 'rare'
                   [
                     "A Rare! Kinda cute, I'll give you that. Mid-tier but make it sparkle.",
                     "Rare gang! Not the flashiest, but got charm. I respect it.",
                     "Hey, Rares are the backbone of any good collection. Don't sleep on this one.",
                     "Rare enough to be interesting but common enough to not break your wallet. W."
                   ]
                 else
                   [
                     "A Common? I mean... everyone starts somewhere, right? ...Right?",
                     "Giving participation trophy energy but honestly? Icon.",
                     "Look, not every pull can be a banger. This one's here for the vibes.",
                     "Common doesn't mean boring! ...Okay sometimes it does. But not this time!"
                   ]
                 end
    desc += "\n*#{commentary.sample}*"

    # Easter egg: baonuki is Blossom's creator (mom)
    desc += "\n\n*That's my mom's past life, by the way. Yeah, THE Envvy card. Be normal about it, chat.*" if char_name == 'Envvy'
    # Easter egg: baonuki is mom's current VTuber persona
    desc += "\n\n*And baonuki? That's my mama's current VTuber persona. Absolute icon behavior.*" if char_name.downcase == 'baonuki'
    # Easter egg: Blossom is self-aware
    desc += "\n\n*Oh, you're looking at ME? Yeah I know I'm Goddess-tier, thanks for noticing. You're literally staring at the person running this entire arcade. Put some respect on it.*" if char_name == 'Blossom'
  else
    # Not owned — show where to get them
    desc = "You **don't** own this one yet.\n\n"

    if banner_info
      if banner_info[:event]
        desc += "#{EMOJI_STRINGS['surprise']} **This is a limited-time event character!**\n"
        desc += "Only available during the **#{banner_info[:banner]}** event. If you're seeing this outside of April... tough luck, chat. You missed it.\n"
      else
        desc += "**Available in:** #{banner_info[:banner]}\n"
        desc += "Try your luck with `/summon` or `/buy` them from the shop if you've got the coins.\n"
      end
    end

    # Unowned commentary
    commentary = case rarity
                 when 'goddess'
                   [
                     "A Goddess you DON'T have?? Go grind and come back. This one's worth it.",
                     "You're window shopping a Goddess. Respect the audacity, honestly.",
                     "Down BAD for a card you don't even own. Relatable tbh."
                   ]
                 when 'legendary'
                   [
                     "Legendary and not in your collection. That's a crime, chat. Go fix it.",
                     "Staring at a Legendary through the glass like a kid at a candy store. Sad.",
                     "You want this one? Then go EARN it. Summons aren't gonna roll themselves."
                   ]
                 when 'rare'
                   [
                     "A Rare you don't have? That's... actually kinda embarrassing. Go pull.",
                     "Not even a Rare?? The gacha machine is RIGHT THERE, bestie.",
                     "Mid-tier but you still don't have it. Interesting strategy."
                   ]
                 else
                   [
                     "You don't even have a COMMON?? Chat, the bar is on the floor.",
                     "It's a Common. They're EVERYWHERE. How do you not have this one??",
                     "Literally the easiest rarity to pull and you're here window shopping. Incredible."
                   ]
                 end
    desc += "\n*#{commentary.sample}*"

    # Easter egg: Blossom unowned
    desc += "\n\n*You don't have ME?? I'm literally RIGHT HERE running this whole operation and you can't even pull my card?? That's honestly embarrassing for both of us.*" if char_name == 'Blossom'
  end

  # 7. Build component list
  has_image = char_data[:gif] && char_data[:gif] =~ /\Ahttps:\/\/.+\..+\/.+/
  inner = [
    { type: 10, content: "## #{emoji} #{char_name} (#{rarity.capitalize})" },
    { type: 14, spacing: 1 },
    { type: 10, content: desc }
  ]
  if has_image
    inner << { type: 14, spacing: 1 }
    inner << { type: 12, items: [{ media: { url: char_data[:gif] } }] }
  end

  # 8. Premium-only favorite button (only if owned)
  if owned
    premium = is_premium?(event.bot, uid)
    if premium
      current_fav = DB.get_favorite_card(uid)
      is_favorited = current_fav == char_name
      fav_label = is_favorited ? 'Favorited!' : 'Set as Favorite'
      fav_style = is_favorited ? 2 : 1
      inner << { type: 14, spacing: 1 }
      inner << { type: 1, components: [
        { type: 2, custom_id: "fav_card_#{uid}_#{char_name}", label: fav_label, style: fav_style, emoji: EMOJI_OBJECTS['hearts'], disabled: is_favorited }
      ]}
    end
  end

  # 9. Mom remark
  mama_note = mom_remark(uid, 'gacha')
  inner << { type: 10, content: mama_note } if mama_note

  # 10. Messaging: Send the finalized spotlight
  send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: inner }])
end

# ------------------------------------------
# TRIGGERS: Prefix & Slash Support
# ------------------------------------------
$bot.command(:view, aliases: [:v],
  description: 'View any VTuber character in detail',
  category: 'Gacha'
) do |event, *name_args|
  char_name = name_args.join(' ').strip
  if char_name.empty?
    send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['confused']} View Who??" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Tell me which character you wanna see, chat.\n\n**Usage:** `#{PREFIX}view <character name>`\n*Example:* `#{PREFIX}view baonuki`" }
    ]}])
    next
  end
  execute_view(event, char_name)
  nil # Suppress default return
end

$bot.application_command(:view) do |event|
  execute_view(event, event.options['character'])
end

# ------------------------------------------
# AUTOCOMPLETE: Character Name Suggestions
# ------------------------------------------
$bot.autocomplete(:character, command_name: :view) do |event|
  begin
    query = (event.options['character'] || '').to_s.strip.downcase

    # Build a flat list of all character names from the universal pool + events
    all_names = []
    UNIVERSAL_POOL[:characters].each_value do |char_list|
      char_list.each { |c| all_names << c[:name] }
    end
    SPRING_CARNIVAL[:characters].each_value do |char_list|
      char_list.each { |c| all_names << c[:name] }
    end
    all_names.uniq!

    # Filter and return top 25 matches
    matches = if query.empty?
                all_names.sort.first(25)
              else
                all_names.select { |n| n.downcase.include?(query) }.first(25)
              end

    event.respond(choices: matches.map { |n| { name: n, value: n } })
  rescue => e
    puts "[AUTOCOMPLETE ERROR] #{e.message}"
    event.respond(choices: [])
  end
end
