require 'discordrb'
require 'dotenv/load'

# =========================
# BOT SETUP
# =========================

puts "[SYSTEM] Checking voice engine..."
begin
  if defined?(Discordrb::Voice)
    puts "✅  Voice Engine: Ready"
  else
    puts "❌  Voice Engine: Missing (libsodium/sodium.dll not found)"
  end
rescue LoadError => e
  puts "❌  Voice Engine: Load Error - #{e.message}"
end

# =========================
# LOAD CONFIG DATA & DATABASE
# =========================
require_relative 'data/config'
require_relative 'data/pools'
require_relative 'data/database'

# =========================
# DATA STRUCTURES
# =========================
SERVER_BOMB_CONFIGS = DB.load_all_bomb_configs
ACTIVE_BOMBS       = {} 
ACTIVE_COLLABS     = {}
ACTIVE_TRADES      = {}

COMMAND_CATEGORIES = {
  'Economy'   => [:balance, :daily, :work, :stream, :post, :collab, :cooldowns, :coinlb],
  'Gacha'     => [:summon, :collection, :banner, :shop, :buy, :view, :ascend, :trade],
  'Arcade'    => [:coinflip, :slots, :roulette, :scratch, :dice, :cups],
  'Fun'       => [:kettle, :level, :leaderboard, :hug, :slap, :interactions],
  'Utility'   => [:ping, :help, :about, :support, :premium, :call, :dismiss],
  'Admin'     => [:setlevel, :enablebombs, :disablebombs, :levelup, :addxp, :bomb, :giveaway],
  'Developer' => [:addcoins, :setcoins, :blacklist, :card, :backup, :givepremium, :removepremium]
}.freeze

def get_cmd_category(cmd_name)
  COMMAND_CATEGORIES.each do |category, commands|
    return category if commands.include?(cmd_name)
  end
  'Uncategorized'
end

# =========================
# BOT HELPERS
# =========================

def roll_rarity(premium = false)
  roll = rand(100)
  
  premium_table = { common: 42, rare: 41, legendary: 15, goddess: 2 }
  
  active_table = premium ? premium_table : RARITY_TABLE
  
  total = 0
  active_table.each do |(rarity, weight)|
    total += weight
    return rarity if roll < total
  end
  :common
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

def get_current_banner
  week_number = Time.now.to_i / 604_800 
  available_pools = CHARACTER_POOLS.keys
  active_key = available_pools[week_number % available_pools.size]
  CHARACTER_POOLS[active_key]
end

def generate_collection_page(user_obj, rarity_page)
  uid = user_obj.id
  chars = DB.get_collection(uid)
  
  page_chars = chars.select { |_, data| data['rarity'] == rarity_page && (data['count'] > 0 || data['ascended'].to_i > 0) }
  
  total_collected = page_chars.size
  total_available = TOTAL_UNIQUE_CHARS[rarity_page]
  
  emoji = case rarity_page
          when 'goddess'   then '💎'
          when 'legendary' then '🌟'
          when 'rare'      then '✨'
          else '⭐'
          end
          
  desc = "You have collected **#{total_collected} / #{total_available}** unique #{rarity_page.capitalize} characters.\n\n"
  
  if page_chars.empty?
    desc += "*You haven't pulled any characters of this rarity yet!*"
  else
    list = page_chars.map do |name, data|
      str = "`#{name}` (x#{data['count']})"
      str += " ✨*(Ascended x#{data['ascended']})*" if data['ascended'].to_i > 0
      str
    end
    desc += list.join(', ')
  end
  
  embed = Discordrb::Webhooks::Embed.new
  embed.title = "#{emoji} #{user_obj.display_name}'s Collection - #{rarity_page.capitalize}"
  embed.description = desc
  embed.color = NEON_COLORS.sample
  embed
end

