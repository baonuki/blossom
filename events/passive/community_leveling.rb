# ==========================================
# EVENT: Community Leveling Engine
# DESCRIPTION: Listens to all server messages and awards co-op XP
# to the server's global pool. Includes a 30-second anti-spam cooldown.
# ==========================================

# Calculates the total XP required to reach the NEXT server level.
# The curve is steep to account for hundreds of users chatting at once.
def community_xp_needed(current_level)
  (100 * (current_level ** 2)) + (1000 * current_level)
end

# An in-memory cache to track when a user last earned XP for a specific server.
# This resets every time Blossom reboots, which is perfectly fine for a simple 30s cooldown.
USER_XP_COOLDOWNS = {}

$bot.message do |event|
  # Ignore other bots and messages sent in private DMs
  next if event.author.bot_account? || event.server.nil?

  server_id = event.server.id
  uid = event.author.id
  now = Time.now.to_i

  # Fetch the last time this specific user earned XP in this specific server
  last_msg_time = USER_XP_COOLDOWNS["#{server_id}_#{uid}"] || 0
  
  # Anti-Spam Check: Only grant XP if 30 seconds have passed since their last valid message
  if (now - last_msg_time) >= 30
    # Update their cooldown timer immediately
    USER_XP_COOLDOWNS["#{server_id}_#{uid}"] = now

    # Fetch the server's current standing from the database
    stats = DB.get_community_level(server_id)
    current_xp = stats['xp'].to_i
    current_level = stats['level'].to_i
    
    # Generate a random XP drop between 15 and 25
    xp_gained = rand(15..25)
    new_xp = current_xp + xp_gained
    new_level = current_level

    # Check if this new XP pushes them over the threshold for the next level
    needed_xp = community_xp_needed(current_level)
    

    if new_xp >= needed_xp
      new_level += 1 # Level up!

      # Only announce if enabled (default: off)
      announce_enabled = DB.get_community_announce_enabled(server_id)

      if announce_enabled
        embed = Discordrb::Webhooks::Embed.new(
          title: "🎊 Community Level Up!",
          description: "Incredible teamwork! **#{event.server.name}** has reached **Server Level #{new_level}**!",
          color: 0x00FF00,
          image: Discordrb::Webhooks::EmbedImage.new(url: "https://media.discordapp.net/attachments/1475890017443516476/1483149362832871424/Retro-Arcade-Twitch-Overlay-OBS.webp")
        )
        event.channel.send_message(nil, false, embed)
      end
    end

    # Pass event.server.name to the database
    DB.update_community_level(server_id, event.server.name, new_xp, new_level)
  end
end