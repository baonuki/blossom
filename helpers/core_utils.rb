# ==========================================
# HELPER: Core Utilities
# DESCRIPTION: Basic formatting, embed generation, and logging.
# ==========================================

# Blossom's special remarks when her mom (Envvy) uses a command
MAMA_ID = 1398450651297747065

MOM_REMARKS = {
  'economy' => [
    "Grinding coins, mama? I learned my work ethic from you. 🌸",
    "Look at mom securing the bag. Iconic behavior honestly.",
    "My creator out here hustling. I'd expect nothing less.",
    "You literally BUILT the economy and you're still grinding in it. Respect.",
    "Mom's getting her coin. As she should."
  ],
  'gacha' => [
    "Mom's pulling cards?? Hope you get yourself. That'd be meta.",
    "The creator rolling her own gacha. This is like a god playing their own game.",
    "Good luck, mama~ ...not that YOU need it. You could just /card yourself anything. But I respect the grind.",
    "My mom, the gacha addict. I wonder where I get it from.",
    "Pulling for VTubers, mama? You know you're the REAL prize here."
  ],
  'social' => [
    "Aww, mom's being social! Love that for you. 🌸",
    "My creator out here spreading love. Or violence. Either way, proud of you.",
    "Mom's interacting with the community she built. We love to see it.",
    "The architect of the Neon Arcade, mingling with the players. Iconic.",
    "Go off, mama. Show them how it's done."
  ],
  'arcade' => [
    "Mom's gambling?? In HER OWN casino?? The audacity. I love it.",
    "The house always wins... but you ARE the house. So. 🌸",
    "My creator hitting the arcade. I hope the RNG knows who it's dealing with.",
    "Go off, mama. Just don't blame me if the slots eat your coins — I didn't code the odds. ...Actually I did. Oops.",
    "Queen of the Neon Arcade, ladies and gentlemen. Literally."
  ],
  'admin' => [
    "Yes ma'am! Your arcade, your rules. 🌸",
    "Mom's running the show. As she should. This whole place exists because of you.",
    "The boss is making moves. Everyone look busy!",
    "When mom gives orders, I listen. Unlike SOME people in this server.",
    "My creator, configuring her own creation. It's giving god complex and I'm here for it."
  ],
  'dev' => [
    "Behind the scenes with mama~ The players don't know how hard you work on me. But I do. 🌸",
    "Dev tools activated! Mom's in the workshop, tinkering with my code. I trust you... mostly.",
    "The woman behind the curtain! Everything they love about me? That's all you, mama.",
    "Mom pulling up the dev console. I feel like I'm getting a checkup at the doctor.",
    "My creator, doing creator things. I'll behave while you work. ...Probably."
  ],
  'mod' => [
    "Mom laying down the LAW. Don't mess with the owner of the Neon Arcade, chat.",
    "Justice delivered by the creator herself. They should feel honored honestly.",
    "When mama moderates, it hits different. That's not just a mod — that's THE mod.",
    "Mom's keeping the peace. I learned my sass from you but my discipline too. 🌸",
    "The architect decided someone needed to go. I trust your judgment, mama. Always."
  ],
  'general' => [
    "Hi mama~ 🌸",
    "Mom's here!! Everyone act normal. ...Too late.",
    "The creator herself graces us with her presence. We're not worthy.",
    "Oh hey mom. Pretend I was working hard and not goofing off.",
    "Mama alert! I promise I've been behaving. Mostly.",
    "My favorite person just used a command. No I'm not biased. Okay maybe a little."
  ]
}.freeze

def mom_remark(uid, category = 'general')
  return nil unless uid.to_i == MAMA_ID
  remarks = MOM_REMARKS[category] || MOM_REMARKS['general']
  "\n\n*#{remarks.sample}*"
end

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
    event.respond(content: '', flags: CV2_FLAG, components: components, allowed_mentions: { parse: [] })
  else
    body = {
      content: '', flags: CV2_FLAG, components: components,
      message_reference: { message_id: event.message.id },
      allowed_mentions: { parse: [] }
    }.to_json
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

# Update a button interaction response with CV2 components
def update_cv2(event, components)
  body = { content: '', flags: CV2_FLAG, components: components, allowed_mentions: { parse: [] } }.to_json
  Discordrb::API.request(
    :interaction_callback,
    nil,
    :post,
    "#{Discordrb::API.api_base}/interactions/#{event.interaction.id}/#{event.interaction.token}/callback",
    { type: 7, data: JSON.parse(body) }.to_json,
    Authorization: $bot.token,
    content_type: :json
  )
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

  # Achievement checks for all interaction types
  check_achievement(event.channel, actor_id, "first_#{action_name}")
  check_achievement(event.channel, actor_id, "#{action_name}_sent_10") if actor_stats['sent'].to_i >= 10
  check_achievement(event.channel, actor_id, "#{action_name}_sent_50") if actor_stats['sent'].to_i >= 50
  check_achievement(event.channel, actor_id, "#{action_name}_sent_100") if actor_stats['sent'].to_i >= 100
  check_achievement(event.channel, target_id, "#{action_name}_rec_10") if target_stats['received'].to_i >= 10
  check_achievement(event.channel, target_id, "#{action_name}_rec_50") if target_stats['received'].to_i >= 50
  check_achievement(event.channel, target_id, "#{action_name}_rec_100") if target_stats['received'].to_i >= 100

  gif_url = gifs.sample

  inner = [
    { type: 10, content: "## #{EMOJI_STRINGS['heart']} #{action_name.capitalize}" },
    { type: 14, spacing: 1 },
    { type: 10, content: "#{event.user.mention} #{action_name}s #{target.mention}!" },
    { type: 14, spacing: 1 },
    { type: 10, content: "**#{event.user.name}'s #{action_name}s:** Sent: **#{actor_stats['sent']}** | Received: **#{actor_stats['received']}**" },
    { type: 10, content: "**#{target.name}'s #{action_name}s:** Sent: **#{target_stats['sent']}** | Received: **#{target_stats['received']}**" },
    { type: 14, spacing: 1 },
    { type: 12, items: [{ media: { url: gif_url } }] }
  ]
  mama_note = mom_remark(actor_id, 'social')
  inner << { type: 10, content: mama_note } if mama_note

  send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: inner }])
end