def collection_view(target_uid, current_page)
  user_chars = DB.get_collection(target_uid)
  owns_goddess = user_chars.values.any? { |data| data['rarity'] == 'goddess' && data['count'] > 0 }

  Discordrb::Components::View.new do |v|
    v.row do |r|
      r.button(custom_id: "coll_common_#{target_uid}", label: 'Common', style: current_page == 'common' ? :success : :secondary, emoji: '⭐', disabled: current_page == 'common')
      r.button(custom_id: "coll_rare_#{target_uid}", label: 'Rare', style: current_page == 'rare' ? :success : :secondary, emoji: '✨', disabled: current_page == 'rare')
      r.button(custom_id: "coll_legendary_#{target_uid}", label: 'Legendary', style: current_page == 'legendary' ? :success : :secondary, emoji: '🌟', disabled: current_page == 'legendary')
      if owns_goddess
        r.button(custom_id: "coll_goddess_#{target_uid}", label: 'Goddess', style: current_page == 'goddess' ? :success : :secondary, emoji: '💎', disabled: current_page == 'goddess')
      end
    end
  end
end

def generate_help_page(bot, user_obj, page_number)
  grouped_commands = bot.commands.values.group_by { |cmd| get_cmd_category(cmd.name) }
  category_order = COMMAND_CATEGORIES.keys + ['Uncategorized']
  
  pages = []
  category_order.each do |category|
    next unless grouped_commands[category] 
    cmds = grouped_commands[category].sort_by(&:name)
    cmds.each_slice(10).with_index do |slice, index|
      pages << { category: category, commands: slice, part: index + 1, total_parts: (cmds.size / 10.0).ceil }
    end
  end

  total_pages = pages.size
  total_pages = 1 if total_pages < 1
  page_number = 1 if page_number < 1
  page_number = total_pages if page_number > total_pages

  active_page = pages[page_number - 1]
  command_lines = active_page[:commands].map { |cmd| "> `#{PREFIX}#{cmd.name}` - #{cmd.attributes[:description] || 'No description provided.'}" }

  cat_name = active_page[:category]
  cat_name += " (Pt. #{active_page[:part]})" if active_page[:total_parts] > 1

  embed = Discordrb::Webhooks::Embed.new
  embed.title = "#{EMOJIS['info']} Bot Help Menu - #{cat_name}"
  embed.description = "Use `#{PREFIX}` before any command!\n\n**Menu Page #{page_number} of #{total_pages}**"
  embed.color = NEON_COLORS.sample
  embed.add_field(name: '📜 Commands', value: command_lines.join("\n"), inline: false)
  embed.timestamp = Time.now
  embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Requested by #{user_obj.display_name}")

  [embed, total_pages, page_number]
end

def help_view(target_uid, current_page, total_pages)
  Discordrb::Components::View.new do |v|
    v.row do |r|
      r.button(custom_id: "helpnav_#{target_uid}_#{current_page - 1}", label: 'Previous', style: :primary, emoji: '◀️', disabled: current_page <= 1)
      r.button(custom_id: "helpnav_#{target_uid}_#{current_page + 1}", label: 'Next', style: :primary, emoji: '▶️', disabled: current_page >= total_pages)
    end
  end
end

def find_character_in_pools(search_name)
  CHARACTER_POOLS.values.each do |pool|
    pool[:characters].each do |rarity, char_list|
      found = char_list.find { |c| c[:name].downcase == search_name.downcase }
      return { char: found, rarity: rarity.to_s } if found
    end
  end
  nil
end

def build_shop_home(user_id)
  embed = Discordrb::Webhooks::Embed.new
  embed.title = "#{EMOJIS['rich']} The VTuber Black Market"
  embed.description = "Tired of bad gacha luck? Save up your stream revenue and buy exactly who you want!\n\n" \
                      "⭐ **Common:** #{SHOP_PRICES['common']} #{EMOJIS['s_coin']} *(Sells for #{SELL_PRICES['common']})*\n" \
                      "✨ **Rare:** #{SHOP_PRICES['rare']} #{EMOJIS['s_coin']} *(Sells for #{SELL_PRICES['rare']})*\n" \
                      "🌟 **Legendary:** #{SHOP_PRICES['legendary']} #{EMOJIS['s_coin']} *(Sells for #{SELL_PRICES['legendary']})*\n\n" \
                      "Use `#{PREFIX}buy <Name>` to purchase characters or tech upgrades!"
  embed.color = NEON_COLORS.sample
  embed.image = Discordrb::Webhooks::EmbedImage.new(url: 'https://media.discordapp.net/attachments/1475890017443516476/1476244926638592050/d60459-53-0076f9af74811878db01-0.jpg?ex=69a06bb9&is=699f1a39&hm=a5769b33a3b669e67f439bad467b90c1a9681f8d3a1e975bb048b79d521ec929&=&format=webp')

  view = Discordrb::Components::View.new do |v|
    v.row do |r|
      r.button(custom_id: "shop_catalog_#{user_id}_1", label: 'View Catalog', style: :primary, emoji: '📖')
      r.button(custom_id: "shop_blackmarket_#{user_id}", label: 'Tech Upgrades', style: :success, emoji: '🛒')
      r.button(custom_id: "shop_sell_#{user_id}", label: 'Sell Duplicates', style: :danger, emoji: '♻️')
    end
  end
  [embed, view]
