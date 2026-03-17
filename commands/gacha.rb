# =========================
# GACHA COMMANDS 
# =========================

def get_collection_pages(uid)
  user_collection = DB.get_collection(uid)
  
  grouped = { 'common' => [], 'rare' => [], 'legendary' => [], 'goddess' => [] }
  user_collection.each do |name, data|
    count = data['count'].to_i
    ascended = data['ascended'].to_i
    
    if count > 0 || ascended > 0
      grouped[data['rarity']] << { name: name, ascended: ascended, count: count }
    end
  end

  available_rarities = ['common', 'rare', 'legendary']
  if TOTAL_UNIQUE_CHARS['goddess'] && TOTAL_UNIQUE_CHARS['goddess'] > 0
    available_rarities << 'goddess'
  end

  pages = []

  available_rarities.each do |rarity|
    chars = grouped[rarity]
    owned = chars.size
    total = TOTAL_UNIQUE_CHARS[rarity] || 0
    asc_total = chars.count { |c| c[:ascended] > 0 }
    
    emoji = case rarity
            when 'goddess'   then '💎'
            when 'legendary' then '🌟'
            when 'rare'      then '✨'
            else '⭐'
            end
    
    page_text = "#{emoji} **#{rarity.capitalize} Characters** (Owned: #{owned}/#{total} | Ascended: #{asc_total})\n\n"
    
    if chars.empty?
      page_text += "> *None yet!*"
    else
      chars.sort_by! { |c| c[:name] }
      chars.each do |c|
        if c[:ascended] > 0
          extra_dupes = c[:count] > 0 ? " | Base: #{c[:count]}" : ""
          page_text += "> **#{c[:name]}** ✨ (Ascended: #{c[:ascended]}#{extra_dupes})\n"
        else
          page_text += "> #{c[:name]} (x#{c[:count]})\n"
        end
      end
    end
    pages << page_text
  end

  pages
end

def execute_summon(event)
  uid = event.user.id
  now = Time.now
  last_used = DB.get_cooldown(uid, 'summon')
  inv = DB.get_inventory(uid)
  is_sub = is_premium?(event.bot, uid)
  cooldown_duration = (inv['gacha pass'] && inv['gacha pass'] > 0) ? 300 : 600

  if last_used && (now - last_used) < cooldown_duration
    ready_time = (last_used + cooldown_duration).to_i
    embed = Discordrb::Webhooks::Embed.new(title: "#{EMOJIS['drink']} Portal Recharging", description: "Your gacha energy is depleted!\nThe portal will be ready <t:#{ready_time}:R>.", color: 0xFF0000)
    if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
      return event.respond(embeds: [embed])
    else
      return event.channel.send_message(nil, false, embed, nil, nil, event.message)
    end
  end

  if DB.get_coins(uid) < SUMMON_COST
    return send_embed(event, title: "#{EMOJIS['info']} Summon", description: "You need **#{SUMMON_COST}** #{EMOJIS['s_coin']} to summon.\nYou currently have **#{DB.get_coins(uid)}**.")
  end

  DB.add_coins(uid, -SUMMON_COST)
  active_banner = get_current_banner
  
  used_manipulator = false
  inv = DB.get_inventory(uid)
  if inv['rng manipulator'] && inv['rng manipulator'] > 0
    DB.remove_inventory(uid, 'rng manipulator', 1)
    used_manipulator = true
    roll = rand(31)
    if roll < 25
      rarity = :rare
    elsif roll < 30
      rarity = :legendary
    else
      rarity = :goddess
    end
  else
    rarity = roll_rarity(is_sub)
  end

  pulled_char = active_banner[:characters][rarity].sample
  name = pulled_char[:name]
  gif_url = pulled_char[:gif]
  
  is_ascended = false
  is_ascended = true if is_sub && rand(100) < 1

  if is_ascended
    DB.add_character(uid, name, rarity.to_s, 5)
    DB.ascend_character(uid, name)
  else
    DB.add_character(uid, name, rarity.to_s, 1)
  end
  
  user_chars = DB.get_collection(uid)
  new_count = user_chars[name]['count']
  new_asc_count = user_chars[name]['ascended'].to_i

  rarity_label = rarity.to_s.capitalize
  emoji = case rarity
          when :goddess   then '💎'
          when :legendary then '🌟'
          when :rare      then '✨'
          else '⭐'
          end

  buff_text = used_manipulator ? "\n\n*🔮 RNG Manipulator consumed! Common pulls bypassed.*" : ""
  desc = "#{emoji} You summoned **#{name}** (#{rarity_label})!\n"
  
  if is_ascended
    buff_text += "\n\n#{EMOJIS['neonsparkle']} **PREMIUM PERK TRIGGERED!**\nYou pulled a **Shiny Ascended** version right out of the portal!"
    desc += "You now own **#{new_asc_count}** Ascended copies of them.#{buff_text}"
  else
    desc += "You now own **#{new_count}** of them.#{buff_text}"
  end

  send_embed(event, title: "#{EMOJIS['sparkle']} Summon Result: #{active_banner[:name]}", description: desc, fields: [{ name: 'Remaining Balance', value: "#{DB.get_coins(uid)} #{EMOJIS['s_coin']}", inline: true }], image: gif_url)
  DB.set_cooldown(uid, 'summon', now)
