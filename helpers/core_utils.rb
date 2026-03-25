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

def send_embed(event, title:, description:, fields: nil, image: nil)
  embed = Discordrb::Webhooks::Embed.new
  embed.title = title
  embed.description = description
  embed.color = NEON_COLORS.sample
  
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

def log_mod_action(bot, server_id, title, description, color = 0x800080)
  config = DB.get_log_config(server_id)
  return unless config[:mod] && config[:channel]

  log_channel = bot.channel(config[:channel])
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
    return send_embed(event, title: "#{EMOJIS['error']} Interaction Error", description: "Mention someone to #{action_name}!")
  end

  actor_id  = event.user.id
  target_id = target.id

  DB.add_interaction(actor_id, action_name, 'sent')
  DB.add_interaction(target_id, action_name, 'received')

  actor_stats  = DB.get_interactions(actor_id)[action_name]
  target_stats = DB.get_interactions(target_id)[action_name]

  send_embed(
    event,
    title: "#{EMOJIS['heart']} #{action_name.capitalize}",
    description: "#{event.user.mention} #{action_name}s #{target.mention}!",
    fields: [
      { name: "#{event.user.name}'s #{action_name}s", value: "Sent: **#{actor_stats['sent']}**\nReceived: **#{actor_stats['received']}**", inline: true },
      { name: "#{target.name}'s #{action_name}s", value: "Sent: **#{target_stats['sent']}**\nReceived: **#{target_stats['received']}**", inline: true }
    ],
    image: gifs.sample
  )
end