end

def build_shop_catalog(user_id, page)
  rarities = ['common', 'rare', 'legendary']
  target_rarity = rarities[page - 1]

  chars = []
  CHARACTER_POOLS.values.each { |pool| chars.concat(pool[:characters][target_rarity.to_sym].map { |c| c[:name] }) }
  chars = chars.uniq.sort

  emoji = case target_rarity
          when 'legendary' then '🌟'
          when 'rare'      then '✨'
          else '⭐'
          end

  embed = Discordrb::Webhooks::Embed.new
  embed.title = "📖 Shop Catalog - #{target_rarity.capitalize}s #{emoji}"
  embed.description = "Price: **#{SHOP_PRICES[target_rarity]}** #{EMOJIS['s_coin']} each.\n\n`" + chars.join("`, `") + "`"
  embed.color = NEON_COLORS.sample
  embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Catalog Page #{page} of 3")

  view = Discordrb::Components::View.new do |v|
    v.row do |r|
      r.button(custom_id: "shop_catalog_#{user_id}_#{page - 1}", label: 'Previous', style: :primary, emoji: '◀️', disabled: page <= 1)
      r.button(custom_id: "shop_home_#{user_id}", label: 'Back to Shop', style: :secondary, emoji: '🔙')
      r.button(custom_id: "shop_catalog_#{user_id}_#{page + 1}", label: 'Next', style: :primary, emoji: '▶️', disabled: page >= 3)
    end
  end
  [embed, view]
end

def build_blackmarket_page(user_id)
  desc = "Welcome to the underground tech shop. Use `#{PREFIX}buy <Item Name>` to purchase.\n\n"
  
  desc += "**🖥️ Stream Upgrades (Permanent)**\n"
  BLACK_MARKET_ITEMS.each do |key, data|
    if data[:type] == 'upgrade'
      desc += "`#{key}` — **#{data[:name]}** (#{data[:price]} #{EMOJIS['s_coin']})\n> *#{data[:desc]}*\n"
    end
  end

  desc += "\n**🎒 Consumables (One-Time Use)**\n"
  BLACK_MARKET_ITEMS.each do |key, data|
    if data[:type] == 'consumable'
      desc += "`#{key}` — **#{data[:name]}** (#{data[:price]} #{EMOJIS['s_coin']})\n> *#{data[:desc]}*\n"
    end
  end

  embed = Discordrb::Webhooks::Embed.new
  embed.title = "🛒 The Black Market"
  embed.description = desc
  embed.color = NEON_COLORS.sample

  view = Discordrb::Components::View.new do |v|
    v.row do |r|
      r.button(custom_id: "shop_home_#{user_id}", label: 'Back to Shop', style: :secondary, emoji: '🔙')
    end
  end
  [embed, view]
end

# =========================
# PREMIUM SYSTEM
# =========================

# Server IDs => Role IDs 
PREMIUM_SERVERS = {
  1475696989059420162 => 1477110574419808306,
  1472509438010065070 => 1477179978004041788  
}

def is_premium?(bot, user_id)
  return true if DB.is_lifetime_premium?(user_id)

  PREMIUM_SERVERS.each do |server_id, role_id|
    server = bot.server(server_id)
    next unless server

    member = server.members.find { |m| m.id == user_id }
    next unless member

    return true if member.roles.any? { |role| role.id == role_id }
  end

  false
end

def award_coins(bot, user_id, amount)
  final_amount = amount
  
  final_amount = (amount * 1.10).round if is_premium?(bot, user_id)
  
  DB.add_coins(user_id, final_amount)
  
  final_amount 
end

# =========================
# BOT SETUP
# =========================

