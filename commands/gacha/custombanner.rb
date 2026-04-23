# ==========================================
# COMMAND: custombanner
# DESCRIPTION: Premium feature to set a custom pull banner for 1 hour.
# CATEGORY: Gacha
# ==========================================

CUSTOM_BANNER_REQUIRED = { common: 5, rare: 5, legendary: 5, goddess: 3 }.freeze

# ------------------------------------------
# LOGIC: Custom Banner Execution
# ------------------------------------------
def execute_custombanner(event, commons_str, rares_str, legendaries_str, goddesses_str)
  uid = event.user.id

  # 1. Premium Check
  unless is_premium?(event.bot, uid)
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['prisma']} Custom Banner" },
      { type: 14, spacing: 1 },
      { type: 10, content: "This is a **premium-only** feature, chat. You need a subscription to create custom banners.\nCheck out `/premium` for the perks!" }
    ]}])
  end

  # 2. Prisma Check
  prisma = DB.get_prisma(uid)
  if prisma < CUSTOM_BANNER_COST
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['prisma']} Custom Banner" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You need **#{CUSTOM_BANNER_COST}** #{EMOJI_STRINGS['prisma']} Prisma to set a custom banner. You've got **#{prisma}**.\nGo grind some Prisma, bestie." }
    ]}])
  end

  # 3. Parse character names from comma-separated strings
  parsed = {}
  errors = []

  { common: commons_str, rare: rares_str, legendary: legendaries_str, goddess: goddesses_str }.each do |rarity, str|
    if str.nil? || str.strip.empty?
      errors << "Missing **#{rarity}** characters."
      next
    end

    names = str.split(',').map(&:strip).reject(&:empty?)
    required = CUSTOM_BANNER_REQUIRED[rarity]

    if names.size != required
      errors << "Need exactly **#{required}** #{rarity} characters, got **#{names.size}**."
      next
    end

    # Validate each character exists in the universal pool at the correct rarity
    validated = []
    names.each do |name|
      found = UNIVERSAL_POOL[:characters][rarity]&.find { |c| c[:name].downcase == name.downcase }
      if found
        validated << found[:name]
      else
        errors << "**#{name}** is not a valid #{rarity} character."
      end
    end

    # Check for duplicates
    if validated.size != validated.uniq.size
      errors << "Duplicate #{rarity} characters detected. Each pick must be unique."
    end

    parsed[rarity] = validated
  end

  unless errors.empty?
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['error']} Custom Banner — Validation Failed" },
      { type: 14, spacing: 1 },
      { type: 10, content: errors.join("\n") },
      { type: 14, spacing: 1 },
      { type: 10, content: "Use `/collection` or `/view` to check character names. Spelling matters, chat!" }
    ]}])
  end

  # 4. Charge Prisma and set the custom banner
  DB.add_prisma(uid, -CUSTOM_BANNER_COST)
  DB.set_custom_banner(uid, parsed, 3600)

  expires_at = (Time.now + 3600).to_i

  # 5. Build the confirmation UI
  char_list = ""
  { goddess: EMOJI_STRINGS['goddess'], legendary: EMOJI_STRINGS['legendary'], rare: EMOJI_STRINGS['rare'], common: EMOJI_STRINGS['common'] }.each do |rarity, emoji|
    char_list += "#{emoji} **#{rarity.to_s.capitalize}:** #{parsed[rarity].join(', ')}\n"
  end

  send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
    { type: 10, content: "## #{EMOJI_STRINGS['neonsparkle']} Custom Banner Activated!" },
    { type: 14, spacing: 1 },
    { type: 10, content: "Your personal pull banner is LIVE, chat. Only YOUR selected characters will appear when you summon.\n\n**Expires:** <t:#{expires_at}:R>\n**Cost:** #{CUSTOM_BANNER_COST} #{EMOJI_STRINGS['prisma']} Prisma" },
    { type: 14, spacing: 1 },
    { type: 10, content: char_list.strip },
    { type: 14, spacing: 1 },
    { type: 10, content: "Now go `/summon` and get exactly who you want. You're welcome.#{mom_remark(uid, 'gacha')}" }
  ]}])
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!custombanner)
# ------------------------------------------
$bot.command(:custombanner, aliases: [:cb, :mybanner],
  description: 'Set a custom pull banner for 1 hour (Premium, 20 Prisma)',
  category: 'Gacha'
) do |event, *args|
  # Prefix format: b!custombanner common1, common2, ... | rare1, rare2, ... | leg1, leg2, ... | goddess1, goddess2, ...
  raw = args.join(' ')
  parts = raw.split('|').map(&:strip)

  if parts.size != 4
    next send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['info']} Custom Banner — Usage" },
      { type: 14, spacing: 1 },
      { type: 10, content: "**Format:** `b!custombanner <5 commons> | <5 rares> | <5 legendaries> | <3 goddesses>`\n\nSeparate tiers with `|` and character names with `,`.\n\n**Example:**\n`b!custombanner Filian, Bao, Silvervale, Zentreya, Obkatiekat | Shylily, Nihmune, Apricot, Dokibird, Kson | Ironmouse, Nyanners, Gawr Gura, Neuro-sama, FUWAMOCO | baonuki, Blossom, Katoh Eli`\n\n**Cost:** #{CUSTOM_BANNER_COST} #{EMOJI_STRINGS['prisma']} Prisma (Premium only)\n**Duration:** 1 hour" }
    ]}])
  end

  execute_custombanner(event, parts[0], parts[1], parts[2], parts[3])
  nil
end

# ------------------------------------------
# TRIGGER: Slash Command (/custombanner)
# ------------------------------------------
$bot.application_command(:custombanner) do |event|
  execute_custombanner(
    event,
    event.options['commons'],
    event.options['rares'],
    event.options['legendaries'],
    event.options['goddesses']
  )
end
