# ==========================================
# EVENT: Ticket System (Support + Applications)
# DESCRIPTION: Handles ticket creation from select menus,
# claim buttons, and close buttons for both support
# tickets and mod applications.
# ==========================================

# Permission bit constants
# VIEW_CHANNEL (1<<10) | SEND_MESSAGES (1<<11) | READ_MESSAGE_HISTORY (1<<16)
TICKET_VIEW_SEND = (1 << 10) | (1 << 11) | (1 << 16) # 66560 + 1024 = 68608
TICKET_DENY_VIEW = (1 << 10) # VIEW_CHANNEL = 1024

# ACTIVE_TICKETS is defined in data/constants.rb

# ==========================================
# SUPPORT TICKET SELECT MENU
# ==========================================
$bot.select_menu(custom_id: 'ticket_support_open') do |event|
  uid = event.user.id

  # Prevent duplicate open tickets
  if ACTIVE_TICKETS[uid]
    event.respond(content: "🎫 *You already have an open ticket! Please use your existing ticket or wait for it to be closed.*", ephemeral: true)
    next
  end

  selected = event.values.first
  label = SUPPORT_TICKET_OPTIONS.find { |o| o[:value] == selected }&.dig(:label) || selected

  # Acknowledge immediately (ephemeral)
  event.respond(content: "🎫 *Creating your support ticket...*", ephemeral: true)

  # Create the private channel via Discord API
  channel_name = "ticket-#{event.user.name.downcase.gsub(/[^a-z0-9]/, '')}-#{uid.to_s[-4..]}"
  server_id = TICKET_SERVER_ID

  permission_overwrites = [
    # Deny @everyone from viewing
    { id: server_id.to_s, type: 0, deny: TICKET_DENY_VIEW.to_s, allow: '0' },
    # Allow the ticket opener
    { id: uid.to_s, type: 1, allow: TICKET_VIEW_SEND.to_s, deny: '0' },
    # Allow staff role
    { id: TICKET_STAFF_ROLE.to_s, type: 0, allow: TICKET_VIEW_SEND.to_s, deny: '0' }
  ]

  begin
    response = Discordrb::API.request(
      :guilds_gid_channels, server_id, :post,
      "#{Discordrb::API.api_base}/guilds/#{server_id}/channels",
      {
        name: channel_name,
        type: 0,
        parent_id: TICKET_CATEGORY_ID.to_s,
        topic: "Support Ticket | #{label} | Opened by #{event.user.name} (#{uid})",
        permission_overwrites: permission_overwrites
      }.to_json,
      Authorization: $bot.token,
      content_type: :json
    )

    channel_data = JSON.parse(response.body)
    ticket_channel_id = channel_data['id']
    ACTIVE_TICKETS[uid] = ticket_channel_id.to_i

    # Send the ticket embed inside the new channel
    ticket_body = {
      content: '', flags: CV2_FLAG,
      components: [{
        type: 17, accent_color: 0x7C3AED,
        components: [
          { type: 10, content: "## 🎫 Support Ticket — #{label}" },
          { type: 14, spacing: 1 },
          { type: 10, content: "**Opened by:** #{event.user.mention}\n**Category:** #{label}\n**Ticket ID:** `#{channel_name}`\n\nPlease describe your issue below and a staff member will assist you shortly.\n\n*A staff member can claim this ticket using the button below.*" },
          { type: 14, spacing: 1 },
          { type: 1, components: [
            { type: 2, style: 3, label: "Claim Ticket", custom_id: "ticket_claim_#{ticket_channel_id}", emoji: { name: '✋' } },
            { type: 2, style: 4, label: "Close Ticket", custom_id: "ticket_close_#{ticket_channel_id}_#{uid}", emoji: { name: '🔒' } }
          ]}
        ]
      }],
      allowed_mentions: { parse: ['users'] }
    }.to_json

    Discordrb::API.request(
      :channels_cid_messages_mid, ticket_channel_id, :post,
      "#{Discordrb::API.api_base}/channels/#{ticket_channel_id}/messages",
      ticket_body, Authorization: $bot.token, content_type: :json
    )

    # Ping staff role so they know
    Discordrb::API.request(
      :channels_cid_messages_mid, ticket_channel_id, :post,
      "#{Discordrb::API.api_base}/channels/#{ticket_channel_id}/messages",
      { content: "<@&#{TICKET_STAFF_ROLE}> — New support ticket opened!", allowed_mentions: { parse: ['roles'] } }.to_json,
      Authorization: $bot.token, content_type: :json
    )
  rescue => e
    puts "[TICKET CREATE ERROR] #{e.message}"
  end
