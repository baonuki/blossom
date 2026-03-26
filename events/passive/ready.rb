# ==========================================
# EVENT: Bot Ready & Background Tasks
# DESCRIPTION: Triggers once Blossom successfully connects to Discord.
# Handles presence updates, active giveaway polling, and blacklists.
# ==========================================

$bot.ready do |event|
  puts "🌸 Blossom is connected and live!"

  # --- CLEAN UP OLD/REMOVED SLASH COMMANDS ---
  # Delete commands that were removed or need to be re-registered with new params
  removed_commands = %w[
    addcoins removecoins setcoins givepremium removepremium
    prisma blacklist card syncachievements
    addxp setlevel enablebombs disablebombs
    dcoin dpremium dbomb
  ]
  # Also force re-register these by deleting first (params changed)
  refresh_commands = %w[bomb setxp]

  event.bot.get_application_commands.each do |cmd|
    if removed_commands.include?(cmd.name) || refresh_commands.include?(cmd.name)
      event.bot.delete_application_command(cmd.id)
      puts "🗑️ Deleted slash command: #{cmd.name} (ID: #{cmd.id})"
    end
  end

  # Re-register commands that need fresh params
  puts "🔄 Re-registering updated slash commands..."
  event.bot.register_application_command(:bomb, 'Enable or disable bomb drops (Admin Only)') do |cmd|
    cmd.string('action', 'Enable or disable', required: true, choices: { 'Enable' => 'enable', 'Disable' => 'disable' })
    cmd.channel('channel', 'The channel to drop bombs in (required for enable)', required: false)
  end
  event.bot.register_application_command(:setxp, 'Manage user XP/Level (Admin Only)') do |cmd|
    cmd.string('action', 'What to do', required: true, choices: { 'Add XP' => 'add', 'Remove XP' => 'remove', 'Set XP' => 'set', 'Set Level' => 'level' })
    cmd.user('user', 'The user to modify', required: true)
    cmd.integer('amount', 'Amount of XP or target level', required: true)
  end
  puts "✅ Slash commands refreshed!"

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