bot = Discordrb::Commands::CommandBot.new(
  token: ENV['TOKEN'],
  prefix: PREFIX,
  intents: [:servers, :server_messages, :server_members, :server_voice_states]
)

bot.button(custom_id: /^menu_/) do |event|
  _, action, owner_id = event.custom_id.split('_')

  if event.user.id.to_s != owner_id
    event.respond(content: "🌸 *This isn't your menu! Run your own balance command to see your stats.*", ephemeral: true)
    next
  end

  uid = event.user.id
  username = event.user.display_name

  new_embed = Discordrb::Webhooks::Embed.new(color: 0xFFB6C1)
  view = Discordrb::Components::View.new

  case action
  when 'home'
    coins = DB.get_coins(uid)
    new_embed.title = "🌸 #{username}'s Balance"
    new_embed.description = "**Coins:** #{coins} #{EMOJIS['s_coin']}\n\n*Click the buttons below to view your items and VTubers!*"
    
    view.row do |r|
      r.button(custom_id: "menu_home_#{uid}", label: 'Balance', style: :secondary, emoji: '💰', disabled: true)
      r.button(custom_id: "menu_inv_#{uid}", label: 'Inventory', style: :primary, emoji: '🎒')
      r.button(custom_id: "menu_vtubers_#{uid}", label: 'VTuber Totals', style: :success, emoji: '🌟')
    end

  when 'inv'
    inv = DB.get_inventory(uid)
    new_embed.title = "🎒 #{username}'s Inventory"

    if inv.empty?
      new_embed.description = "*Your inventory is completely empty!*"
    else
      upgrades = []
      consumables = []

      # Exact matches from your Stream Upgrades market list
      upgrade_keywords = ['headset', 'keyboard', 'mic', 'neon sign', 'gacha pass']

      inv.each do |item, count|
        is_upgrade = upgrade_keywords.any? { |kw| item.downcase.include?(kw) }
        if is_upgrade
          upgrades << "**#{item}**: #{count}"
        else
          consumables << "**#{item}**: #{count}"
        end
      end

      desc = ""
      unless upgrades.empty?
        desc += "🎙️ **Stream Upgrades (Permanent)**\n" + upgrades.join("\n") + "\n\n"
      end
      unless consumables.empty?
        desc += "💊 **Consumables (One-Time Use)**\n" + consumables.join("\n")
      end

      new_embed.description = desc.strip
    end

    view.row do |r|
      r.button(custom_id: "menu_home_#{uid}", label: 'Balance', style: :secondary, emoji: '💰')
      r.button(custom_id: "menu_inv_#{uid}", label: 'Inventory', style: :primary, emoji: '🎒', disabled: true)
      r.button(custom_id: "menu_vtubers_#{uid}", label: 'VTuber Totals', style: :success, emoji: '🌟')
    end

  when 'vtubers', 'cards' # Catches 'cards' just in case old buttons are still in chat!
    col = DB.get_collection(uid)
    new_embed.title = "🌟 #{username}'s VTuber Collection"

    if col.empty?
      new_embed.description = "*You haven't pulled any VTubers yet!*"
    else
      unique_vtubers = col.keys.size
      unique_ascended = 0

      rarity_counts = Hash.new(0)
      ascended_rarity_counts = Hash.new(0)

      col.each do |name, data|
        r = data['rarity']
        count = data['count']
        ascended = data['ascended']

        rarity_counts[r] += count
        if ascended > 0
          unique_ascended += 1
          ascended_rarity_counts[r] += ascended
        end
      end

      # THE FIX: This array forces Ruby to sort in this exact order!
      rarity_order = ['common', 'rare', 'legendary', 'goddess']
      
      # Any rarity not in the list gets pushed to the bottom (index 99)
      sorted_rarity = rarity_counts.sort_by { |r, _| rarity_order.index(r.downcase) || 99 }
      sorted_ascended = ascended_rarity_counts.sort_by { |r, _| rarity_order.index(r.downcase) || 99 }

      desc = "✨ **Unique VTubers:** #{unique_vtubers}\n"
      desc += "🌟 **Unique Ascended:** #{unique_ascended}\n\n"

      desc += "📊 **Total by Rarity:**\n"
      sorted_rarity.each { |r, c| desc += "• #{r.capitalize}: **#{c}**\n" }

      if sorted_ascended.any?
        desc += "\n🔥 **Ascended by Rarity:**\n"
        sorted_ascended.each { |r, c| desc += "• #{r.capitalize}: **#{c}**\n" }
      end

      new_embed.description = desc.strip
    end

    view.row do |r|
      r.button(custom_id: "menu_home_#{uid}", label: 'Balance', style: :secondary, emoji: '💰')
      r.button(custom_id: "menu_inv_#{uid}", label: 'Inventory', style: :primary, emoji: '🎒')
      r.button(custom_id: "menu_vtubers_#{uid}", label: 'VTuber Totals', style: :success, emoji: '🌟', disabled: true)
    end
  end

  event.update_message(embeds: [new_embed], components: view)
