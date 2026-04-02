# ==========================================
# COMMAND: fish
# DESCRIPTION: Cast a line and reel in catches worth varying coins.
# CATEGORY: Arcade
# ==========================================

# Weighted catch table: [name, emoji, coin_value, weight]
# Higher weight = more common
FISH_TABLE = [
  { name: 'Old Boot',        emoji: '👢', coins: 5,    weight: 15, tier: :junk },
  { name: 'Tin Can',         emoji: '🥫', coins: 10,   weight: 12, tier: :junk },
  { name: 'Seaweed',         emoji: '🌿', coins: 15,   weight: 10, tier: :junk },
  { name: 'Guppy',           emoji: '🐟', coins: 30,   weight: 15, tier: :common },
  { name: 'Sardine',         emoji: '🐟', coins: 50,   weight: 12, tier: :common },
  { name: 'Clownfish',       emoji: '🐠', coins: 75,   weight: 10, tier: :common },
  { name: 'Pufferfish',      emoji: '🐡', coins: 100,  weight: 7,  tier: :uncommon },
  { name: 'Electric Eel',    emoji: '⚡', coins: 150,  weight: 5,  tier: :uncommon },
  { name: 'Octopus',         emoji: '🐙', coins: 250,  weight: 4,  tier: :rare },
  { name: 'Sea Turtle',      emoji: '🐢', coins: 400,  weight: 3,  tier: :rare },
  { name: 'Shark',           emoji: '🦈', coins: 750,  weight: 2,  tier: :epic },
  { name: 'Whale',           emoji: '🐋', coins: 1500, weight: 1,  tier: :legendary },
  { name: 'Golden Koi',      emoji: '✨', coins: 3000, weight: 1,  tier: :mythic }
].freeze

# Premium "Golden Rod" adds extra catches
GOLDEN_ROD_TABLE = [
  { name: 'Neon Jellyfish',  emoji: '🪼', coins: 500,  weight: 3, tier: :rare },
  { name: 'Abyssal Leviathan', emoji: '🌊', coins: 2000, weight: 1, tier: :legendary },
  { name: 'Prisma Crab',     emoji: '🦀', coins: 0, prisma: 5, weight: 2, tier: :epic }
].freeze

FISH_TIER_COLORS = {
  junk: 0x808080, common: 0xAAAAAA, uncommon: 0x00CC00,
  rare: 0x3399FF, epic: 0xAA00FF, legendary: 0xFFAA00, mythic: 0xFF00AA
}.freeze

def weighted_sample(table)
  total = table.sum { |f| f[:weight] }
  roll = rand(total)
  cumulative = 0
  table.each do |fish|
    cumulative += fish[:weight]
    return fish if roll < cumulative
  end
  table.last
end

def execute_fish(event)
  uid = event.user.id
  now = Time.now
  is_sub = is_premium?(event.bot, uid)

  # 1. Cooldown Check
  cooldown = is_sub ? FISH_COOLDOWN_PREMIUM : FISH_COOLDOWN
  last_used = DB.get_cooldown(uid, 'fish')

  if last_used && (now - last_used) < cooldown
    remaining = cooldown - (now - last_used)
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['drink']} Line's Still Wet" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You just cast. Chill for **#{format_time_delta(remaining)}** before you fish again." }
    ]}])
  end

  # 2. Set cooldown
  DB.set_cooldown(uid, 'fish', now)

  # 3. Build catch pool (premium gets extra fish)
  pool = FISH_TABLE.dup
  pool += GOLDEN_ROD_TABLE if is_sub

  # 4. Roll the catch
  catch = weighted_sample(pool)

  # 5. Award coins (or prisma for special catches)
  if catch[:prisma]
    DB.add_prisma(uid, catch[:prisma])
    reward_text = "**+#{catch[:prisma]}** #{EMOJI_STRINGS['prisma']}"
  else
    final_coins = is_sub ? (catch[:coins] * 1.10).to_i : catch[:coins]
    DB.add_coins(uid, final_coins)
    reward_text = "**+#{final_coins}** #{EMOJI_STRINGS['s_coin']}"
  end

  # 6. Tier flavor text
  flavor = case catch[:tier]
           when :junk      then "...that's not even a fish. Tragic."
           when :common    then "Basic catch, basic vibes. At least it's something."
           when :uncommon  then "Okay, not bad. A decent haul."
           when :rare      then "Ooh, now THAT'S a catch! Nice pull from the deep."
           when :epic      then "YO?? Chat look at this absolute UNIT!"
           when :legendary then "NO WAY. A legendary catch?! The ocean just blessed you!"
           when :mythic    then "WHAT. THE. ACTUAL. I CAN'T EVEN— CHAT ARE YOU SEEING THIS?!"
           end

  rod_text = is_sub ? "\n#{EMOJI_STRINGS['neonsparkle']} *Golden Rod equipped — exclusive catches unlocked!*" : ""

  components = [{ type: 17, accent_color: FISH_TIER_COLORS[catch[:tier]], components: [
    { type: 10, content: "## 🎣 Gone Fishin'" },
    { type: 14, spacing: 1 },
    { type: 10, content: "You cast your line and reel in...\n\n" \
                         "## #{catch[:emoji]} #{catch[:name]}\n" \
                         "*(#{catch[:tier].to_s.capitalize})*\n\n" \
                         "#{flavor}\n\n#{reward_text}#{rod_text}\n" \
                         "💳 **Balance:** #{DB.get_coins(uid)} #{EMOJI_STRINGS['s_coin']}#{mom_remark(uid, 'arcade')}" }
  ]}]
  send_cv2(event, components)
end

# ------------------------------------------
# TRIGGERS
# ------------------------------------------
$bot.command(:fish, aliases: [:fishing, :cast],
  description: 'Cast a line and catch something! (5m cooldown)',
  category: 'Arcade'
) do |event|
  execute_fish(event)
  nil
end

$bot.application_command(:fish) do |event|
  execute_fish(event)
end
