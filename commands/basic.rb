# =========================
# BASIC COMMANDS (HYBRID)
# =========================

def execute_ping(event, timestamp)
  time_diff = Time.now - timestamp
  latency_ms = (time_diff * 1000).round 
  send_embed(event, title: "#{EMOJIS['play']} Pong!", description: "My connection to Discord is **#{latency_ms}ms**.\nChat is moving fast!")
end

bot.command(:ping, description: 'Check bot latency', category: 'Utility') { |e| execute_ping(e, e.message.timestamp); nil }
bot.application_command(:ping) { |e| execute_ping(e, (e.interaction.creation_time rescue Time.now)) }

def execute_kettle(event)
  if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
    event.respond(content: "#{EMOJIS['sparkle']} <@266358927401287680> #{EMOJIS['sparkle']}")
  else
    event.respond("#{EMOJIS['sparkle']} <@266358927401287680> #{EMOJIS['sparkle']}")
  end
end

bot.command(:kettle, description: 'Pings a specific user with a yay emoji', category: 'Fun') { |e| execute_kettle(e); nil }
bot.application_command(:kettle) { |e| execute_kettle(e) }

def execute_help(event)
  embed = generate_category_embed(event.bot, event.user, 'Home')
  view = help_select_menu(event.user.id)

  if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
    event.respond(embeds: [embed], components: view)
  else
    event.channel.send_message(nil, false, embed, nil, nil, nil, view)
  end
end

bot.command(:help, description: 'Shows the interactive help menu', category: 'Utility') do |event|
  execute_help(event)
  nil
end

bot.application_command(:help) do |event|
  execute_help(event)
end

def execute_about(event)
  fields = [
    { name: "#{EMOJIS['play']} The Content Grind", value: "We are on that monetization grind! I manage the server's economy so you can earn #{EMOJIS['s_coin']} by hitting that `b!stream` button, getting engagement with a quick `b!post` on socials, or doing a `b!collab` with other chatters.", inline: false },
    { name: "#{EMOJIS['sparkle']} VTuber Gacha", value: "Spend your hard-earned stream revenue to `b!summon` your favorite VTubers! Will you pull common indie darlings, or hit the legendary RNG for Gura, Calli, or Ironmouse? Build your `b!collection` and flex your pulls!", inline: false },
    { name: "#{EMOJIS['like']} Just Chatting & Vibes", value: "Lurkers don't get XP here! I track your chat activity and reward you with levels the more you type. Plus, you can `b!hug` your friends or `b!slap` a troll.", inline: false },
    { name: "#{EMOJIS['bomb']} A Little Bit of Trolling", value: "Sometimes chat gets too cozy, so the admins let me drop a literal `b!bomb` in the channel. You have to scramble to defuse it for a massive coin payout, or the whole chat goes BOOM!", inline: false },
    { name: "#{EMOJIS['developer']} Behind the Scenes", value: "Blossom is a Kyvrixon Dev. product. Developed by **en.vvy** and written in **.rb** (Ruby).", inline: false }
  ]
  send_embed(event, title: "#{EMOJIS['heart']} About Blossom", description: "Hey Chat! I'm **Blossom**, your server's dedicated head mod, hype-woman, and resident gacha addict. I'm here to turn your Discord server into the ultimate content creator community.\n\nDrop a `/help` in chat and let's go live! #{EMOJIS['stream']}#{EMOJIS['neonsparkle']}", fields: fields)
end

bot.command(:about, description: 'Learn more about Blossom!', category: 'Utility') { |e| execute_about(e); nil }
bot.application_command(:about) { |e| execute_about(e) }

def execute_support(event)
  send_embed(event, title: "🛠️ Support Server", description: "Need assistance, have questions, or want to report a bug?\nJoin the Tsukiyo Server here:\n\n**https://discord.gg/tsukiyo**")
end

bot.command(:support, description: 'Get a link to the official support server', category: 'Utility') { |e| execute_support(e); nil }
bot.application_command(:support) { |e| execute_support(e) }

def execute_premium(event)
  desc = "Support Blossom's development and unlock amazing global perks!\n\n"
  desc += "**💎 Premium Bonuses:**\n"
  desc += "⏱️ **50% Faster Cooldowns** on `!work`, `!stream`, and `!post`\n"
  desc += "💰 **+10% Coin Boost** from all sources (daily, work, streams, bombs, collabs!)\n"
  desc += "🍀 **Boosted Gacha Odds** (Much higher chance to pull Rares, Legendaries, and Goddesses)\n"
  desc += "✨ **1% Secret Chance** to instantly pull a Shiny Ascended character from the portal!\n\n"
  desc += "To unlock these perks, join the Tsukiyo Server and boost it!:\n**https://discord.gg/tsukiyo**"
  send_embed(event, title: "💎 Blossom Premium", description: desc)