end

bot.command(:summon, description: 'Roll the gacha!', category: 'Gacha') { |e| execute_summon(e); nil }
bot.application_command(:summon) { |e| execute_summon(e) }

# This helper does all the heavy lifting for generating the UI
def build_collection_page(event, target_user, col, current_rarity, page, is_edit: false)
  uid = target_user.id
  username = target_user.display_name

  # Pre-sort to keep your exact market rarity order
  rarity_order = ['common', 'rare', 'legendary', 'goddess']
  
  # Find which rarities the user actually owns, in the correct order
  owned_rarities = rarity_order.select { |r| col.values.any? { |d| d['rarity'].downcase == r } }
  other_rarities = col.values.map { |d| d['rarity'].downcase }.uniq - rarity_order
  all_owned_rarities = owned_rarities + other_rarities

  # Grab only the VTubers for the currently selected rarity
  items_in_rarity = col.select { |_, data| data['rarity'].downcase == current_rarity }
  sorted_items = items_in_rarity.sort_by { |name, _| name }

  # Math for the 10-per-page limit
  items_per_page = 10
  total_pages = (sorted_items.size / items_per_page.to_f).ceil
  total_pages = 1 if total_pages < 1
  
  page = 1 if page < 1
  page = total_pages if page > total_pages

  start_idx = (page - 1) * items_per_page
  page_items = sorted_items[start_idx, items_per_page]

  # Build the beautiful embed
  embed = Discordrb::Webhooks::Embed.new(
    title: "🌟 #{username}'s VTubers: #{current_rarity.capitalize}",
    color: 0xFFB6C1
  )

  desc = ""
  page_items.each do |name, data|
    count = data['count']
    asc = data['ascended']
    asc_text = asc > 0 ? " | 🔥 Ascended: #{asc}" : ""
    desc += "**#{name}** - x#{count}#{asc_text}\n"
  end

  embed.description = desc.empty? ? "*No VTubers found.*" : desc
  embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Page #{page}/#{total_pages} • Total #{current_rarity.capitalize}: #{items_in_rarity.size}")

  # Build the Interactive Components
  view = Discordrb::Components::View.new

  # 1. The Select Menu (Dropdown)
  view.row do |r|
    r.select_menu(custom_id: "colsel_#{uid}", placeholder: "Select Rarity...", max_values: 1) do |s|
      all_owned_rarities.each do |rarity|
        # Marks the rarity they are currently looking at as the default/selected one
        s.option(label: rarity.capitalize, value: rarity, default: rarity == current_rarity)
      end
    end
  end

  # 2. The Pagination Buttons (Only show if there are multiple pages!)
  if total_pages > 1
    view.row do |r|
      r.button(custom_id: "colbtn_#{uid}_#{page - 1}_#{current_rarity}", label: '◀ Prev', style: :secondary, disabled: page <= 1)
      r.button(custom_id: "colbtn_#{uid}_#{page + 1}_#{current_rarity}", label: 'Next ▶', style: :secondary, disabled: page >= total_pages)
    end
  end

  # Send or Edit the message based on who called this method
  if is_edit
    event.update_message(embeds: [embed], components: view)
  elsif event.is_a?(Discordrb::Events::ApplicationCommandEvent)
    event.respond(embeds: [embed], components: view)
  else
    event.channel.send_message(nil, false, embed, nil, nil, nil, view)
  end
end

# The actual command users type
def execute_collection(event, target_user)
  uid = target_user.id
  col = DB.get_collection(uid)

  if col.empty?
    error_msg = "🌸 *#{target_user.display_name} hasn't pulled any VTubers yet!*"
    return event.is_a?(Discordrb::Events::ApplicationCommandEvent) ? event.respond(content: error_msg) : event.respond(error_msg)
  end

  # Start them on the lowest rarity they actually own
  rarity_order = ['common', 'rare', 'legendary', 'goddess']
  owned_rarities = rarity_order.select { |r| col.values.any? { |d| d['rarity'].downcase == r } }
  other_rarities = col.values.map { |d| d['rarity'].downcase }.uniq - rarity_order
  starting_rarity = (owned_rarities + other_rarities).first

  build_collection_page(event, target_user, col, starting_rarity, 1, is_edit: false)