end

# ==========================================
# MOD APPLICATION SELECT MENU
# ==========================================
$bot.select_menu(custom_id: 'ticket_apply_open') do |event|
  uid = event.user.id

  # Prevent duplicate open tickets
  if ACTIVE_TICKETS[uid]
    event.respond(content: "📝 *You already have an open ticket/application! Please use your existing one or wait for it to be closed.*", ephemeral: true)
    next
  end

  selected = event.values.first
  label = APPLICATION_OPTIONS.find { |o| o[:value] == selected }&.dig(:label) || selected
  is_twitch = selected == 'twitch_mod'

  # Acknowledge immediately (ephemeral)
  event.respond(content: "📝 *Creating your application...*", ephemeral: true)

  # Create the private channel
  channel_name = "app-#{event.user.name.downcase.gsub(/[^a-z0-9]/, '')}-#{uid.to_s[-4..]}"
  server_id = TICKET_SERVER_ID

  permission_overwrites = [
    { id: server_id.to_s, type: 0, deny: TICKET_DENY_VIEW.to_s, allow: '0' },
    { id: uid.to_s, type: 1, allow: TICKET_VIEW_SEND.to_s, deny: '0' },
    { id: TICKET_STAFF_ROLE.to_s, type: 0, allow: TICKET_VIEW_SEND.to_s, deny: '0' }
  ]

  begin
    response = Discordrb::API.request(
      :guilds_gid_channels, server_id, :post,
      "#{Discordrb::API.api_base}/guilds/#{server_id}/channels",
      {
        name: channel_name,
        type: 0,
        parent_id: TICKET_CATEGORY_ID.to_s,
        topic: "Mod Application | #{label} | #{event.user.name} (#{uid})",
        permission_overwrites: permission_overwrites
      }.to_json,
      Authorization: $bot.token,
      content_type: :json
    )

    channel_data = JSON.parse(response.body)
    ticket_channel_id = channel_data['id']
    ACTIVE_TICKETS[uid] = ticket_channel_id.to_i

    # Build application questions based on type
    if is_twitch
      questions = "Please answer the following questions:\n\n" \
                  "**1.** What is your Twitch username?\n" \
                  "**2.** How long have you been watching the stream?\n" \
                  "**3.** Do you have any prior moderation experience? If so, where?\n" \
                  "**4.** What timezone are you in and what hours are you typically available?\n" \
                  "**5.** Why do you want to be a Twitch moderator?\n" \
                  "**6.** How would you handle a viewer being toxic in chat?\n" \
                  "**7.** Is there anything else you'd like us to know?"
    else
      questions = "Please answer the following questions:\n\n" \
                  "**1.** How long have you been a member of this Discord server?\n" \
                  "**2.** Do you have any prior Discord moderation experience? If so, where?\n" \
                  "**3.** What timezone are you in and what hours are you typically available?\n" \
                  "**4.** Why do you want to be a Discord moderator?\n" \
                  "**5.** How would you handle a conflict between two members?\n" \
                  "**6.** Are you familiar with Discord moderation tools (timeouts, bans, audit log)?\n" \
                  "**7.** Is there anything else you'd like us to know?"
    end

    emoji = is_twitch ? '🟣' : '🔵'

    # Send the application embed
    app_body = {
      content: '', flags: CV2_FLAG,
      components: [{
        type: 17, accent_color: is_twitch ? 0x9146FF : 0x5865F2,
        components: [
          { type: 10, content: "## #{emoji} #{label} Application" },
          { type: 14, spacing: 1 },
          { type: 10, content: "**Applicant:** #{event.user.mention}\n**Position:** #{label}\n**Application ID:** `#{channel_name}`\n\n#{questions}\n\n*Take your time answering. A staff member will review your application once submitted.*" },
          { type: 14, spacing: 1 },
          { type: 1, components: [
            { type: 2, style: 3, label: "Claim Application", custom_id: "ticket_claim_#{ticket_channel_id}", emoji: { name: '✋' } },
            { type: 2, style: 4, label: "Close Application", custom_id: "ticket_close_#{ticket_channel_id}_#{uid}", emoji: { name: '🔒' } }
          ]}
        ]
      }],
      allowed_mentions: { parse: ['users'] }
    }.to_json

    Discordrb::API.request(
      :channels_cid_messages_mid, ticket_channel_id, :post,
      "#{Discordrb::API.api_base}/channels/#{ticket_channel_id}/messages",
      app_body, Authorization: $bot.token, content_type: :json
    )

    # Ping staff
    Discordrb::API.request(
      :channels_cid_messages_mid, ticket_channel_id, :post,
      "#{Discordrb::API.api_base}/channels/#{ticket_channel_id}/messages",
      { content: "<@&#{TICKET_STAFF_ROLE}> — New mod application submitted!", allowed_mentions: { parse: ['roles'] } }.to_json,
      Authorization: $bot.token, content_type: :json
    )
  rescue => e
    puts "[APPLICATION CREATE ERROR] #{e.message}"
  end
