# ==========================================
# EVENT: Auto-Mod Message Handler
# DESCRIPTION: Filters banned words, links, and spam.
# ==========================================

# In-memory spam tracking: { uid => [timestamp, timestamp, ...] }
SPAM_TRACKER = {}

$bot.message do |event|
  next unless event.server
  next if event.user.bot_account?

  sid = event.server.id
  uid = event.user.id

  # Skip admins and developers
  begin
    next if event.user.permission?(:administrator, event.channel)
  rescue
    next
  end
  next if DEV_IDS.include?(uid)

  config = DB.get_automod_config(sid)

  # --- WORD FILTER ---
  banned_words = DB.get_automod_words(sid)
  unless banned_words.empty?
    content_lower = event.message.content.downcase
    if banned_words.any? { |w| content_lower.include?(w) }
      begin
        event.message.delete
        event.channel.send_message("\u{1F6E1}\u{FE0F} Message from #{event.user.mention} removed \u2014 contains a banned word.")
      rescue
        # Missing permissions
      end
      next
    end
  end

  # --- LINK FILTER ---
  if config['link_filter']
    if event.message.content.match?(%r{https?://|www\.|discord\.gg/}i)
      begin
        event.message.delete
        event.channel.send_message("\u{1F6E1}\u{FE0F} Link from #{event.user.mention} removed \u2014 links are not allowed in this server.")
      rescue
      end
      next
    end
  end

  # --- SPAM FILTER ---
  if config['spam_filter']
    now = Time.now.to_f
    SPAM_TRACKER[uid] ||= []
    SPAM_TRACKER[uid] << now

    # Clean old entries outside the time window
    SPAM_TRACKER[uid].reject! { |t| (now - t) > SPAM_TIME_WINDOW }

    if SPAM_TRACKER[uid].size >= SPAM_MESSAGE_LIMIT
      SPAM_TRACKER[uid] = [] # Reset counter

      begin
        # Timeout via raw Discord API (PATCH /guilds/:id/members/:id)
        timeout_until = (Time.now + SPAM_MUTE_DURATION).utc.iso8601
        Discordrb::API.request(
          :guilds_sid_members_uid, sid, :patch,
          "#{Discordrb::API.api_base}/guilds/#{sid}/members/#{uid}",
          { communication_disabled_until: timeout_until }.to_json,
          Authorization: $bot.token,
          content_type: :json
        )
        event.channel.send_message("\u{1F6E1}\u{FE0F} #{event.user.mention} has been timed out for **#{SPAM_MUTE_DURATION}s** \u2014 slow down, chat!")
      rescue => e
        puts "[AUTOMOD SPAM] Failed to timeout #{uid}: #{e.message}"
      end
    end
  end
end
