# ==========================================
# COMMAND: profile
# DESCRIPTION: Premium profile customization — color, bio, favorites.
# CATEGORY: Utility
# ==========================================

def format_fav_line(name)
  result = find_character_in_pools(name)
  return nil unless result
  emoji = case result[:rarity]
          when 'goddess'   then EMOJI_STRINGS['goddess']
          when 'legendary' then EMOJI_STRINGS['legendary']
          when 'rare'      then EMOJI_STRINGS['rare']
          else EMOJI_STRINGS['common']
          end
  "#{emoji} #{name}"
end

def execute_profile(event, action, args)
  uid = event.user.id
  is_sub = is_premium?(event.bot, uid)

  unless is_sub
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['prisma']} Premium Only" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Profile customization is a **Blossom Premium** perk! Subscribe to flex on the peasants." }
    ]}])
  end

  profile = DB.get_profile(uid)
  cosmetics = DB.get_cosmetics(uid)

  # No args = show current profile settings
  if action.nil?
    color_display = profile['color'] ? "`##{profile['color']}`" : "*Not set (random neon)*"
    bio_display = profile['bio'] && !profile['bio'].empty? ? profile['bio'] : "*Not set*"
    favs = profile['favorites']
    fav_display = favs.empty? ? "*None set*" : favs.each_with_index.map { |f, i| "**#{i + 1}.** #{format_fav_line(f) || f}" }.join("\n")

    pet_display = cosmetics['pet'] && PETS[cosmetics['pet']] ? "#{PETS[cosmetics['pet']][:emoji]} #{PETS[cosmetics['pet']][:name]}" : "*None*"
    title_display = cosmetics['title'] && TITLES[cosmetics['title']] ? "**#{TITLES[cosmetics['title']][:name]}**" : "*None*"
    theme_display = COLLECTION_THEMES[cosmetics['theme']] ? COLLECTION_THEMES[cosmetics['theme']][:name] : "Default"
    badge_display = cosmetics['badge'] && BADGES[cosmetics['badge']] ? "#{BADGES[cosmetics['badge']][:emoji]} #{BADGES[cosmetics['badge']][:name]}" : "*None*"

    return send_cv2(event, [{ type: 17, accent_color: profile['color'] ? profile['color'].to_i(16) : NEON_COLORS.sample, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['neonsparkle']} Profile Settings" },
      { type: 14, spacing: 1 },
      { type: 10, content: "🎨 **Color:** #{color_display}\n📝 **Bio:** #{bio_display}\n#{EMOJI_STRINGS['hearts']} **Favorites:**\n#{fav_display}" },
      { type: 14, spacing: 1 },
      { type: 10, content: "🐾 **Pet:** #{pet_display}\n🏷️ **Title:** #{title_display}\n🎨 **Theme:** #{theme_display}\n🏅 **Badge:** #{badge_display}" },
      { type: 14, spacing: 1 },
      { type: 10, content: "-# `#{PREFIX}profile color/bio/fav/unfav/pet/title/theme/badge/reset`\n-# `#{PREFIX}profile shop` to browse cosmetics" }
    ]}])
  end

  case action.downcase
  when 'color'
    hex = args.first&.delete('#')&.strip
    unless hex && hex.match?(/\A[0-9a-fA-F]{6}\z/)
      return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} Invalid Color" },
        { type: 14, spacing: 1 },
        { type: 10, content: "I need a valid 6-digit hex code, chat. Like `#FF00AA` or `#7B2FBE`." }
      ]}])
    end

    DB.set_profile_color(uid, hex.upcase)
    send_cv2(event, [{ type: 17, accent_color: hex.to_i(16), components: [
      { type: 10, content: "## 🎨 Color Updated!" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Your profile color is now `##{hex.upcase}`. Looking fresh~" }
    ]}])

  when 'bio'
    text = args.join(' ').strip
    if text.empty?
      return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} Missing Bio" },
        { type: 14, spacing: 1 },
        { type: 10, content: "You gotta actually write something. `#{PREFIX}profile bio <your bio here>`" }
      ]}])
    end

    if text.length > 100
      return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} Too Long" },
        { type: 14, spacing: 1 },
        { type: 10, content: "Max 100 characters, bestie. You wrote #{text.length}. Less is more." }
      ]}])
    end

    DB.set_profile_bio(uid, text)
    send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: [
      { type: 10, content: "## 📝 Bio Updated!" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Your bio is now: *\"#{text}\"*" }
    ]}])

  when 'fav'
    slot = args[0]&.to_i
    name = args[1..].join(' ').strip if args.length > 1

    unless slot && (1..3).include?(slot) && name && !name.empty?
      return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} Usage" },
        { type: 14, spacing: 1 },
        { type: 10, content: "`#{PREFIX}profile fav <1/2/3> <character name>`\nSlot 1 is available to all premium users. Slots 2 and 3 let you flex harder." }
      ]}])
    end

    # Verify they own the card
    collection = DB.get_collection(uid)
    owned = collection.keys.find { |k| k.downcase == name.downcase }
    unless owned
      return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} Not Found" },
        { type: 14, spacing: 1 },
        { type: 10, content: "You don't own a card called **#{name}**. Check your collection!" }
      ]}])
    end

    DB.set_favorite_card_slot(uid, slot, owned)
    fav_display = format_fav_line(owned) || owned
    send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['hearts']} Favorite Set!" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Slot **##{slot}** is now #{fav_display}. Looking good on your profile~" }
    ]}])

  when 'unfav'
    slot = args[0]&.to_i
    unless slot && (1..3).include?(slot)
      return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} Usage" },
        { type: 14, spacing: 1 },
        { type: 10, content: "`#{PREFIX}profile unfav <1/2/3>`" }
      ]}])
    end

    DB.clear_favorite_slot(uid, slot)
    send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['checkmark']} Favorite Cleared" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Slot **##{slot}** is now empty." }
    ]}])

  when 'pet'
    pet_id = args.first&.downcase
    if pet_id.nil?
      list = PETS.map { |id, p| "#{p[:emoji]} **#{p[:name]}** — #{p[:price]} #{EMOJI_STRINGS['prisma']} (`#{id}`)" }.join("\n")
      return send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
        { type: 10, content: "## 🐾 Available Pets" },
        { type: 14, spacing: 1 },
        { type: 10, content: "#{list}\n\n`#{PREFIX}profile pet <id>` to equip · `#{PREFIX}profile pet none` to unequip" }
      ]}])
    end

    if pet_id == 'none'
      DB.set_pet(uid, nil)
      return send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['checkmark']} Pet Removed" },
        { type: 14, spacing: 1 },
        { type: 10, content: "Your companion has been dismissed. They'll miss you." }
      ]}])
    end

    unless PETS.key?(pet_id)
      return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} Unknown Pet" },
        { type: 14, spacing: 1 },
        { type: 10, content: "That pet doesn't exist. Use `#{PREFIX}profile pet` to see the list." }
      ]}])
    end

    pet = PETS[pet_id]
    prisma = DB.get_prisma(uid)
    # Check if already owned (already equipped or re-equipping is free)
    current = cosmetics['pet']
    if current != pet_id && prisma < pet[:price]
      return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} Not Enough Prisma" },
        { type: 14, spacing: 1 },
        { type: 10, content: "**#{pet[:name]}** costs **#{pet[:price]}** #{EMOJI_STRINGS['prisma']}. You have **#{prisma}**." }
      ]}])
    end

    DB.add_prisma(uid, -pet[:price]) unless current == pet_id
    DB.set_pet(uid, pet_id)
    send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: [
      { type: 10, content: "## #{pet[:emoji]} #{pet[:name]} Equipped!" },
      { type: 14, spacing: 1 },
      { type: 10, content: "#{pet[:idle]}\n\nYour new companion will appear in your commands!#{"" if current == pet_id}#{current != pet_id ? "\n-#{pet[:price]} #{EMOJI_STRINGS['prisma']}" : ''}" }
    ]}])

  when 'title'
    title_id = args.first&.downcase
    if title_id.nil?
      list = TITLES.reject { |_, t| t[:dev_only] }.map { |id, t| "**#{t[:name]}** — #{t[:price]} #{EMOJI_STRINGS['prisma']} (`#{id}`)" }.join("\n")
      return send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
        { type: 10, content: "## 🏷️ Available Titles" },
        { type: 14, spacing: 1 },
        { type: 10, content: "#{list}\n\n`#{PREFIX}profile title <id>` to equip · `#{PREFIX}profile title none` to unequip" }
      ]}])
    end

    if title_id == 'none'
      DB.set_title(uid, nil)
      return send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['checkmark']} Title Removed" },
        { type: 14, spacing: 1 },
        { type: 10, content: "Back to being a nobody. Just kidding. Mostly." }
      ]}])
    end

    unless TITLES.key?(title_id)
      return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} Unknown Title" },
        { type: 14, spacing: 1 },
        { type: 10, content: "That title doesn't exist. Use `#{PREFIX}profile title` to see the list." }
      ]}])
    end

    title = TITLES[title_id]
    if title[:dev_only] && !DEV_IDS.include?(uid)
      return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} Developer Exclusive" },
        { type: 14, spacing: 1 },
        { type: 10, content: "That title is reserved for Bot Developers only." }
      ]}])
    end

    prisma = DB.get_prisma(uid)
    current = cosmetics['title']
    if current != title_id && prisma < title[:price]
      return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} Not Enough Prisma" },
        { type: 14, spacing: 1 },
        { type: 10, content: "**#{title[:name]}** costs **#{title[:price]}** #{EMOJI_STRINGS['prisma']}. You have **#{prisma}**." }
      ]}])
    end

    DB.add_prisma(uid, -title[:price]) unless current == title_id
    DB.set_title(uid, title_id)
    send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: [
      { type: 10, content: "## 🏷️ Title Equipped!" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You are now **#{title[:name]}**. It suits you.#{current != title_id ? "\n-#{title[:price]} #{EMOJI_STRINGS['prisma']}" : ''}" }
    ]}])

  when 'theme'
    theme_id = args.first&.downcase
    if theme_id.nil?
      list = COLLECTION_THEMES.map { |id, t| "#{t[:bullet]}#{t[:prefix]}#{t[:name]}#{t[:suffix]}#{t[:price] > 0 ? " — #{t[:price]} #{EMOJI_STRINGS['prisma']}" : ' (Free)'} (`#{id}`)" }.join("\n")
      return send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
        { type: 10, content: "## 🎨 Collection Themes" },
        { type: 14, spacing: 1 },
        { type: 10, content: "#{list}\n\n`#{PREFIX}profile theme <id>` to apply" }
      ]}])
    end

    unless COLLECTION_THEMES.key?(theme_id)
      return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} Unknown Theme" },
        { type: 14, spacing: 1 },
        { type: 10, content: "That theme doesn't exist. Use `#{PREFIX}profile theme` to see the list." }
      ]}])
    end

    theme = COLLECTION_THEMES[theme_id]
    prisma = DB.get_prisma(uid)
    current = cosmetics['theme']
    if current != theme_id && theme[:price] > 0 && prisma < theme[:price]
      return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} Not Enough Prisma" },
        { type: 14, spacing: 1 },
        { type: 10, content: "**#{theme[:name]}** costs **#{theme[:price]}** #{EMOJI_STRINGS['prisma']}. You have **#{prisma}**." }
      ]}])
    end

    DB.add_prisma(uid, -theme[:price]) if current != theme_id && theme[:price] > 0
    DB.set_collection_theme(uid, theme_id)
    send_cv2(event, [{ type: 17, accent_color: theme[:color] || NEON_COLORS.sample, components: [
      { type: 10, content: "## 🎨 Theme Applied: #{theme[:name]}" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Your collection now uses the **#{theme[:name]}** theme! Check it out with `#{PREFIX}collection`.#{current != theme_id && theme[:price] > 0 ? "\n-#{theme[:price]} #{EMOJI_STRINGS['prisma']}" : ''}" }
    ]}])

  when 'badge'
    badge_id = args.first&.downcase
    if badge_id.nil?
      owned = DB.get_badges(uid).map { |r| r['badge_id'] }
      visible_badges = BADGES.reject { |_, b| b[:dev_only] && !DEV_IDS.include?(uid) }
      list = visible_badges.map do |id, b|
        owned_mark = owned.include?(id) ? '✅' : (b[:earnable] ? '🔒' : "#{b[:price]} #{EMOJI_STRINGS['prisma']}")
        "#{b[:emoji]} **#{b[:name]}** — #{owned_mark} (`#{id}`)"
      end.join("\n")
      return send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
        { type: 10, content: "## 🏅 Badges" },
        { type: 14, spacing: 1 },
        { type: 10, content: "#{list}\n\n✅ = owned · 🔒 = earn via achievements\n`#{PREFIX}profile badge <id>` to equip · `#{PREFIX}profile badge none` to unequip" }
      ]}])
    end

    if badge_id == 'none'
      DB.set_equipped_badge(uid, nil)
      return send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['checkmark']} Badge Removed" },
        { type: 14, spacing: 1 },
        { type: 10, content: "No badge equipped. Incognito mode." }
      ]}])
    end

    unless BADGES.key?(badge_id)
      return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} Unknown Badge" },
        { type: 14, spacing: 1 },
        { type: 10, content: "That badge doesn't exist. Use `#{PREFIX}profile badge` to see the list." }
      ]}])
    end

    badge = BADGES[badge_id]

    # Dev-only badges
    if badge[:dev_only] && !DEV_IDS.include?(uid)
      return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['x_']} Developer Exclusive" },
        { type: 14, spacing: 1 },
        { type: 10, content: "That badge is reserved for Bot Developers only." }
      ]}])
    end

    # Check if user owns the badge
    unless DB.has_badge?(uid, badge_id)
      if badge[:earnable] && !badge[:dev_only]
        return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
          { type: 10, content: "## 🔒 Badge Locked" },
          { type: 14, spacing: 1 },
          { type: 10, content: "**#{badge[:emoji]} #{badge[:name]}** is earned via achievements. Keep grinding!" }
        ]}])
      end

      # Purchasable badge
      prisma = DB.get_prisma(uid)
      if prisma < badge[:price]
        return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
          { type: 10, content: "## #{EMOJI_STRINGS['x_']} Not Enough Prisma" },
          { type: 14, spacing: 1 },
          { type: 10, content: "**#{badge[:name]}** costs **#{badge[:price]}** #{EMOJI_STRINGS['prisma']}. You have **#{prisma}**." }
        ]}])
      end

      DB.add_prisma(uid, -badge[:price])
      DB.unlock_badge(uid, badge_id)
    end

    DB.set_equipped_badge(uid, badge_id)
    send_cv2(event, [{ type: 17, accent_color: 0xFFD700, components: [
      { type: 10, content: "## #{badge[:emoji]} Badge Equipped!" },
      { type: 14, spacing: 1 },
      { type: 10, content: "**#{badge[:name]}** — *#{badge[:desc]}*\nThis will show on your profile and level page!" }
    ]}])

  when 'reset'
    DB.set_profile_color(uid, nil)
    DB.set_profile_bio(uid, nil)
    (1..3).each { |s| DB.clear_favorite_slot(uid, s) }
    DB.set_pet(uid, nil)
    DB.set_title(uid, nil)
    DB.set_collection_theme(uid, 'default')
    DB.set_equipped_badge(uid, nil)
    send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['checkmark']} Profile Reset" },
      { type: 14, spacing: 1 },
      { type: 10, content: "All profile customizations cleared. Back to default neon vibes." }
    ]}])

  else
    send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['confused']} Unknown Option" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Options: `color`, `bio`, `fav`, `unfav`, `pet`, `title`, `theme`, `badge`, `reset`.\n`#{PREFIX}profile` with no args to see your current settings." }
    ]}])
  end
end

# ------------------------------------------
# TRIGGERS: Prefix & Slash Support
# ------------------------------------------
$bot.command(:profile,
  description: 'Customize your premium profile!',
  category: 'Utility'
) do |event, action, *args|
  execute_profile(event, action, args)
  nil
end

$bot.application_command(:profile) do |event|
  action = event.options['action']
  value = event.options['value'] || ''
  execute_profile(event, action, value.split(' '))
end
