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
  'Economy'   => [:balance, :daily, :work, :stream, :post, :collab, :cooldowns, :coinlb, :lottery, :lotteryinfo, :givecoins, :remindme],
  'Gacha'     => [:summon, :collection, :banner, :shop, :buy, :view, :ascend, :trade, :givecard, :sell],
  'Arcade'    => [:coinflip, :slots, :roulette, :scratch, :dice, :cups],
  'Fun'       => [:kettle, :level, :leaderboard, :hug, :slap, :interactions],
  'Utility'   => [:ping, :help, :about, :support, :premium, :call, :dismiss, :serverinfo, :suggest],
  'Admin'     => [:setlevel, :enablebombs, :disablebombs, :levelup, :addxp, :giveaway, :logsetup, :logtoggle, :purge, :kick, :ban, :timeout, :verifysetup],
  'Developer' => [:addcoins, :removecoins, :setcoins, :blacklist, :card, :backup, :givepremium, :removepremium, :bomb]
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

def generate_category_embed(bot, user_obj, category)
  embed = Discordrb::Webhooks::Embed.new
  embed.color = NEON_COLORS.sample
  embed.timestamp = Time.now
  embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Requested by #{user_obj.display_name}", icon_url: user_obj.avatar_url)

  if category == 'Home'
    embed.title = "#{EMOJIS['info'] || 'ℹ️'} Blossom Help Menu"
    embed.description = "Welcome to Blossom's help menu! 🌸\n\n" \
                        "**Prefix:** `#{PREFIX}`\n" \
                        "*All commands listed can be used as both Slash Commands (`/`) and Prefix Commands!* \n\n" \
                        "Use the dropdown menu below to explore the different categories."
  else
    embed.title = "🌸 Help Category: #{category}"
    embed.description = "**Prefix:** `#{PREFIX}` | **Slash:** `/`\n\n"
    
    if COMMAND_CATEGORIES[category]
      cmd_list = COMMAND_CATEGORIES[category].map do |cmd_sym|
        cmd = bot.commands[cmd_sym]
        desc = cmd ? (cmd.attributes[:description] || 'No description provided.') : 'No description provided.'
        # We only list the raw name in backticks now!
        "`#{cmd_sym}` - #{desc}"
      end
      embed.description += cmd_list.join("\n")
    else
      embed.description += "*No commands found in this category.*"
    end
  end
  embed
end

def help_select_menu(user_id)
  Discordrb::Components::View.new do |v|
    v.row do |r|
      r.select_menu(custom_id: "help_menu_#{user_id}", placeholder: 'Select a category to explore...', max_values: 1) do |s|
        s.option(label: 'Home', value: 'Home', emoji: '🏠', description: 'Return to the main menu')
        
        emoji_map = {
          'Economy' => '💰',
          'Gacha'   => '🌟',
          'Arcade'  => '🕹️',
          'Fun'     => '🎉',
          'Utility' => '🔧',
          'Admin'   => '🛡️'
        }
        
        visible_categories = COMMAND_CATEGORIES.keys - ['Developer']
        
        visible_categories.each do |cat|
          s.option(label: cat, value: cat, emoji: emoji_map[cat] || '🌸')
        end
      end
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

# =========================
# PREMIUM SYSTEM
# =========================