end

bot.command(:collection, description: 'View all the characters you own', category: 'Gacha') do |event|
  execute_collection(event, event.message.mentions.first || event.user)
  nil
end

bot.application_command(:collection) do |event|
  target_id = event.options['user']
  target = target_id ? event.bot.user(target_id.to_i) : event.user
  execute_collection(event, target)
end

def execute_banner(event)
  active_banner = get_current_banner
  chars = active_banner[:characters]
  week_number = Time.now.to_i / 604_800 
  available_pools = CHARACTER_POOLS.keys
  next_key = available_pools[(week_number + 1) % available_pools.size]
  next_banner = CHARACTER_POOLS[next_key]
  next_rotation_time = (week_number + 1) * 604_800

  fields = [
    { name: '🌟 Legendaries (5%)', value: chars[:legendary].map { |c| c[:name] }.join(', '), inline: false },
    { name: '✨ Rares (25%)', value: chars[:rare].map { |c| c[:name] }.join(', '), inline: false },
    { name: '⭐ Commons (69%)', value: chars[:common].map { |c| c[:name] }.join(', '), inline: false }
  ]

  desc = "Here are the VTubers you can pull this week!\n\n**Next Rotation:** <t:#{next_rotation_time}:R>\n**Up Next:** #{next_banner[:name]}"
  send_embed(event, title: "#{EMOJIS['neonsparkle']} Current Gacha: #{active_banner[:name]}", description: desc, fields: fields)
end

bot.command(:banner, description: 'Check which characters are in the gacha pool this week!', category: 'Gacha') { |e| execute_banner(e); nil }
bot.application_command(:banner) { |e| execute_banner(e) }

def execute_shop(event)
  embed, view = build_shop_home(event.user.id)
  if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
    event.respond(embeds: [embed], components: view)
  else
    event.channel.send_message(nil, false, embed, nil, { replied_user: false }, event.message, view)
  end
end

bot.command(:shop, description: 'View the character shop and direct-buy prices!', category: 'Gacha') { |e| execute_shop(e); nil }
bot.application_command(:shop) { |e| execute_shop(e) }

def execute_buy(event, search_name)
  uid = event.user.id
  search_name = search_name.downcase.strip

  if BLACK_MARKET_ITEMS.key?(search_name)
    item_data = BLACK_MARKET_ITEMS[search_name]
    price = item_data[:price]

    if DB.get_coins(uid) < price
      return send_embed(event, title: "#{EMOJIS['nervous']} Insufficient Funds", description: "You need **#{price}** #{EMOJIS['s_coin']} to buy the #{item_data[:name]}.\nYou currently have **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}.")
    end

    inv = DB.get_inventory(uid)
    if item_data[:type] == 'upgrade' && inv[search_name] && inv[search_name] >= 1
      return send_embed(event, title: "#{EMOJIS['confused']} Already Owned", description: "You already have the **#{item_data[:name]}** equipped in your setup!")
    end

    DB.add_coins(uid, -price)
    DB.add_inventory(uid, search_name, 1)

    if search_name == 'gamer fuel'
      DB.remove_inventory(uid, search_name, 1)
      DB.set_cooldown(uid, 'stream', nil)
      DB.set_cooldown(uid, 'post', nil)
      DB.set_cooldown(uid, 'collab', nil)
      return send_embed(event, title: "🥫 Gamer Fuel Consumed!", description: "You cracked open a cold one and chugged it.\n**ALL your content creation cooldowns have been reset!** Get back to the grind.")
    elsif search_name == 'stamina pill'
      DB.remove_inventory(uid, search_name, 1)
      DB.set_cooldown(uid, 'summon', nil)
      return send_embed(event, title: "💊 Stamina Pill Swallowed!", description: "You took a highly questionable Stamina Pill...\n**Your !summon cooldown has been instantly reset!** Get back to gambling.")
    end

    return send_embed(event, title: "🛒 Item Purchased!", description: "You successfully bought the **#{item_data[:name]}** for **#{price}** #{EMOJIS['s_coin']}!\nIt has been added to your inventory/setup.")
  end

  result = find_character_in_pools(search_name)
  unless result
    return send_embed(event, title: "#{EMOJIS['error']} Shop Error", description: "I couldn't find a character or item named **#{search_name}**. Check your spelling!")
  end

  char_data = result[:char]
  rarity    = result[:rarity]
  price     = SHOP_PRICES[rarity]

  if price.nil?
    return send_embed(event, title: "#{EMOJIS['x_']} Black Market Locked", description: "You cannot directly purchase **#{char_data[:name]}**. She can only be obtained through the gacha portal.")
  end

  if DB.get_coins(uid) < price
    return send_embed(event, title: "#{EMOJIS['nervous']} Insufficient Funds", description: "You need **#{price}** #{EMOJIS['s_coin']} to buy a #{rarity.capitalize} character.\nYou currently have **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}.")
  end

  DB.add_coins(uid, -price)
  name = char_data[:name]
  gif_url = char_data[:gif]

  DB.add_character(uid, name, rarity.to_s, 1)
  new_count = DB.get_collection(uid)[name]['count']

  emoji = case rarity
          when 'goddess'   then '💎'
          when 'legendary' then '🌟'
          when 'rare'      then '✨'
          else '⭐'
          end

  send_embed(event, title: "#{EMOJIS['coins']} Purchase Successful!", description: "#{emoji} You directly purchased **#{name}** for **#{price}** #{EMOJIS['s_coin']}!\nYou now own **#{new_count}** of them.", fields: [{ name: 'Remaining Balance', value: "#{DB.get_coins(uid)} #{EMOJIS['s_coin']}", inline: true }], image: gif_url)