end

# ==========================================
# CLAIM TICKET BUTTON
# ==========================================
$bot.button(custom_id: /^ticket_claim_\d+$/) do |event|
  # Only staff can claim
  is_staff = event.user.roles.any? { |r| r.id == TICKET_STAFF_ROLE } || DEV_IDS.include?(event.user.id)
  unless is_staff
    event.respond(content: "🔒 *Only staff members can claim tickets.*", ephemeral: true)
    next
  end

  ticket_channel_id = event.custom_id.split('_').last

  # Update the message to show who claimed it
  update_cv2(event, [{
    type: 17, accent_color: 0x00FF00,
    components: [
      { type: 10, content: "## ✅ Ticket Claimed" },
      { type: 14, spacing: 1 },
      { type: 10, content: "This ticket has been claimed by #{event.user.mention}.\n\nThey will be assisting you shortly. Please be patient!" },
      { type: 14, spacing: 1 },
      { type: 1, components: [
        { type: 2, style: 2, label: "Claimed by #{event.user.name}", custom_id: "ticket_claimed_noop", disabled: true, emoji: { name: '✅' } },
        { type: 2, style: 4, label: "Close Ticket", custom_id: "ticket_close_#{ticket_channel_id}_staff", emoji: { name: '🔒' } }
      ]}
    ]
  }])
end

# Noop for disabled claimed button
$bot.button(custom_id: 'ticket_claimed_noop') do |event|
  event.respond(content: "This ticket is already claimed!", ephemeral: true)
end

# ==========================================
# CLOSE TICKET BUTTON
# ==========================================
$bot.button(custom_id: /^ticket_close_\d+/) do |event|
  parts = event.custom_id.split('_')
  ticket_channel_id = parts[2]
  opener_id = parts[3] # Could be a uid or 'staff'

  # Only staff or the ticket opener can close
  is_staff = event.user.roles.any? { |r| r.id == TICKET_STAFF_ROLE } || DEV_IDS.include?(event.user.id)
  is_opener = opener_id != 'staff' && event.user.id.to_s == opener_id

  unless is_staff || is_opener
    event.respond(content: "🔒 *Only staff or the ticket opener can close this ticket.*", ephemeral: true)
    next
  end

  # Update the message first
  update_cv2(event, [{
    type: 17, accent_color: 0xFF0000,
    components: [
      { type: 10, content: "## 🔒 Ticket Closing..." },
      { type: 14, spacing: 1 },
      { type: 10, content: "This ticket is being closed by #{event.user.mention}.\n\n*Channel will be deleted in 10 seconds...*" }
    ]
  }])

  # Remove from active tickets
  ACTIVE_TICKETS.delete_if { |_uid, cid| cid.to_s == ticket_channel_id.to_s }

  # Delete the channel after a short delay
  Thread.new do
    sleep(10)
    begin
      Discordrb::API.request(
        :channels_cid, ticket_channel_id, :delete,
        "#{Discordrb::API.api_base}/channels/#{ticket_channel_id}",
        nil, Authorization: $bot.token
      )
    rescue => e
      puts "[TICKET DELETE ERROR] #{e.message}"
    end
  end
end