end

# =========================
# LOAD COMMANDS
# =========================
eval(File.read(File.join(__dir__, 'commands/basic.rb')), binding)
eval(File.read(File.join(__dir__, 'commands/economy.rb')), binding)
eval(File.read(File.join(__dir__, 'commands/gacha.rb')), binding)
eval(File.read(File.join(__dir__, 'commands/arcade.rb')), binding)
eval(File.read(File.join(__dir__, 'commands/trade.rb')), binding)
eval(File.read(File.join(__dir__, 'commands/developer.rb')), binding)
eval(File.read(File.join(__dir__, 'commands/leveling.rb')), binding)

# =========================
# LOAD EVENTS (Background Logic)
# =========================
eval(File.read(File.join(__dir__, 'events/leveling.rb')), binding)
eval(File.read(File.join(__dir__, 'events/economy.rb')), binding)
eval(File.read(File.join(__dir__, 'events/gacha.rb')), binding)
eval(File.read(File.join(__dir__, 'events/trade.rb')), binding)
eval(File.read(File.join(__dir__, 'events/basic.rb')), binding)

# =========================
# RUN
# =========================

bot.ready do
  puts "Blossom is connected and live!"
  
  Thread.new do
    storage_server_id  = 1475696989059420162
    storage_channel_id = 1476943608702832680
    
    loop do
      begin
        storage_channel = bot.channel(storage_channel_id, storage_server_id)
        
        if storage_channel
          db_file = "blossom.db"
          if File.exist?(db_file)
            timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')
            
            storage_channel.send_message("📦 **Automated Daily Backup**\nTimestamp: `#{timestamp}`")
            File.open(db_file, 'rb') { |file| storage_channel.send_file(file) }
            
            puts "[SYSTEM] Daily backup sent to storage channel."
          end
        else
          puts "[ERROR] Backup failed: Could not find storage channel."
        end
      rescue => e
        puts "[BACKUP ERROR] #{e.message}"
      end

      sleep 86400
    end
  end

  Thread.new do
    loop do
      begin
        bot.playing = "#{PREFIX}help in the Arcade 🕹️"
        sleep 15

        server_count = bot.servers.size
        total_members = bot.servers.values.sum { |server| server.member_count }
        bot.playing = "with #{total_members} chatters in #{server_count} servers 🔴| b!"
        sleep 15
      rescue => e
        sleep 5 
      end
    end
  end

  Thread.new do
  loop do
    sleep 10 
    now = Time.now.to_i
    
    DB.get_active_giveaways.each do |gw|
      if now >= gw['end_time'].to_i
        gw_id = gw['id']
        
        begin
          # Postgres returns BIGINTs as strings, so we MUST .to_i the IDs!
          channel = bot.channel(gw['channel_id'].to_i)
          next unless channel

          entrants = DB.get_giveaway_entrants(gw_id)
          
          begin
            msg = channel.message(gw['message_id'].to_i)
          rescue
            msg = nil
          end

          ended_embed = Discordrb::Webhooks::Embed.new(
            title: "🎉 **GIVEAWAY ENDED: #{gw['prize']}** 🎉",
            color: 0x808080
          )

          if entrants.empty?
            ended_embed.description = "Hosted by: <@#{gw['host_id']}>\n\nNobody entered the giveaway! 😢"
            msg.edit(nil, ended_embed, Discordrb::Components::View.new) if msg
            channel.send_message("The giveaway for **#{gw['prize']}** ended, but nobody entered!")
          else
            winner_id = entrants.sample
            winner_mention = "<@#{winner_id}>"
            ended_embed.description = "Hosted by: <@#{gw['host_id']}>\nWinner: #{winner_mention}\nTotal Entrants: **#{entrants.size}**"
            msg.edit(nil, ended_embed, Discordrb::Components::View.new) if msg
            channel.send_message("Congratulations #{winner_mention}! You won the **#{gw['prize']}**! 🎉")
          end
          
          DB.delete_giveaway(gw_id)
          
        rescue StandardError => e
          # This catches 403 Forbidden or any other weird Discord API crashes
          puts "⚠️ Cleaned up broken giveaway #{gw_id} - #{e.message}"
          DB.delete_giveaway(gw_id)
        end
      end
    end
  end
