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

def build_collection_page(event, target_user, col, current_rarity, page, is_edit: false)
  uid = target_user.id
  username = target_user.display_name

  rarity_order = ['common', 'rare', 'legendary', 'goddess']
  
  owned_rarities = rarity_order.select { |r| col.values.any? { |d| d['rarity'].downcase == r } }
  other_rarities = col.values.map { |d| d['rarity'].downcase }.uniq - rarity_order
  all_owned_rarities = owned_rarities + other_rarities

  items_in_rarity = col.select { |_, data| data['rarity'].downcase == current_rarity }
  sorted_items = items_in_rarity.sort_by { |name, _| name }

  items_per_page = 10
  total_pages = (sorted_items.size / items_per_page.to_f).ceil
  total_pages = 1 if total_pages < 1
  
  page = 1 if page < 1
  page = total_pages if page > total_pages

  start_idx = (page - 1) * items_per_page
  page_items = sorted_items[start_idx, items_per_page]

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

  view = Discordrb::Components::View.new

  view.row do |r|
    r.select_menu(custom_id: "colsel_#{uid}", placeholder: "Select Rarity...", max_values: 1) do |s|
      all_owned_rarities.each do |rarity|
        s.option(label: rarity.capitalize, value: rarity, default: rarity == current_rarity)
      end
    end
  end

  if total_pages > 1
    view.row do |r|
      r.button(custom_id: "colbtn_#{uid}_#{page - 1}_#{current_rarity}", label: '◀ Prev', style: :secondary, disabled: page <= 1)
      r.button(custom_id: "colbtn_#{uid}_#{page + 1}_#{current_rarity}", label: 'Next ▶', style: :secondary, disabled: page >= total_pages)
    end
  end

  if is_edit
    event.update_message(embeds: [embed], components: view)
  elsif event.is_a?(Discordrb::Events::ApplicationCommandEvent)
    event.respond(embeds: [embed], components: view)
  else
    event.channel.send_message(nil, false, embed, nil, nil, nil, view)
  end
end

def execute_collection(event, target_user)
  uid = target_user.id
  col = DB.get_collection(uid)

  if col.empty?
    error_msg = "🌸 *#{target_user.display_name} hasn't pulled any VTubers yet!*"
    return event.is_a?(Discordrb::Events::ApplicationCommandEvent) ? event.respond(content: error_msg) : event.respond(error_msg)
  end

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