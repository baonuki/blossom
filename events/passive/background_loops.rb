# ==========================================
# EVENT: Background Economy Loops
# DESCRIPTION: Houses the threads for hourly lotteries,
# daily reminders, birthdays, happy hours, and auto-claim.
# ==========================================

$bot.ready do |event|

  # --- GLOBAL HOURLY LOTTERY DRAW ---
  Thread.new do
    loop do
      now = Time.now.to_i
      sleep_time = 3600 - (now % 3600)
      sleep(sleep_time)

      entries = DB.get_lottery_entries
      next if entries.nil? || entries.empty?

      DB.clear_lottery

      begin
        winner_id = entries.sample
        jackpot = 100 + (entries.size * 100)

        DB.add_coins(winner_id, jackpot)
        check_achievement(nil, winner_id, 'lottery_win', silent: true)

        winner_user = event.bot.user(winner_id)
        if winner_user
          begin
            winner_user.pm("#{EMOJI_STRINGS['neonsparkle']} **NO WAY — JACKPOT!** You just pulled **#{jackpot}** #{EMOJI_STRINGS['s_coin']} from the Hourly Lottery! Lucky you~ \u{1F338}")
          rescue
          end
        end
      rescue => e
        puts "[LOTTERY ERROR] #{e.message}"
      end
    end
  end

  # --- DAILY REMINDER PING ---
  Thread.new do
    loop do
      sleep(60)

      begin
        pending_reminders = DB.get_pending_daily_reminders

        pending_reminders.each do |row|
          uid = row['user_id'].to_i
          chan_id = row['reminder_channel'].to_i

          channel = event.bot.channel(chan_id)
          if channel
            begin
              channel.send_message("\u{1F514} <@#{uid}>, your `#{PREFIX}daily` is up! Don't break the streak or I WILL judge you. \u{1F338}")
            rescue
            end
          end
          DB.mark_reminder_sent(uid)
        end
      rescue => e
        puts "[REMINDER ERROR] #{e.message}"
      end
    end
  end

  # --- DAILY BIRTHDAY CHECK ---
  Thread.new do
    last_checked_date = nil
    loop do
      sleep(60)
      today = Time.now.strftime('%Y-%m-%d')
      next if today == last_checked_date

      last_checked_date = today
      begin
        birthday_uids = DB.get_todays_birthdays
        birthday_uids.each do |uid|
          DB.add_coins(uid, BIRTHDAY_REWARD)
          user = event.bot.user(uid)
          next unless user

          if is_premium?(event.bot, uid)
            begin
              user.pm("## \u{1F382} HAPPY BIRTHDAY!! #{EMOJI_STRINGS['neonsparkle']}\n\nIt's YOUR day, #{user.name}!! The Neon Arcade is throwing confetti in your honor! " \
                       "Here's **#{BIRTHDAY_REWARD}** #{EMOJI_STRINGS['s_coin']} as a birthday gift from yours truly~ \u{1F338}\n\n*\u2014 Love, Blossom* #{EMOJI_STRINGS['hearts']}")
            rescue
            end
          end
        end
      rescue => e
        puts "[BIRTHDAY ERROR] #{e.message}"
      end
    end
  end

  # --- HAPPY HOUR (Random Coin Multiplier Events) ---
  Thread.new do
    loop do
      now = Time.now.to_i
      # Align to top of each hour
      sleep_time = 3600 - (now % 3600)
      sleep(sleep_time)

      begin
        # Skip if a happy hour is already active
        next if happy_hour_active?

        # Roll for happy hour (HAPPY_HOUR_CHANCE% per hour)
        if rand(100) < HAPPY_HOUR_CHANCE
          $happy_hour = {
            multiplier: HAPPY_HOUR_MULTIPLIER,
            ends_at: Time.now + HAPPY_HOUR_DURATION
          }
          puts "[HAPPY HOUR] \u{1F389} Coin multiplier event started! Ends at #{$happy_hour[:ends_at]}"
        end
      rescue => e
        puts "[HAPPY HOUR ERROR] #{e.message}"
      end
    end
  end

  # --- AUTO-CLAIM DAILY (Premium Feature) ---
  Thread.new do
    loop do
      sleep(120) # Check every 2 minutes

      begin
        autoclaim_users = DB.get_autoclaim_users

        autoclaim_users.each do |row|
          uid = row['user_id'].to_i

          # Verify still premium — disable if lapsed
          unless is_premium?(event.bot, uid)
            DB.toggle_autoclaim(uid) # Turns off
            next
          end

          now = Time.now
          today = Date.today

          # Fetch daily info for streak calculation
          daily_info = DB.get_daily_info(uid)
          last_used = daily_info['at'] ? Time.parse(daily_info['at'].to_s) : nil
          current_streak = daily_info['streak'].to_i

          # Verify cooldown is actually up
          next if last_used && (now - last_used) < DAILY_COOLDOWN

          # Streak calculation
          if last_used.nil? || (now - last_used) > (DAILY_COOLDOWN * 2)
            new_streak = 1
          else
            new_streak = current_streak + 1
          end

          # Base reward + streak
          reward = DAILY_REWARD + (new_streak * DAILY_STREAK_BONUS)

          # Marriage bonus
          marriage = DB.get_marriage(uid)
          reward += MARRIAGE_DAILY_BONUS if marriage

          # Neon sign boost
          inv_array = DB.get_inventory(uid)
          inv = inv_array.each_with_object({}) { |item, h| h[item['item_id']] = item['quantity'] }
          reward *= 2 if inv['neon sign'] && inv['neon sign'] > 0

          # Award coins (handles premium +10% and happy hour)
          final_reward = award_coins(event.bot, uid, reward)
          DB.update_daily_claim(uid, new_streak, now)
          DB.add_calendar_claim(uid, today)

          # Prisma reward
          base_prisma = rand(1..3)
          streak_multiplier = 1 + (new_streak / 7)
          prisma_reward = base_prisma * streak_multiplier
          DB.add_prisma(uid, prisma_reward)

          # Calendar milestone checks
          claim_count = DB.get_monthly_claim_count(uid, today.year, today.month)
          milestone_msg = ""
          if claim_count == CALENDAR_MILESTONE_14
            milestone_bonus = CALENDAR_MILESTONE_14_PREMIUM
            award_coins(event.bot, uid, milestone_bonus)
            milestone_msg += "\n\u2B50 **14-Day Milestone Bonus:** +#{milestone_bonus} coins!"
          end
          if claim_count == CALENDAR_MILESTONE_28
            milestone_bonus = CALENDAR_MILESTONE_28_PREMIUM
            award_coins(event.bot, uid, milestone_bonus)
            DB.add_prisma(uid, CALENDAR_MILESTONE_28_PRISMA)
            milestone_msg += "\n\u{1F31F} **28-Day Milestone Bonus:** +#{milestone_bonus} coins + #{CALENDAR_MILESTONE_28_PRISMA} Prisma!"
          end

          # Achievement checks (silent)
          check_achievement(nil, uid, 'streak_7', silent: true)   if new_streak == 7
          check_achievement(nil, uid, 'streak_30', silent: true)  if new_streak == 30
          check_achievement(nil, uid, 'streak_69', silent: true)  if new_streak == 69
          check_achievement(nil, uid, 'streak_100', silent: true) if new_streak == 100
          check_achievement(nil, uid, 'streak_365', silent: true) if new_streak == 365

          # DM the user
          user = event.bot.user(uid)
          if user
            begin
              user.pm("## #{EMOJI_STRINGS['checkmark']} Auto-Claimed Daily!\n\n" \
                       "I grabbed your daily for you! \u{1F338}\n\n" \
                       "**Reward:** #{final_reward} #{EMOJI_STRINGS['s_coin']} + #{prisma_reward} #{EMOJI_STRINGS['prisma']}\n" \
                       "\u{1F525} **Streak:** #{new_streak} days\n" \
                       "**Calendar:** #{claim_count}/#{Date.new(today.year, today.month, -1).day} this month#{milestone_msg}\n\n" \
                       "Balance: **#{DB.get_coins(uid)}** #{EMOJI_STRINGS['s_coin']}")
            rescue
              # DMs closed
            end
          end
        end
      rescue => e
        puts "[AUTOCLAIM ERROR] #{e.message}"
      end
    end
  end

  # --- DAILY TIP / FUN FACT ---
  Thread.new do
    last_tip_date = nil
    loop do
      sleep(300) # Check every 5 minutes
      today = Time.now.strftime('%Y-%m-%d')
      next if today == last_tip_date

      # Post tips at ~10 AM (hour 10)
      next unless Time.now.hour >= 10

      last_tip_date = today
      begin
        tip = BLOSSOM_TIPS.sample
        tip_channels = DB.get_all_tip_channels

        tip_channels.each do |row|
          chan_id = row['tip_channel'].to_i
          next if chan_id == 0

          channel = event.bot.channel(chan_id)
          next unless channel

          begin
            channel.send_message("## \u{1F4A1} Blossom's Tip of the Day\n\n#{tip}\n\n*\u2014 Your friendly Neon Arcade manager \u{1F338}*")
          rescue
          end
        end
      rescue => e
        puts "[DAILY TIP ERROR] #{e.message}"
      end
    end
  end

  # --- WEEKLY CHALLENGE GENERATION ---
  Thread.new do
    loop do
      sleep(600) # Check every 10 minutes

      begin
        week_start = current_week_start
        existing = DB.get_weekly_challenges(week_start)
        unless existing
          challenges = generate_weekly_challenges
          DB.set_weekly_challenges(week_start, challenges)
          puts "[CHALLENGES] Generated weekly challenges for week of #{week_start}"
        end
      rescue => e
        puts "[CHALLENGE GEN ERROR] #{e.message}"
      end
    end
  end

  # --- HOURLY HEIST EVENTS ---
  Thread.new do
    loop do
      now = Time.now.to_i
      # Align to top of each hour (offset by 30 min so it doesn't collide with lottery)
      sleep_time = 3600 - (now % 3600) + 1800
      sleep_time -= 3600 if sleep_time > 3600
      sleep_time = [sleep_time, 60].max
      sleep(sleep_time)

      begin
        heist_configs = DB.get_all_heist_channels
        heist_configs.each do |row|
          sid = row['server_id'].to_i
          chan_id = row['heist_channel'].to_i
          next if chan_id == 0

          # Skip if a heist is already active for this server
          next if ACTIVE_HEISTS[sid]

          channel = event.bot.channel(chan_id)
          next unless channel

          vault_amount = HEIST_BASE_VAULT + (HEIST_PER_PLAYER_VAULT * 5) # Preview with 5 players

          # Send heist announcement with join button
          body = {
            content: '', flags: CV2_FLAG,
            components: [{
              type: 17, accent_color: 0xFFD700,
              components: [
                { type: 10, content: "## \u{1F3E6} HEIST ALERT! #{EMOJI_STRINGS['neonsparkle']}" },
                { type: 14, spacing: 1 },
                { type: 10, content: "A vault in the Neon Arcade is vulnerable! Assemble a crew to crack it open!\n\n\u{1F4B0} **Estimated Vault:** #{vault_amount}+ #{EMOJI_STRINGS['s_coin']} (scales with crew size)\n\u{1F465} **Min Crew:** #{HEIST_MIN_PLAYERS} players\n\u23F0 **Join Window:** 5 minutes\n\u{1F451} Premium hackers add +#{HEIST_PREMIUM_BONUS}% success rate!\n\nClick below to join the crew!" },
                { type: 14, spacing: 1 },
                { type: 1, components: [
                  { type: 2, style: 3, label: "\u{1F3AD} Join the Heist!", custom_id: "heist_join_#{sid}" }
                ]}
              ]
            }],
            allowed_mentions: { parse: [] }
          }.to_json

          response = Discordrb::API.request(
            :channels_cid_messages_mid, chan_id, :post,
            "#{Discordrb::API.api_base}/channels/#{chan_id}/messages",
            body, Authorization: $bot.token, content_type: :json
          )
          msg_data = JSON.parse(response.body)

          ACTIVE_HEISTS[sid] = {
            message_id: msg_data['id'].to_i,
            participants: [],
            started_at: Time.now,
            channel_id: chan_id
          }

          # Schedule heist execution after join window
          Thread.new do
            sleep(HEIST_JOIN_WINDOW)
            execute_heist_result(event.bot, sid)
          end
        end
      rescue => e
        puts "[HEIST LOOP ERROR] #{e.message}"
      end
    end
  end