end

  DB.get_blacklist.each do |uid|
    bot.ignore_user(uid)
  end
end

puts "Registering slash commands to Discord API..."

# --- REGISTER SLASH COMMANDS ---

# puts "Registering slash commands to Discord API..."
# bot.register_application_command(:ping, 'Check bot latency')
# bot.register_application_command(:kettle, 'Pings a specific user with a yay emoji')
# bot.register_application_command(:help, 'Shows a paginated list of all available commands')
# bot.register_application_command(:about, 'Learn more about Blossom and her creator!')
# bot.register_application_command(:interactions, 'Show your hug/slap stats')
# bot.register_application_command(:support, 'Get a link to the official support server')
# bot.register_application_command(:premium, 'View the benefits of Blossom Premium!')

# bot.register_application_command(:hug, 'Send a hug with a random GIF') do |cmd|
#   cmd.user('user', 'The person you want to hug', required: true)
# end

# bot.register_application_command(:slap, 'Send a playful slap with a random GIF') do |cmd|
#   cmd.user('user', 'The person you want to slap', required: true)
# end

# bot.register_application_command(:giveaway, 'Start a giveaway (Admin only)') do |cmd|
#   cmd.channel('channel', 'The channel to host the giveaway in', required: true)
#   cmd.string('time', 'Duration (e.g., 10m, 2h, 1d)', required: true)
#   cmd.string('prize', 'What are you giving away?', required: true)
# end

# bot.register_application_command(:coinflip, 'Bet your stream revenue on a coinflip!') do |cmd|
#   cmd.integer('amount', 'How many coins to bet', required: true)
#   cmd.string('choice', 'Heads or Tails', required: true, choices: { 'Heads' => 'heads', 'Tails' => 'tails' })
# end

# bot.register_application_command(:slots, 'Spin the neon slots!') do |cmd|
#   cmd.integer('amount', 'How many coins to bet', required: true)
# end

# bot.register_application_command(:roulette, 'Bet on the roulette wheel!') do |cmd|
#   cmd.integer('amount', 'How many coins to bet', required: true)
#   cmd.string('bet', 'red, black, even, odd, or 0-36', required: true)
# end

# bot.register_application_command(:scratch, 'Buy a neon scratch-off ticket for 500 coins!')

# bot.register_application_command(:dice, 'Roll 2d6! Bet on high (8-12), low (2-6), or 7.') do |cmd|
#   cmd.integer('amount', 'How many coins to bet', required: true)
#   cmd.string('bet', 'high, low, or 7', required: true, choices: { 'High (8-12)' => 'high', 'Low (2-6)' => 'low', 'Seven (7)' => '7' })
# end

# bot.register_application_command(:cups, 'Guess which cup hides the coin (1, 2, or 3)!') do |cmd|
#   cmd.integer('amount', 'How many coins to bet', required: true)
#   cmd.integer('guess', 'Cup 1, 2, or 3', required: true, choices: { 'Cup 1' => 1, 'Cup 2' => 2, 'Cup 3' => 3 })
# end

# bot.register_application_command(:setlevel, 'Set a user\'s server level (Admin Only)') do |cmd|
  # cmd.user('user', 'The user to modify', required: true)
  # cmd.integer('level', 'The new level', required: true)
# end

# bot.register_application_command(:addxp, 'Add or remove server XP from a user (Admin Only)') do |cmd|
  # cmd.user('user', 'The user to modify', required: true)
  # cmd.integer('amount', 'Amount of XP (use negative to remove)', required: true)
# end

# bot.register_application_command(:enablebombs, 'Enable random bomb drops in a specific channel (Admin Only)') do |cmd|
  # cmd.channel('channel', 'The channel to drop bombs in', required: true)
