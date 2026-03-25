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

  # 3. UI: Construct the Rarity Fields
  # We've added the "Goddess" tier at 1% and kept the rest of your rates balanced.
  fields = [
    { 
      name: '👑 Goddesses (1%)', 
      value: chars[:goddess].map { |c| c[:name] }.join(', '), 
      inline: false 
    },
    { 
      name: '🌟 Legendaries (5%)', 
      value: chars[:legendary].map { |c| c[:name] }.join(', '), 
      inline: false 
    },
    { 
      name: '✨ Rares (25%)', 
      value: chars[:rare].map { |c| c[:name] }.join(', '), 
      inline: false 
    },
    { 
      name: '⭐ Commons (69%)', 
      value: chars[:common].map { |c| c[:name] }.join(', '), 
      inline: false 
    }
  ]

  # 4. UI: Build the description with live Discord timestamps
  desc = "Here are the VTubers you can pull this week!\n\n" \
         "**Next Rotation:** <t:#{next_rotation_time}:R>\n" \
         "**Up Next:** #{next_banner[:name]}"

  # 5. Messaging: Send the finalized Embed
  send_embed(
    event, 
    title: "#{EMOJIS['neonsparkle']} Current Gacha: #{active_banner[:name]}", 
    description: desc, 
    fields: fields
  )
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!banner)
# ------------------------------------------
bot.command(:banner, 
  description: 'Check which characters are in the gacha pool this week!', 
  category: 'Gacha'
) do |event|
  execute_banner(event)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/banner)
# ------------------------------------------
bot.application_command(:banner) do |event|
  execute_banner(event)
end