end

bot.command(:premium, description: 'View the benefits of Blossom Premium!', category: 'Utility') { |e| execute_premium(e); nil }
bot.application_command(:premium) { |e| execute_premium(e) }

def execute_interactions(event)
  data = DB.get_interactions(event.user.id)
  send_embed(event, title: "#{event.user.display_name}'s Interaction Stats", description: '', fields: [
    { name: "#{EMOJIS['hearts']} Hugs", value: "Sent: **#{data['hug']['sent']}**\nReceived: **#{data['hug']['received']}**", inline: true },
    { name: "#{EMOJIS['bonk']} Slaps", value: "Sent: **#{data['slap']['sent']}**\nReceived: **#{data['slap']['received']}**", inline: true }
  ])
end

bot.command(:interactions, description: 'Show your hug/slap stats', category: 'Fun') { |e| execute_interactions(e); nil }
bot.application_command(:interactions) { |e| execute_interactions(e) }

def execute_hug(event, target)
  if target.nil?
    return send_embed(event, title: "#{EMOJIS['error']} Interaction Error", description: "Mention someone to hug!")
  end

  if target.id == event.bot.profile.id
    DB.add_interaction(event.user.id, 'hug', 'sent')
    DB.add_interaction(target.id, 'hug', 'received')
    DB.add_interaction(target.id, 'hug', 'sent')
    DB.add_interaction(event.user.id, 'hug', 'received')

    actor_stats = DB.get_interactions(event.user.id)['hug']
    bot_stats   = DB.get_interactions(target.id)['hug']

    send_embed(event, title: "🫂 Hugs for Blossom!", description: "Aww, thanks for the love, #{event.user.mention}! Chat's been crazy today, I needed that.\n\n*Blossom hugs you back tightly!*", fields: [
      { name: "#{event.user.name}'s Hugs", value: "Sent: **#{actor_stats['sent']}**\nReceived: **#{actor_stats['received']}**", inline: true },
      { name: "Blossom's Hugs", value: "Sent: **#{bot_stats['sent']}**\nReceived: **#{bot_stats['received']}**", inline: true }
    ], image: HUG_GIFS.sample)
  else
    interaction_embed(event, 'hug', HUG_GIFS, target)
  end
end

bot.command(:hug, description: 'Send a hug with a random GIF', category: 'Fun') do |event|
  execute_hug(event, event.message.mentions.first)
  nil
end

bot.application_command(:hug) do |event|
  target_id = event.options['user']
  target = event.bot.user(target_id.to_i) if target_id
  execute_hug(event, target)
end

def execute_slap(event, target)
  if target.nil?
    return send_embed(event, title: "#{EMOJIS['error']} Interaction Error", description: "Mention someone to slap!")
  end

  if target.id == event.bot.profile.id
    DB.add_interaction(event.user.id, 'slap', 'sent')
    DB.add_interaction(target.id, 'slap', 'received')
    DB.add_interaction(target.id, 'slap', 'sent')
    DB.add_interaction(event.user.id, 'slap', 'received')

    actor_stats = DB.get_interactions(event.user.id)['slap']
    bot_stats   = DB.get_interactions(target.id)['slap']

    send_embed(event, title: "💢 Bot Abuse Detected!", description: "Hey! #{event.user.mention} just slapped me?! Chat, clip that! That is literal bot abuse.\n\n*Blossom smacks you right back!*", fields: [
      { name: "#{event.user.name}'s Slaps", value: "Sent: **#{actor_stats['sent']}**\nReceived: **#{actor_stats['received']}**", inline: true },
      { name: "Blossom's Slaps", value: "Sent: **#{bot_stats['sent']}**\nReceived: **#{bot_stats['received']}**", inline: true }
    ], image: SLAP_GIFS.sample)
  else
    interaction_embed(event, 'slap', SLAP_GIFS, target)
  end
end

bot.command(:slap, description: 'Send a playful slap with a random GIF', category: 'Fun') do |event|
  execute_slap(event, event.message.mentions.first)
  nil
end

bot.application_command(:slap) do |event|
  target_id = event.options['user']
  target = event.bot.user(target_id.to_i) if target_id
  execute_slap(event, target)
end

