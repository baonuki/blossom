# ==========================================
# COMMAND: banner
# DESCRIPTION: Check the current gacha pool and the next scheduled rotation.
# CATEGORY: Gacha
# ==========================================

# ------------------------------------------
# LOGIC: Gacha Banner Display Execution
# ------------------------------------------
def execute_banner(event)
  # 1. Initialization: Fetch the currently active banner data
  active_banner = get_current_banner
  chars = active_banner[:characters]
  
  # 2. Rotation Logic: Calculate the current and next weekly window
  # 604,800 is the number of seconds in a week.
  week_number = Time.now.to_i / 604_800 
  available_pools = CHARACTER_POOLS.keys
  
  # Predict the next banner in the rotation
  next_key = available_pools[(week_number + 1) % available_pools.size]
  next_banner = CHARACTER_POOLS[next_key]
  next_rotation_time = (week_number + 1) * 604_800

  # 3. UI: Build the description with live Discord timestamps
  desc = "Here's who's in the Neon Arcade portal this week, chat.\n\n" \
         "**Next Rotation:** <t:#{next_rotation_time}:R>\n" \
         "**Up Next:** #{next_banner[:name]}"

  # 4. UI: Construct the CV2 Container with rarity sections
  components = [
    {
      type: 17,
      accent_color: NEON_COLORS.sample,
      components: [
        { type: 10, content: "## #{EMOJI_STRINGS['neonsparkle']} Current Gacha: #{active_banner[:name]}" },
        { type: 14, spacing: 1 },
        { type: 10, content: desc },
        { type: 14, spacing: 1 },
        { type: 10, content: "**#{EMOJI_STRINGS['crown']} Goddesses (1%)** — actual lottery winners only\n#{chars[:goddess].map { |c| c[:name] }.join(', ')}" },
        { type: 14, spacing: 1 },
        { type: 10, content: "**🌟 Legendaries (5%)** — W pull territory\n#{chars[:legendary].map { |c| c[:name] }.join(', ')}" },
        { type: 14, spacing: 1 },
        { type: 10, content: "**#{EMOJI_STRINGS['neonsparkle']} Rares (25%)** — solid, no copium needed\n#{chars[:rare].map { |c| c[:name] }.join(', ')}" },
        { type: 14, spacing: 1 },
        { type: 10, content: "**⭐ Commons (69%)** — you'll see these a lot, chat\n#{chars[:common].map { |c| c[:name] }.join(', ')}" }
      ]
    }
  ]

  # 5. Messaging: Send the finalized CV2 message
  send_cv2(event, components)
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!banner)
# ------------------------------------------
$bot.command(:banner, 
  description: 'Check which characters are in the gacha pool this week!', 
  category: 'Gacha'
) do |event|
  execute_banner(event)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/banner)
# ------------------------------------------
$bot.application_command(:banner) do |event|
  execute_banner(event)
end