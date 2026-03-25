# ==========================================
# EVENT: Background Economy Loops
# DESCRIPTION: Houses the threads for hourly lotteries and 
# daily reminders. Wrapped in bot.ready so they don't crash on boot.
# ==========================================

bot.ready do |event|
  
  # --- GLOBAL HOURLY LOTTERY DRAW ---
  Thread.new do
    loop do
      now = Time.now.to_i
      # Calculate exact seconds until the next top-of-the-hour
      sleep_time = 3600 - (now % 3600) 
      sleep(sleep_time)

      entries = DB.get_lottery_entries
      next if entries.nil? || entries.empty?
      
      DB.clear_lottery # Wipe it for the next hour

      begin
        winner_id = entries.sample
        jackpot = 100 + (entries.size * 100) # Base 100 + 100 per entry
        
        DB.add_coins(winner_id, jackpot)
        
        winner_user = event.bot.user(winner_id)
        if winner_user
          begin
            winner_user.pm("✨ **JACKPOT!** You won **#{jackpot}** #{EMOJIS['s_coin']} in the Hourly Lottery! 🌸")
          rescue
            # Ignore if their DMs are closed
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
      sleep(60) # Check the database once every minute
      
      begin
        pending_reminders = DB.get_pending_daily_reminders
        
        pending_reminders.each do |row|
          uid = row['user_id'].to_i
          chan_id = row['reminder_channel'].to_i
          
          channel = event.bot.channel(chan_id)
          if channel
            begin
              channel.send_message("🔔 <@#{uid}>, your `#{PREFIX}daily` is ready! Don't lose your streak! 🌸")
            rescue
              # Ignore if bot lacks permission to type in that channel
            end
          end
          DB.mark_reminder_sent(uid) 
        end
      rescue => e
        puts "[REMINDER ERROR] #{e.message}"
      end
    end
  end

end