# ==========================================
# COMMAND: collection
# DESCRIPTION: View your full VTuber collection with rarity filtering and pagination.
# CATEGORY: Gacha / Collection
# ==========================================

# ------------------------------------------
# LOGIC: UI Builder (Embed & Components)
# ------------------------------------------
def build_collection_page(event, target_user, col, current_rarity, page, is_edit: false)
  uid = target_user.id
  username = target_user.display_name

  # 1. Initialization: Define rarity priority and identify what the user actually owns
  rarity_order = ['common', 'rare', 'legendary', 'goddess']
  owned_rarities = rarity_order.select { |r| col.values.any? { |d| d['rarity'].downcase == r } }
  other_rarities = col.values.map { |d| d['rarity'].downcase }.uniq - rarity_order
  all_owned_rarities = owned_rarities + other_rarities

  # 2. Filtering: Grab only the items belonging to the currently selected rarity
  items_in_rarity = col.select { |_, data| data['rarity'].downcase == current_rarity }
  sorted_items = items_in_rarity.sort_by { |name, _| name }

  # 3. Pagination Math: Calculate total pages (10 items per page)
  items_per_page = 10
  total_pages = (sorted_items.size / items_per_page.to_f).ceil
  total_pages = 1 if total_pages < 1
  
  # Bounds checking for the page number
  page = 1 if page < 1
  page = total_pages if page > total_pages

  start_idx = (page - 1) * items_per_page
  page_items = sorted_items[start_idx, items_per_page]

  # 4. Load collection theme
  cosmetics = DB.get_cosmetics(uid)
  theme_id = cosmetics['theme'] || 'default'
  theme = COLLECTION_THEMES[theme_id] || COLLECTION_THEMES['default']

  # 5. UI: Construct the Collection Embed
  embed = Discordrb::Webhooks::Embed.new(
    title: "#{EMOJI_STRINGS[current_rarity] || EMOJI_STRINGS['neonsparkle']} #{username}'s VTubers: #{current_rarity.capitalize}",
    color: theme[:color] || 0xFFB6C1
  )

  desc = ""
  if page_items.nil? || page_items.empty?
    desc = "*Nothing here yet. Go pull some cards, chat.*"
  else
    lines = page_items.map do |name, data|
      count = data['count']
      asc = data['ascended']
      asc_text = asc > 0 ? " #{EMOJI_STRINGS['neonsparkle']}Ascended x#{asc}" : ""
      "#{theme[:bullet]}#{theme[:prefix]}#{name}#{theme[:suffix]} (x#{count})#{asc_text}"
    end
    desc = lines.join("\n")
  end

  embed.description = desc
  embed.footer = Discordrb::Webhooks::EmbedFooter.new(
    text: "Page #{page}/#{total_pages} • Total #{current_rarity.capitalize}: #{items_in_rarity.size}"
  )

  # 5. Components: Build the Rarity Select Menu and Nav Buttons
  view = Discordrb::Components::View.new

  # Row 1: The Rarity Dropdown
  view.row do |r|
    r.select_menu(custom_id: "colsel_#{uid}", placeholder: "Select Rarity...", max_values: 1) do |s|
      all_owned_rarities.each do |rarity|
        s.option(label: rarity.capitalize, value: rarity, default: rarity == current_rarity)
      end
    end
  end

  # Row 2: Navigation Buttons (only if there are multiple pages)
  if total_pages > 1
    view.row do |r|
      r.button(custom_id: "colbtn_#{uid}_#{page - 1}_#{current_rarity}", label: '◀ Prev', style: :secondary, disabled: page <= 1)
      r.button(custom_id: "colbtn_#{uid}_#{page + 1}_#{current_rarity}", label: 'Next ▶', style: :secondary, disabled: page >= total_pages)
    end
  end

  # 6. Response: Edit current message or send a fresh one
  if is_edit
    event.update_message(embeds: [embed], components: view)
  elsif event.is_a?(Discordrb::Events::ApplicationCommandEvent)
    event.respond(embeds: [embed], components: view)
  else
    event.channel.send_message(nil, false, embed, nil, nil, event.message, view)
  end
end

# ------------------------------------------
# LOGIC: Main Collection Executor
# ------------------------------------------
def execute_collection(event, target_user)
  uid = target_user.id
  col = DB.get_collection(uid)

  # A. Safety: Handle users with empty collections
  if col.empty?
    error_msg = "🌸 *#{target_user.display_name} has zero VTubers. Literally empty. Go summon something!*"
    return event.is_a?(Discordrb::Events::ApplicationCommandEvent) ? event.respond(content: error_msg) : event.channel.send_message(error_msg, false, nil, nil, nil, event.message)
  end

  # B. Initial Landing: Find the first rarity the user actually owns to show first
  rarity_order = ['common', 'rare', 'legendary', 'goddess']
  owned_rarities = rarity_order.select { |r| col.values.any? { |d| d['rarity'].downcase == r } }
  other_rarities = col.values.map { |d| d['rarity'].downcase }.uniq - rarity_order
  starting_rarity = (owned_rarities + other_rarities).first

  build_collection_page(event, target_user, col, starting_rarity, 1, is_edit: false)
end

# ------------------------------------------
# TRIGGERS: Prefix & Slash
# ------------------------------------------
$bot.command(:collection, aliases: [:coll, :cards], description: 'View all the characters you own', category: 'Gacha') do |event|
  execute_collection(event, event.message.mentions.first || event.user)
  nil
end

$bot.application_command(:collection) do |event|
  target_id = event.options['user']
  target = target_id ? event.bot.user(target_id.to_i) : event.user
  execute_collection(event, target)
end