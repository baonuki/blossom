# ==========================================
# EVENT: Bot Ready & Background Tasks
# DESCRIPTION: Triggers once Blossom successfully connects to Discord.
# Handles presence updates, active giveaway polling, and blacklists.
# ==========================================

$bot.ready do |event|
  puts "🌸 Blossom is connected and live!"

  # --- SLASH COMMAND REGISTRATION ---
  # All slash commands are live. Uncomment below to re-register if needed.
  event.bot.register_application_command(:leaderboard, 'Show top users by level for this server')
  # event.bot.register_application_command(:spin, 'Spin the daily prize wheel!')
  # event.bot.register_application_command(:marry, 'Propose to someone!') do |cmd|
  #   cmd.user('user', 'The person you want to marry', required: true)
  # end
  # event.bot.register_application_command(:divorce, 'End your marriage')
  # event.bot.register_application_command(:birthday, 'Set or view your birthday!') do |cmd|
  #   cmd.string('action', 'What to do', required: true, choices: { 'Set Birthday' => 'set', 'View Birthday' => 'view' })
  #   cmd.string('date', 'Your birthday in MM/DD format (for set)', required: false)
  # end
  # event.bot.register_application_command(:profile, 'Customize your premium profile!') do |cmd|
  #   cmd.string('action', 'What to change', required: true, choices: {
  #     'Set Color' => 'color', 'Set Bio' => 'bio', 'Set Favorite' => 'fav',
  #     'Remove Favorite' => 'unfav', 'Reset All' => 'reset', 'View Settings' => 'view'
  #   })
  #   cmd.string('value', 'Hex code, bio text, or "slot name", required: false)
  # end

  puts "#{EMOJI_STRINGS['stream']} Syncing server names to database..."
  active_server_ids = event.bot.servers.keys
  event.bot.servers.each do |id, server|
    # Fetch current XP/Level so we don't reset them to 0
    stats = DB.get_community_level(id)
    # Update the name without changing the XP/Level
    DB.update_community_level(id, server.name, stats['xp'], stats['level'])
  end
  puts "✅ Sync complete!"

  # Prune any servers Blossom is no longer in from the global leaderboard
  # and per-server XP tables. Skipped entirely if the connected-server cache
  # is empty so a bad gateway handshake can't accidentally wipe the DB.
  if active_server_ids.empty?
    puts "[PRUNE] Skipping orphan cleanup — connected-server cache is empty."
  else
    pruned = DB.prune_orphan_servers(active_server_ids)
    if pruned
      puts "🧹 Pruned #{pruned[:leaderboard]} stale leaderboard entr#{pruned[:leaderboard] == 1 ? 'y' : 'ies'} " \
           "and #{pruned[:user_xp]} orphaned user XP row#{pruned[:user_xp] == 1 ? '' : 's'}."
    end
  end

  # ---------------------------------

  # ------------------------------------------
  # 1. DYNAMIC STATUS UPDATER
  # ------------------------------------------
  Thread.new do
    # Set status immediately on startup, then refresh every 60 seconds
    loop do
      begin
        server_count = event.bot.servers.size
        total_members = event.bot.servers.values.sum { |server| server.member_count }

        event.bot.playing = "with #{total_members} users in #{server_count} arcades | #{PREFIX}help"
      rescue => e
        puts "[STATUS] Update failed: #{e.message}"
      end
      sleep 60
    end
  end

  # ------------------------------------------
  # 2. GIVEAWAY END-TIMER LOOP
  # ------------------------------------------
  Thread.new do
    loop do
      sleep_seconds = DB.giveaway_scheduler_sleep_seconds
      sleep(sleep_seconds) if sleep_seconds.positive?

      now = Time.now.to_i
      DB.get_giveaways_due(now).each do |gw|
        gw_id = gw['id']
        begin
          channel = event.bot.channel(gw['channel_id'].to_i)
          unless channel
            DB.delete_giveaway(gw_id)
            next
          end

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
            msg&.edit(nil, ended_embed, Discordrb::Components::View.new)
            channel.send_message("The giveaway for **#{gw['prize']}** ended, but nobody entered!")
          else
            winner_id = entrants.sample
            winner_mention = "<@#{winner_id}>"

            # FIXED: Actually fetch the user object before checking it!
            winner_user = event.bot.user(winner_id)
            check_achievement(channel, winner_id, 'giveaway_win', silent: true) if winner_user

            ended_embed.description = "Hosted by: <@#{gw['host_id']}>\nWinner: #{winner_mention}\nTotal Entrants: **#{entrants.size}**"
            msg&.edit(nil, ended_embed, Discordrb::Components::View.new)
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

  # ------------------------------------------
  # 3. APPLY GLOBAL BLACKLIST + PURGE BLACKLISTED USER DATA
  # ------------------------------------------
  # Every blacklisted user gets re-purged on every boot. The purge is
  # idempotent — if there's nothing left to delete it just no-ops — so this
  # is safe to run unconditionally and acts as a self-healing safety net in
  # case data ever leaks back in for someone on the list.
  blacklist_ids = DB.get_blacklist
  blacklist_total_rows = 0
  blacklist_ids.each do |uid|
    event.bot.ignore_user(uid)
    counts = DB.purge_user_data(uid) || {}
    blacklist_total_rows += counts.values.sum
  end
  if blacklist_ids.any?
    puts "🚫 Re-applied blacklist for #{blacklist_ids.size} user#{blacklist_ids.size == 1 ? '' : 's'} " \
         "(purged #{blacklist_total_rows} stale row#{blacklist_total_rows == 1 ? '' : 's'})."
  end
end