# end

# bot.register_application_command(:disablebombs, 'Disable bomb drops (Admin Only)')

# bot.register_application_command(:addcoins, 'Add or remove coins from a user (Dev Only)') do |cmd|
  # cmd.user('user', 'The user to modify', required: true)
  # cmd.integer('amount', 'Amount of coins (use negative to remove)', required: true)
# end

# bot.register_application_command(:setcoins, 'Set a user\'s balance to an exact amount (Dev Only)') do |cmd|
  # cmd.user('user', 'The user to modify', required: true)
  # cmd.integer('amount', 'The new balance', required: true)
# end

# bot.register_application_command(:blacklist, 'Toggle blacklist for a user (Dev Only)') do |cmd|
  # cmd.user('user', 'The user to blacklist or forgive', required: true)
# end

# bot.register_application_command(:card, 'Manage user cards (Dev Only)') do |cmd|
  # cmd.string('action', 'add / remove / giveascended / takeascended', required: true)
  # cmd.user('user', 'The user to modify', required: true)
  # cmd.string('character', 'The character name', required: true)
# end

# bot.register_application_command(:givepremium, 'Give a user lifetime premium (Dev only)') do |cmd|
  # cmd.user('user', 'The user to upgrade', required: true)
# end

# bot.register_application_command(:removepremium, 'Remove lifetime premium (Dev only)') do |cmd|
  # cmd.user('user', 'The user to downgrade', required: true)
# end

# bot.register_application_command(:backup, 'Manually trigger a database backup (Dev Only)')

# bot.register_application_command(:balance, "Show a user's coin balance, gacha stats, and inventory") do |cmd|
#   cmd.user('user', 'The user to check (optional)', required: false)
# end

# bot.register_application_command(:daily, 'Claim your daily coin reward')
# bot.register_application_command(:work, 'Work for some coins')
# bot.register_application_command(:stream, 'Go live and earn some coins!')
# bot.register_application_command(:post, 'Post on social media for some quick coins!')
# bot.register_application_command(:collab, 'Ask the server to do a collab stream! (30m cooldown)')
# bot.register_application_command(:cooldowns, 'Check your active timers for economy commands')
# bot.register_application_command(:coinlb, 'Show the richest users globally')
# bot.register_application_command(:bomb, 'Plant a bomb that explodes in 5 minutes (Admin only)')

 # bot.register_application_command(:summon, 'Roll the gacha!')
 # bot.register_application_command(:collection, 'View all the characters you own') do |cmd|
   # cmd.user('user', 'The user whose collection you want to view', required: false)
 # end
 # bot.register_application_command(:banner, 'Check which characters are in the gacha pool this week!')
 # bot.register_application_command(:shop, 'View the character shop and direct-buy prices!')
 # bot.register_application_command(:buy, 'Buy a character or tech upgrade') do |cmd|
   # cmd.string('item', 'Name of the character or item to buy', required: true)
 # end
 # bot.register_application_command(:view, 'Look at a specific character you own') do |cmd|
   # cmd.string('character', 'Name of the character', required: true)
 # end
 # bot.register_application_command(:ascend, 'Fuse 5 duplicate characters into a Shiny Ascended version!') do |cmd|
 #  cmd.string('character', 'Name of the character', required: true)
 # end

 # Leveling Commands
 # bot.register_application_command(:level, 'Show a user\'s level and XP for this server') do |cmd|
  # cmd.user('user', 'The user to check (optional)', required: false)
 # end
 # bot.register_application_command(:leaderboard, 'Show top users by level for this server')
# bot.register_application_command(:levelup, 'Configure where level-up messages go (Admin Only)') do |cmd|
 #  cmd.string('state', 'Turn messages on or off', required: false, choices: { 'On' => 'on', 'Off' => 'off' })
  # cmd.channel('channel', 'Pick a specific channel for the messages', required: false)
# end

# bot.register_application_command(:trade, 'Trade a character with someone') do |cmd|
   # cmd.user('user', 'The user you want to trade with', required: true)
   # cmd.string('offer', 'The character you are giving', required: true)
   # cmd.string('request', 'The character you want from them', required: true)
 # end

# ------------------------------------

puts "Starting bot with prefix #{PREFIX.inspect}..."
bot.run