end

# --- HEIST RESULT EXECUTION (called after join window) ---
def execute_heist_result(bot, sid)
  heist = ACTIVE_HEISTS.delete(sid)
  return unless heist

  channel = bot.channel(heist[:channel_id])
  return unless channel

  players = heist[:participants]

  if players.size < HEIST_MIN_PLAYERS
    # Not enough players
    begin
      channel.send_message(
        "## \u{1F3E6} Heist Cancelled #{EMOJI_STRINGS['nervous']}\n\n" \
        "Only **#{players.size}** showed up... needed **#{HEIST_MIN_PLAYERS}**. The vault lives another day. Skill issue, chat."
      )
    rescue; end
    return
  end

  # Calculate success chance
  base_chance = HEIST_BASE_CHANCE + (players.size * HEIST_PER_PLAYER)
  premium_count = players.count { |uid| is_premium?(bot, uid) }
  bonus_chance = premium_count * HEIST_PREMIUM_BONUS
  total_chance = [base_chance + bonus_chance, HEIST_MAX_CHANCE].min

  success = rand(100) < total_chance
  vault = HEIST_BASE_VAULT + (players.size * HEIST_PER_PLAYER_VAULT)

  if success
    split = (vault.to_f / players.size).round
    players.each { |uid| DB.add_coins(uid, split) }

    player_mentions = players.map { |uid| "<@#{uid}>" }.join(', ')
    begin
      channel.send_message(
        "## \u{1F4B0} HEIST SUCCESSFUL! #{EMOJI_STRINGS['rich']}\n\n" \
        "The crew cracked the vault! **#{vault}** #{EMOJI_STRINGS['s_coin']} split among **#{players.size}** players!\n\n" \
        "**Each player earned:** #{split} #{EMOJI_STRINGS['s_coin']}\n" \
        "**Success rate was:** #{total_chance}%#{premium_count > 0 ? " (#{premium_count} hacker#{premium_count > 1 ? 's' : ''} helped!)" : ""}\n\n" \
        "\u{1F465} Crew: #{player_mentions}\n\nGG, chat! \u{1F338}"
      )
    rescue; end
  else
    player_mentions = players.map { |uid| "<@#{uid}>" }.join(', ')
    begin
      channel.send_message(
        "## \u{1F6A8} HEIST FAILED! #{EMOJI_STRINGS['error']}\n\n" \
        "The alarm went off! The crew scattered with NOTHING!\n\n" \
        "**Success rate was:** #{total_chance}% \u2014 bad luck!\n\n" \
        "\u{1F465} Crew: #{player_mentions}\n\nBetter luck next hour... \u{1F338}"
      )
    rescue; end
  end
end
