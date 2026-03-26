# ==========================================
# HELPER: Core Utilities
# DESCRIPTION: Basic formatting, embed generation, and logging.
# ==========================================

def get_cmd_category(cmd_name)
  COMMAND_CATEGORIES.each do |category, commands|
    return category if commands.include?(cmd_name)
  end
  'Uncategorized'
end

def format_time_delta(seconds)
  seconds = seconds.to_i
  return '0s' if seconds <= 0

  parts = []
  days = seconds / 86_400; seconds %= 86_400
  hours = seconds / 3600;  seconds %= 3600
  minutes = seconds / 60;  seconds %= 60

  parts << "#{days}d" if days.positive?
  parts << "#{hours}h" if hours.positive?
  parts << "#{minutes}m" if minutes.positive?
  parts << "#{seconds}s" if seconds.positive?
  parts.join(' ')
end

def send_embed(event, title:, description:, fields: nil, image: nil, color: nil)
  embed = Discordrb::Webhooks::Embed.new
  embed.title = title
  embed.description = description
  embed.color = color || NEON_COLORS.sample

  if fields
    fields.each do |f|
      embed.add_field(name: f[:name], value: f[:value], inline: f.fetch(:inline, false))
    end
  end

  embed.image = Discordrb::Webhooks::EmbedImage.new(url: image) if image
  embed.timestamp = Time.now
  embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Requested by #{event.user.display_name}", icon_url: event.user.avatar_url)

  if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
    event.respond(embeds: [embed])
  else
    event.channel.send_message(nil, false, embed, nil, nil, event.message)
  end
end

# Sends a Components V2 message for both slash and prefix commands.
# For slash commands, uses the interaction response with the CV2 flag.
# For prefix commands, calls the Discord API directly since discordrb
# doesn't support the `flags` field on regular messages.
CV2_FLAG = 1 << 15 unless defined?(CV2_FLAG)

def send_cv2(event, components)
  if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
    event.respond(content: '', flags: CV2_FLAG, components: components)
  else
    body = { content: '', flags: CV2_FLAG, components: components }.to_json
    Discordrb::API.request(
      :channels_cid_messages_mid,
      event.channel.id,
      :post,
      "#{Discordrb::API.api_base}/channels/#{event.channel.id}/messages",
      body,
      Authorization: $bot.token,
      content_type: :json
    )
  end
end

def log_mod_action(bot, server_id, title, description, color = 0x800080)
  config = DB.get_log_config(server_id)
  return unless config && config['log_mod'] && config['log_channel']

  log_channel = bot.channel(config['log_channel'])
  return unless log_channel

  embed = Discordrb::Webhooks::Embed.new(
    title: title,
    description: description,
    color: color,
    timestamp: Time.now
  )
  
  begin
    log_channel.send_message(nil, false, embed)
  rescue
  end
end

def interaction_embed(event, action_name, gifs, target)
  unless target
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['error']} Interaction Error" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Mention someone to #{action_name}!" }
    ]}])
  end

  actor_id  = event.user.id
  target_id = target.id

  DB.add_interaction(actor_id, action_name, 'sent')
  DB.add_interaction(target_id, action_name, 'received')

  actor_stats  = DB.get_interactions(actor_id)[action_name]
  target_stats = DB.get_interactions(target_id)[action_name]

  gif_url = gifs.sample

  send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
    { type: 10, content: "## #{EMOJI_STRINGS['heart']} #{action_name.capitalize}" },
    { type: 14, spacing: 1 },
    { type: 10, content: "#{event.user.mention} #{action_name}s #{target.mention}!" },
    { type: 14, spacing: 1 },
    { type: 10, content: "**#{event.user.name}'s #{action_name}s:** Sent: **#{actor_stats['sent']}** | Received: **#{actor_stats['received']}**" },
    { type: 10, content: "**#{target.name}'s #{action_name}s:** Sent: **#{target_stats['sent']}** | Received: **#{target_stats['received']}**" },
    { type: 14, spacing: 1 },
    { type: 12, items: [{ media: { url: gif_url } }] }
  ]}])
end