# Server IDs => Role IDs 
PREMIUM_SERVERS = {
  1125196330646638592 => 1125222184533639338,
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
    is_sub = is_premium?(event.bot, uid)
    daily_info = DB.get_daily_info(uid)

    badges = []
    badges << "#{EMOJIS['developer']} **Bot Developer**" if uid == DEV_ID
    badges << "💎 **Premium**" if is_sub
    
    header = badges.empty? ? "" : badges.join(" | ") + "\n\n"

    new_embed.title = "🌸 #{username}'s Balance"
    new_embed.description = "#{header}**Coins:** #{coins} #{EMOJIS['s_coin']}\n🔥 **Daily Streak:** #{daily_info['streak']} Days\n\n*Click the buttons below to view your items and VTubers!*"
    
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

  when 'vtubers', 'cards'
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

      rarity_order = ['common', 'rare', 'legendary', 'goddess']
      
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

bot.select_menu(custom_id: /^help_menu_/) do |event|
  owner_id = event.custom_id.split('_').last

  if event.user.id.to_s != owner_id
    event.respond(content: "🌸 *This isn't your menu! Run your own `#{PREFIX}help` command to explore.*", ephemeral: true)
    next
  end

  selected_category = event.values.first
  new_embed = generate_category_embed(event.bot, event.user, selected_category)
  view = help_select_menu(owner_id) 

  event.update_message(embeds: [new_embed], components: view)
end

# =========================
# VERIFICATION SYSTEM
# =========================

bot.button(custom_id: 'verify_start') do |event|
  role_id = DB.get_verify_role(event.server.id)
  
  if role_id.nil?
    event.respond(content: "⚠️ Verification hasn't been fully configured yet!", ephemeral: true)
    next
  end

  emojis = ['🍎', '🍉', '🍇', '🍓', '🍒', '🍑', '🍍', '🥝', '🍅', '🥥', '🍔', '🍕', '🍩', '🍦', '🍪', '🍯', '🍩', '🥞', '🥐']
  selected_emojis = emojis.sample(9).shuffle
  correct_emoji = selected_emojis.sample

  view = Discordrb::Components::View.new
  selected_emojis.each_slice(3) do |row_emojis|
    view.row do |r|
      row_emojis.each do |emoji|
        if emoji == correct_emoji
          r.button(custom_id: "verify_pass_#{role_id}", style: :secondary, emoji: emoji)
        else
          r.button(custom_id: "verify_fail_#{rand(10000)}", style: :secondary, emoji: emoji)
        end
      end
    end
  end

  event.respond(content: "🤖 **Human Check!**\nTo gain access to the server, please click on the **#{correct_emoji}** from the buttons below!", ephemeral: true, components: view)
end

bot.button(custom_id: /^verify_pass_/) do |event|
  role_id = event.custom_id.split('_').last.to_i
  role = event.server.role(role_id)
  
  if role
    begin
      event.user.add_role(role)
      event.update_message(content: "✅ **Verification successful!** Welcome to the server! 🌸", components: [])
    rescue => e
      event.update_message(content: "❌ I don't have permission to give you the role! Please tell an Admin to move my bot role higher up in the settings.", components: [])
    end
  else
    event.update_message(content: "❌ The verification role no longer exists! An Admin needs to run `#{PREFIX}verifysetup` again.", components: [])
  end
end

bot.button(custom_id: /^verify_fail_/) do |event|
  event.update_message(content: "❌ **Incorrect!** That was the wrong emoji. Please dismiss this message and click the 'Start Verification' button to try again.", components: [])
end

# =========================
# SAFE LOAD COMMANDS
# =========================
def safe_load(file_path, context_binding)
  begin
    eval(File.read(file_path), context_binding)
    puts "✅ Loaded: #{file_path}"
  rescue StandardError => e
    puts "❌ ERROR in #{file_path}!"
    puts "   Line: #{e.backtrace.first}"
    puts "   Message: #{e.message}"
  rescue SyntaxError => e
    puts "⚠️ SYNTAX ERROR in #{file_path}!"
    puts "   Message: #{e.message}"
  end
end

command_files = [
  'commands/basic.rb', 'commands/economy.rb', 'commands/gacha.rb', 
  'commands/arcade.rb', 'commands/trade.rb', 'commands/developer.rb', 
  'commands/leveling.rb', 'commands/moderation.rb'
]

event_files = [
  'events/leveling.rb', 'events/economy.rb', 'events/gacha.rb', 
  'events/trade.rb', 'events/basic.rb', 'events/moderation.rb'
]

command_files.each { |f| safe_load(File.join(__dir__, f), binding) }
event_files.each { |f| safe_load(File.join(__dir__, f), binding) }

bot.include!(Moderation)

# =========================
# RUN
# =========================

bot.ready do
  puts "Blossom is connected and live!"

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

=begin

 bot.register_application_command(:ping, 'Check bot latency')
 bot.register_application_command(:kettle, 'Pings a specific user with a yay emoji')
 bot.register_application_command(:help, 'Shows a paginated list of all available commands')
 bot.register_application_command(:about, 'Learn more about Blossom and her creator!')
 bot.register_application_command(:interactions, 'Show your hug/slap stats')
 bot.register_application_command(:support, 'Get a link to the official support server')
 bot.register_application_command(:premium, 'View the benefits of Blossom Premium!')

 bot.register_application_command(:hug, 'Send a hug with a random GIF') do |cmd|
   cmd.user('user', 'The person you want to hug', required: true)
 end

 bot.register_application_command(:slap, 'Send a playful slap with a random GIF') do |cmd|
   cmd.user('user', 'The person you want to slap', required: true)
 end

 bot.register_application_command(:giveaway, 'Start a giveaway (Admin only)') do |cmd|
   cmd.channel('channel', 'The channel to host the giveaway in', required: true)
   cmd.string('time', 'Duration (e.g., 10m, 2h, 1d)', required: true)
   cmd.string('prize', 'What are you giving away?', required: true)
 end

 bot.register_application_command(:coinflip, 'Bet your stream revenue on a coinflip!') do |cmd|
   cmd.integer('amount', 'How many coins to bet', required: true)
   cmd.string('choice', 'Heads or Tails', required: true, choices: { 'Heads' => 'heads', 'Tails' => 'tails' })
 end

 bot.register_application_command(:slots, 'Spin the neon slots!') do |cmd|
   cmd.integer('amount', 'How many coins to bet', required: true)
 end

 bot.register_application_command(:roulette, 'Bet on the roulette wheel!') do |cmd|
   cmd.integer('amount', 'How many coins to bet', required: true)
   cmd.string('bet', 'red, black, even, odd, or 0-36', required: true)
 end

 bot.register_application_command(:scratch, 'Buy a neon scratch-off ticket for 500 coins!')

 bot.register_application_command(:dice, 'Roll 2d6! Bet on high (8-12), low (2-6), or 7.') do |cmd|
   cmd.integer('amount', 'How many coins to bet', required: true)
   cmd.string('bet', 'high, low, or 7', required: true, choices: { 'High (8-12)' => 'high', 'Low (2-6)' => 'low', 'Seven (7)' => '7' })
 end

 bot.register_application_command(:cups, 'Guess which cup hides the coin (1, 2, or 3)!') do |cmd|
   cmd.integer('amount', 'How many coins to bet', required: true)
   cmd.integer('guess', 'Cup 1, 2, or 3', required: true, choices: { 'Cup 1' => 1, 'Cup 2' => 2, 'Cup 3' => 3 })
 end

 bot.register_application_command(:setlevel, 'Set a user\'s server level (Admin Only)') do |cmd|
   cmd.user('user', 'The user to modify', required: true)
   cmd.integer('level', 'The new level', required: true)
 end

 bot.register_application_command(:addxp, 'Add or remove server XP from a user (Admin Only)') do |cmd|
   cmd.user('user', 'The user to modify', required: true)
   cmd.integer('amount', 'Amount of XP (use negative to remove)', required: true)
 end

 bot.register_application_command(:enablebombs, 'Enable random bomb drops in a specific channel (Admin Only)') do |cmd|
   cmd.channel('channel', 'The channel to drop bombs in', required: true)
 end

 bot.register_application_command(:disablebombs, 'Disable bomb drops (Admin Only)')

 bot.register_application_command(:addcoins, 'Add or remove coins from a user (Dev Only)') do |cmd|
   cmd.user('user', 'The user to modify', required: true)
   cmd.integer('amount', 'Amount of coins (use negative to remove)', required: true)
 end

 bot.register_application_command(:setcoins, 'Set a user\'s balance to an exact amount (Dev Only)') do |cmd|
   cmd.user('user', 'The user to modify', required: true)
   cmd.integer('amount', 'The new balance', required: true)
 end

 bot.register_application_command(:blacklist, 'Toggle blacklist for a user (Dev Only)') do |cmd|
   cmd.user('user', 'The user to blacklist or forgive', required: true)
 end

 bot.register_application_command(:card, 'Manage user cards (Dev Only)') do |cmd|
   cmd.string('action', 'add / remove / giveascended / takeascended', required: true)
   cmd.user('user', 'The user to modify', required: true)
   cmd.string('character', 'The character name', required: true)
 end

 bot.register_application_command(:givepremium, 'Give a user lifetime premium (Dev only)') do |cmd|
   cmd.user('user', 'The user to upgrade', required: true)
 end

 bot.register_application_command(:removepremium, 'Remove lifetime premium (Dev only)') do |cmd|
   cmd.user('user', 'The user to downgrade', required: true)
 end

 bot.register_application_command(:backup, 'Manually trigger a database backup (Dev Only)')

 bot.register_application_command(:balance, "Show a user's coin balance, gacha stats, and inventory") do |cmd|
   cmd.user('user', 'The user to check (optional)', required: false)
 end

 bot.register_application_command(:daily, 'Claim your daily coin reward')
 bot.register_application_command(:work, 'Work for some coins')
 bot.register_application_command(:stream, 'Go live and earn some coins!')
 bot.register_application_command(:post, 'Post on social media for some quick coins!')
 bot.register_application_command(:collab, 'Ask the server to do a collab stream! (30m cooldown)')
 bot.register_application_command(:cooldowns, 'Check your active timers for economy commands')
 bot.register_application_command(:coinlb, 'Show the richest users globally')
 bot.register_application_command(:bomb, 'Plant a bomb that explodes in 5 minutes (Admin only)')

  bot.register_application_command(:summon, 'Roll the gacha!')

  bot.register_application_command(:collection, 'View all the characters you own') do |cmd|
    cmd.user('user', 'The user whose collection you want to view', required: false)
  end
  bot.register_application_command(:banner, 'Check which characters are in the gacha pool this week!')
  bot.register_application_command(:shop, 'View the character shop and direct-buy prices!')
  bot.register_application_command(:buy, 'Buy a character or tech upgrade') do |cmd|
    cmd.string('item', 'Name of the character or item to buy', required: true)
  end
  bot.register_application_command(:view, 'Look at a specific character you own') do |cmd|
    cmd.string('character', 'Name of the character', required: true)
  end
  bot.register_application_command(:ascend, 'Fuse 5 duplicate characters into a Shiny Ascended version!') do |cmd|
   cmd.string('character', 'Name of the character', required: true)
  end

  bot.register_application_command(:level, 'Show a user\'s level and XP for this server') do |cmd|
   cmd.user('user', 'The user to check (optional)', required: false)
  end

bot.register_application_command(:leaderboard, 'Show top users by level for this server')

bot.register_application_command(:levelup, 'Configure where level-up messages go (Admin Only)') do |cmd|
   cmd.string('state', 'Turn messages on or off', required: false, choices: { 'On' => 'on', 'Off' => 'off' })
   cmd.channel('channel', 'Pick a specific channel for the messages', required: false)
 end

 bot.register_application_command(:trade, 'Trade a character with someone') do |cmd|
    cmd.user('user', 'The user you want to trade with', required: true)
    cmd.string('offer', 'The character you are giving', required: true)
    cmd.string('request', 'The character you want from them', required: true)
end

bot.register_application_command(:purge, 'Deletes a number of messages (Admin only)') do |cmd|
  cmd.integer('amount', 'Number of messages to delete (1-100)', required: true)
end

bot.register_application_command(:kick, 'Kicks a user from the server (Admin only)') do |cmd|
  cmd.user('user', 'The user to kick', required: true)
  cmd.string('reason', 'Why are they being kicked?', required: false)
end

bot.register_application_command(:ban, 'Bans a user from the server (Admin only)') do |cmd|
  cmd.user('user', 'The user to ban', required: true)
  cmd.string('reason', 'Why are they being banned?', required: false)
end

bot.register_application_command(:timeout, 'Timeouts a user for X minutes (Admin only)') do |cmd|
  cmd.user('user', 'The user to timeout', required: true)
  cmd.integer('minutes', 'How many minutes?', required: true)
  cmd.string('reason', 'Why are they being timed out?', required: false)
end

bot.register_application_command(:lottery, 'Enter the hourly global lottery!') do |cmd|
  cmd.integer('tickets', 'How many 1000-coin tickets to buy', required: false)
end

bot.register_application_command(:lotteryinfo, 'View current lottery stats and your tickets')

bot.register_application_command(:remindme, 'Toggle your daily reward reminder ping')

bot.register_application_command(:givecoins, 'Give your coins to another user') do |cmd|
  cmd.user('user', 'Who?', required: true)
  cmd.integer('amount', 'How much?', required: true)
end

bot.register_application_command(:serverinfo, 'Displays information about the current server')

bot.register_application_command(:givecard, 'Give a VTuber card to another user') do |cmd|
  cmd.user('user', 'The user you want to give the card to', required: true)
  cmd.string('character', 'The name of the character', required: true)
end

bot.register_application_command(:sell, 'Sell your duplicate VTuber cards for coins') do |cmd|
  cmd.string('filter', 'How do you want to sell?', required: true, choices: { 
    'All Dupes (Keep 1 of each)' => 'all', 
    'Over 5 (Save copies for ascending)' => 'over5', 
    'Specific Rarity' => 'rarity' 
  })
  cmd.string('rarity', 'If filtering by rarity, which one?', required: false, choices: { 
    'Common' => 'common', 
    'Rare' => 'rare', 
    'Legendary' => 'legendary', 
    'Goddess' => 'goddess' 
  })
end

bot.register_application_command(:logsetup, 'Set the channel for server logs (Admin Only)') do |cmd|
  cmd.channel('channel', 'The channel to send logs to', required: true)
end

bot.register_application_command(:logtoggle, 'Toggle logging for specific events (Admin Only)') do |cmd|
  cmd.string('type', 'What to toggle', required: true, choices: { 'Message Deletes' => 'deletes', 'Message Edits' => 'edits', 'Mod Actions' => 'mod' })
end

bot.register_application_command(:kick, 'Kicks a user from the server (Admin only)') do |cmd|
  cmd.user('user', 'The user to kick', required: true)
  cmd.string('reason', 'Why are they being kicked?', required: false)
end

bot.register_application_command(:removecoins, 'Remove coins from a user (Dev Only)') do |cmd|
  cmd.user('user', 'Who?', required: true)
  cmd.integer('amount', 'How much?', required: true)
end

=end

bot.register_application_command(:verifysetup, 'Set up a verification panel (Admin Only)') do |cmd|
  cmd.channel('channel', 'The channel to send the panel to', required: true)
  cmd.role('role', 'The role to give verified members', required: true)
end

bot.register_application_command(:suggest, 'Send a suggestion directly to the developer!') do |cmd|
  cmd.string('suggestion', 'What would you like to see added or changed?', required: true)
end

# ------------------------------------

puts "Starting bot with prefix #{PREFIX.inspect}..."
bot.run