end

bot.command(:buy, description: 'Buy a character or tech upgrade (Usage: !buy <Name>)', min_args: 1, category: 'Gacha') do |event, *name_args|
  execute_buy(event, name_args.join(' '))
  nil
end

bot.application_command(:buy) do |event|
  execute_buy(event, event.options['item'])
end

def execute_view(event, search_name)
  uid = event.user.id
  search_name = search_name.strip
  user_chars = DB.get_collection(uid)
  
  owned_name = user_chars.keys.find { |k| k.downcase == search_name.downcase }
  
  unless owned_name && (user_chars[owned_name]['count'] > 0 || user_chars[owned_name]['ascended'].to_i > 0)
    return send_embed(event, title: "#{EMOJIS['confused']} Character Not Found", description: "You don't own **#{search_name}** yet!\nUse `/summon` to roll for them, or `/buy` to get them from the shop.")
  end
  
  result = find_character_in_pools(owned_name)
  char_data = result[:char]
  rarity    = result[:rarity]
  count     = user_chars[owned_name]['count']
  ascended  = user_chars[owned_name]['ascended'].to_i
  
  emoji = case rarity
          when 'goddess'   then '💎'
          when 'legendary' then '🌟'
          when 'rare'      then '✨'
          else '⭐'
          end
          
  desc = "You currently own **#{count}** standard copies of this character.\n"
  desc += "#{EMOJIS['neonsparkle']} **You own #{ascended} Shiny Ascended copies!** #{EMOJIS['neonsparkle']}" if ascended > 0

  send_embed(event, title: "#{emoji} #{owned_name} (#{rarity.capitalize})", description: desc, image: char_data[:gif])
end

bot.command(:view, description: 'Look at a specific character you own', min_args: 1, category: 'Gacha') do |event, *name_args|
  execute_view(event, name_args.join(' '))
  nil
end

bot.application_command(:view) do |event|
  execute_view(event, event.options['character'])
end

def execute_ascend(event, search_name)
  uid = event.user.id
  search_name = search_name.downcase.strip
  user_chars = DB.get_collection(uid)
  
  owned_name = user_chars.keys.find { |k| k.downcase == search_name }

  unless owned_name
    return send_embed(event, title: "#{EMOJIS['error']} Ascension Failed", description: "You don't own any copies of **#{search_name}**!")
  end

  if user_chars[owned_name]['count'] < 5
    return send_embed(event, title: "#{EMOJIS['nervous']} Not Enough Copies", description: "You need **5 copies** of #{owned_name} to ascend them. You only have **#{user_chars[owned_name]['count']}**.")
  end

  ascension_cost = 5000
  if DB.get_coins(uid) < ascension_cost
    return send_embed(event, title: "#{EMOJIS['nervous']} Insufficient Funds", description: "The ritual costs **#{ascension_cost}** #{EMOJIS['s_coin']}. You currently have **#{DB.get_coins(uid)}** #{EMOJIS['s_coin']}.")
  end

  DB.add_coins(uid, -ascension_cost)
  DB.ascend_character(uid, owned_name)

  send_embed(event, title: "#{EMOJIS['neonsparkle']} Ascension Complete! #{EMOJIS['neonsparkle']}", description: "You paid **#{ascension_cost}** #{EMOJIS['s_coin']} and fused 5 copies of **#{owned_name}** together!\n\nThey have been reborn as a **Shiny Ascended** character. View them in your `/collection`!")
end

bot.command(:ascend, description: 'Fuse 5 duplicate characters into a Shiny Ascended version!', min_args: 1, category: 'Gacha') do |event, *name_args|
  execute_ascend(event, name_args.join(' '))
  nil
end

bot.application_command(:ascend) do |event|
  execute_ascend(event, event.options['character'])
end