def execute_giveaway(event, channel_id, time_str, prize)
  unless event.user.permission?(:administrator, event.channel) || event.user.id == DEV_ID
    return send_embed(event, title: "❌ Permission Denied", description: 'You need Administrator permissions to start a giveaway!')
  end

  target_channel = event.bot.channel(channel_id, event.server)
  unless target_channel
    return send_embed(event, title: "⚠️ Error", description: "I couldn't find that channel!")
  end

  duration = 0
  if time_str =~ /^(\d+)(m|h|d)$/i
    amount = $1.to_i
    unit = $2.downcase
    duration = amount * 60 if unit == 'm'
    duration = amount * 3600 if unit == 'h'
    duration = amount * 86400 if unit == 'd'
  else
    return send_embed(event, title: "⚠️ Invalid Time Format", description: "Example: `10m` or `2d`")
  end

  expire_time = Time.now + duration
  giveaway_id = "gw_#{expire_time.to_i}_#{rand(10000)}"
  discord_timestamp = "<t:#{expire_time.to_i}:R>"

  embed = Discordrb::Webhooks::Embed.new(
    title: "🎉 **GIVEAWAY: #{prize}** 🎉",
    description: "Hosted by: #{event.user.mention}\nEnds: **#{discord_timestamp}**\n\nClick the button below to enter!",
    color: 0xFFD700 
  )

  view = Discordrb::Components::View.new do |v|
    v.row { |r| r.button(custom_id: giveaway_id, label: 'Enter Giveaway', style: :success, emoji: '🎉') }
  end

  msg = target_channel.send_message(nil, false, embed, nil, nil, nil, view)
  DB.create_giveaway(giveaway_id, target_channel.id, msg.id, event.user.id, prize, expire_time.to_i)
  
  if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
    event.respond(content: "✅ Giveaway successfully saved to the database and started in #{target_channel.mention}!")
  else
    event.respond("✅ Giveaway successfully saved to the database and started in #{target_channel.mention}!")
  end
end

bot.command(:giveaway, description: 'Start a giveaway (Admin only)', min_args: 3, usage: 'b!giveaway #channel 10m Prize Name', category: 'Admin') do |event, channel_mention, time_str, *prize_args|
  channel_id = channel_mention.gsub(/[^0-9]/, '').to_i
  prize = prize_args.join(' ')
  execute_giveaway(event, channel_id, time_str, prize)
  nil
end

bot.application_command(:giveaway) do |event|
  channel_id = event.options['channel'].to_i
  time_str = event.options['time']
  prize = event.options['prize']
  execute_giveaway(event, channel_id, time_str, prize)
end

def execute_serverinfo(event)
  unless event.server
    return send_embed(event, title: "⚠️ Error", description: "This command can only be used inside a server!")
  end

  server = event.server
  owner = server.owner
  
  created_time = server.creation_time.to_i

  fields = [
    { name: '👑 Server Owner', value: owner ? owner.mention : "Unknown", inline: true },
    { name: '👥 Total Members', value: server.member_count.to_s, inline: true },
    { name: '📅 Created On', value: "<t:#{created_time}:D> (<t:#{created_time}:R>)", inline: false }
  ]

  send_embed(
    event, 
    title: "📊 #{server.name} - Server Info", 
    description: "Here are the stats for **#{server.name}**:", 
    fields: fields,
    image: server.icon_url
  )
end

bot.command(:serverinfo, description: 'Displays information about the current server', category: 'Utility') { |e| execute_serverinfo(e); nil }
bot.application_command(:serverinfo) { |e| execute_serverinfo(e) }

def execute_suggest(event, suggestion_text)
  if suggestion_text.nil? || suggestion_text.strip.empty?
    return send_embed(event, title: "⚠️ Missing Suggestion", description: "Please tell me what you'd like to suggest!\nExample: `#{PREFIX}suggest Add a fishing minigame!`")
  end

  dev_user = event.bot.user(DEV_ID)

  unless dev_user
    return send_embed(event, title: "❌ Error", description: "I couldn't find my developer in my cache! Try again later.")
  end

  server_name = event.server ? event.server.name : "Direct Messages"
  
  dev_embed = Discordrb::Webhooks::Embed.new(
    title: "💡 New Bot Suggestion",
    description: "**From:** #{event.user.mention} *(#{event.user.distinct})*\n**Server:** #{server_name}\n\n**Suggestion:**\n#{suggestion_text}",
    color: 0xFFD700, # Gold
    timestamp: Time.now
  )
  dev_embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "User ID: #{event.user.id}")

  begin
    pm_channel = dev_user.pm
    pm_channel.send_message(nil, false, dev_embed)
    
    send_embed(event, title: "✅ Suggestion Sent!", description: "Thank you! Your suggestion has been sent directly to my developer. 🌸")
  rescue => e
    puts "[SUGGEST ERROR] #{e.message}"
    send_embed(event, title: "❌ Delivery Failed", description: "I couldn't send the suggestion. My developer might have their DMs closed right now!")
  end
end

bot.command(:suggest, description: 'Send a suggestion directly to the developer!', category: 'Utility') do |event, *args|
  execute_suggest(event, args.join(' '))
  nil
end

bot.application_command(:suggest) do |event|
  execute_suggest(event, event.options['suggestion'])
end