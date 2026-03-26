# ==========================================
# EVENT: Bot Ready & Background Tasks
# DESCRIPTION: Triggers once Blossom successfully connects to Discord.
# Handles presence updates, active giveaway polling, and blacklists.
# ==========================================

$bot.ready do |event|
  puts "🌸 Blossom is connected and live!"

  # --- CLEAN UP REMOVED SLASH COMMANDS ---
  removed_commands = %w[
    addcoins removecoins setcoins givepremium removepremium
    prisma blacklist card syncachievements
    addxp setlevel enablebombs disablebombs bomb setxp
  ]
  event.bot.get_application_commands.each do |cmd|
    if removed_commands.include?(cmd.name)
      event.bot.delete_application_command(cmd.id)
      puts "🗑️ Deleted removed slash command: \\#{cmd.name} (ID: \\#{cmd.id})"
    end
  end

  puts "#{EMOJI_STRINGS['stream']} Syncing server names to database..."
  event.bot.servers.each do |id, server|
    # Fetch current XP/Level so we don't reset them to 0
    stats = DB.get_community_level(id)
    # Update the name without changing the XP/Level
    DB.update_community_level(id, server.name, stats['xp'], stats['level'])
  end
  puts "✅ Sync complete!"

  # ---------------------------------

  # ------------------------------------------
  # 1. DYNAMIC STATUS UPDATER
  # ------------------------------------------
  Thread.new do
    loop do
      begin
        server_count = event.bot.servers.size
        total_members = event.bot.servers.values.sum { |server| server.member_count }

        # Updates Blossom's "Playing" status every 60 seconds
        event.bot.playing = "with #{total_members} users in #{server_count} arcades | #{PREFIX}help"

        sleep 60
      rescue => e
        sleep 15 # If Discord's API hiccups, wait 15 seconds and try again
      end
    end
  end

  # ------------------------------------------
  # 2. GIVEAWAY END-TIMER LOOP
  # ------------------------------------------
  Thread.new do
    loop do
      sleep 10 # Check the database every 10 seconds for ended giveaways
      now = Time.now.to_i
      active_gws = DB.get_active_giveaways
      active_gws.each do |gw|
        if now >= gw['end_time'].to_i
          gw_id = gw['id']
          begin
            channel = event.bot.channel(gw['channel_id'].to_i)
            next unless channel

            entrants = DB.get_giveaway_entrants(gw_id)

            # Try to fetch the original giveaway message to edit it
            begin
              msg = channel.message(gw['message_id'].to_i)
            rescue
              msg = nil
            end

            ended_embed = Discordrb::Webhooks::Embed.new(
              title: "#{EMOJI_STRINGS['surprise']} **GIVEAWAY ENDED: #{gw['prize']}** #{EMOJI_STRINGS['surprise']}",
              color: 0x808080 # Gray out the embed so people know it's over
            )

            if entrants.empty?
              ended_embed.description = "Hosted by: <@#{gw['host_id']}>\n\nNobody entered the giveaway! 😢"
              msg.edit(nil, ended_embed, Discordrb::Components::View.new) if msg
              channel.send_message("The giveaway for **#{gw['prize']}** ended, but nobody entered!")
            else
              winner_id = entrants.sample
              winner_mention = "<@#{winner_id}>"

              # FIXED: Actually fetch the user object before checking it!
              winner_user = event.bot.user(winner_id)
              check_achievement(channel, winner_id, 'giveaway_win', silent: true) if winner_user

              ended_embed.description = "Hosted by: <@#{gw['host_id']}>\nWinner: #{winner_mention}\nTotal Entrants: **#{entrants.size}**"
              msg.edit(nil, ended_embed, Discordrb::Components::View.new) if msg
              channel.send_message("Congratulations #{winner_mention}! You won the **#{gw['prize']}**! #{EMOJI_STRINGS['surprise']}")
            end

            # Wipe it from the active database
            DB.delete_giveaway(gw_id)
          rescue StandardError => e
            puts "#{EMOJI_STRINGS['error']} Cleaned up broken giveaway #{gw_id} - #{e.message}"
            DB.delete_giveaway(gw_id) # Delete broken ones so they don't loop forever
          end
        end
      end
    end
  end

  # ------------------------------------------
  # 3. APPLY GLOBAL BLACKLIST
  # ------------------------------------------
  DB.get_blacklist.each do |uid|
    event.bot.ignore_user(uid)
  end
end
