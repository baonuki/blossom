# ==========================================
# EVENT: Member Join & Leave Logging + Welcomer
# DESCRIPTION: Logs member joins/leaves and sends welcome messages.
# ==========================================

WELCOME_MESSAGES = [
  "just walked into the arcade! Everybody say hi or you're banned. (I'm kidding.) (Maybe.)",
  "just joined the party! Quick, someone teach them the vibe before they get lost.",
  "has entered the building! Another player in the Neon Arcade, let's gooo!",
  "just spawned in! Welcome to the chaos, grab a seat and try not to break anything.",
  "is here! The server just got a little more interesting. Probably.",
  "just logged in! Hope you're ready for the best community on Discord. No pressure.",
  "has arrived! Someone roll out the neon carpet!"
].freeze

UNVERIFIED_ROLE_ID  = 1472510193299361802
UNVERIFIED_SERVER_ID = 1472509438010065070

$bot.member_join do |event|
  user = event.member
  server = event.server

  # --- AUTO-ASSIGN UNVERIFIED ROLE ---
  if server.id == UNVERIFIED_SERVER_ID
    begin
      unverified_role = server.role(UNVERIFIED_ROLE_ID)
      user.add_role(unverified_role) if unverified_role
    rescue => e
      puts "[UNVERIFIED ROLE ERROR] #{e.message}"
    end
  end

  # --- WELCOMER ---
  begin
    welcome_config = DB.get_welcome_config(server.id)
    if welcome_config[:enabled] && welcome_config[:channel]
      welcome_channel = event.bot.channel(welcome_config[:channel])
      if welcome_channel
        avatar_url = user.avatar_url || ''
        custom_msg = DB.get_welcome_message(server.id)

        if custom_msg
          welcome_body = custom_msg.gsub('{user}', user.mention).gsub('{server}', server.name)
        else
          welcome_body = "#{user.mention} #{WELCOME_MESSAGES.sample}"
        end

        components = [{ type: 17, accent_color: NEON_COLORS.sample, components: [
          { type: 9, components: [
            { type: 10, content: "## #{EMOJI_STRINGS['neonsparkle']} Welcome to #{server.name}!" },
            { type: 10, content: welcome_body }
          ], accessory: { type: 11, media: { url: avatar_url } } },
          { type: 14, spacing: 1 },
          { type: 10, content: "You're member **##{server.member_count}** — make yourself at home, chat! #{EMOJI_STRINGS['hearts']}" }
        ]}]

        body = { content: '', flags: CV2_FLAG, components: components }.to_json
        Discordrb::API.request(
          :channels_cid_messages_mid,
          welcome_channel.id,
          :post,
          "#{Discordrb::API.api_base}/channels/#{welcome_channel.id}/messages",
          body,
          Authorization: $bot.token,
          content_type: :json
        )
      end
    end
  rescue => e
    puts "[WELCOMER ERROR] #{e.message}"
  end

  # --- JOIN LOGGING ---
  begin
    config = DB.get_log_config(server.id)
    if config && config['log_joins'] && config['log_channel']
      log_channel = event.bot.channel(config['log_channel'])
      if log_channel
        account_age = ((Time.now - user.creation_time) / 86400).round

        embed = Discordrb::Webhooks::Embed.new(
          title: "#{EMOJI_STRINGS['checkmark']} Member Joined",
          description: "**#{user.display_name}** (#{user.mention}) just walked into the arcade.\n\n" \
                       "**Account Age:** #{account_age} days\n" \
                       "**Member Count:** #{server.member_count}",
          color: 0x00FF00,
          timestamp: Time.now
        )
        embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: user.avatar_url) if user.avatar_url
        log_channel.send_message(nil, false, embed)
      end
    end
  rescue => e
    puts "[LOG ERROR] Failed to log member join: #{e.message}"
  end
end

$bot.member_leave do |event|
  config = DB.get_log_config(event.server.id)
  next unless config && config['log_leaves'] && config['log_channel']

  log_channel = event.bot.channel(config['log_channel'])
  next unless log_channel

  user = event.user

  embed = Discordrb::Webhooks::Embed.new(
    title: "#{EMOJI_STRINGS['x_']} Member Left",
    description: "**#{user.name}** (#{user.mention}) has left the arcade.\n\n" \
                 "**Member Count:** #{event.server.member_count}",
    color: 0xFF0000,
    timestamp: Time.now
  )
  embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: user.avatar_url) if user.avatar_url

  begin
    log_channel.send_message(nil, false, embed)
  rescue => e
    puts "[LOG ERROR] Failed to log member leave: #{e.message}"
  end
end
