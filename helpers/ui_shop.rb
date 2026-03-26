# ==========================================
# HELPER: Interactive UI Builders (Shop & Collection)
# DESCRIPTION: Generates the embeds and component views 
# for Blossom's interactive economy menus.
# ==========================================

def build_shop_home(user_id)
  embed = Discordrb::Webhooks::Embed.new
  embed.title = "#{EMOJI_STRINGS['rich']} The VTuber Black Market"
  embed.description = "Tired of bad gacha luck? Save up your stream revenue and buy exactly who you want!\n\n" \
                      "⭐ **Common:** #{SHOP_PRICES['common']} #{EMOJI_STRINGS['s_coin']} *(Sells for #{SELL_PRICES['common']})*\n" \
                      "#{EMOJI_STRINGS['neonsparkle']} **Rare:** #{SHOP_PRICES['rare']} #{EMOJI_STRINGS['s_coin']} *(Sells for #{SELL_PRICES['rare']})*\n" \
                      "🌟 **Legendary:** #{SHOP_PRICES['legendary']} #{EMOJI_STRINGS['s_coin']} *(Sells for #{SELL_PRICES['legendary']})*\n\n" \
                      "Use `#{PREFIX}buy <Name>` to purchase characters or tech upgrades!"
  embed.color = NEON_COLORS.sample
  embed.image = Discordrb::Webhooks::EmbedImage.new(url: 'https://media.discordapp.net/attachments/1475890017443516476/1476244926638592050/d60459-53-0076f9af74811878db01-0.jpg')

  view = Discordrb::Components::View.new do |v|
    v.row do |r|
      r.button(custom_id: "shop_catalog_#{user_id}_1", label: 'View Catalog', style: :primary, emoji: '📖')
      r.button(custom_id: "shop_blackmarket_#{user_id}", label: 'Tech Upgrades', style: :success, emoji: '🛒')
      r.button(custom_id: "shop_prisma_#{user_id}", label: 'Prisma Shop', style: :danger, emoji: '💎')
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
          when 'rare'      then EMOJI_STRINGS['neonsparkle']
          else '⭐'
          end

  embed = Discordrb::Webhooks::Embed.new
  embed.title = "📖 Shop Catalog - #{target_rarity.capitalize}s #{emoji}"
  embed.description = "Price: **#{SHOP_PRICES[target_rarity]}** #{EMOJI_STRINGS['s_coin']} each.\n\n`" + chars.join("`, `") + "`"
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
      desc += "`#{key}` — **#{data[:name]}** (#{data[:price]} #{EMOJI_STRINGS['s_coin']})\n> *#{data[:desc]}*\n"
    end
  end

  desc += "\n**🎒 Consumables (One-Time Use)**\n"
  BLACK_MARKET_ITEMS.each do |key, data|
    if data[:type] == 'consumable'
      desc += "`#{key}` — **#{data[:name]}** (#{data[:price]} #{EMOJI_STRINGS['s_coin']})\n> *#{data[:desc]}*\n"
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

def build_prisma_shop(user_id)
  # Gather all unique goddess characters from the pools
  goddess_chars = []
  CHARACTER_POOLS.values.each do |pool|
    next unless pool[:characters][:goddess]
    pool[:characters][:goddess].each { |c| goddess_chars << c[:name] }
  end
  goddess_chars = goddess_chars.uniq.sort

  prisma_bal = DB.get_prisma(user_id)

  desc = "Spend your hard-earned Prisma on the rarest characters in existence.\n\n"
  desc += "#{EMOJI_STRINGS['prisma']} **Goddess Characters** — **#{GODDESS_PRISMA_PRICE}** #{EMOJI_STRINGS['prisma']} each\n\n"
  desc += goddess_chars.map { |name| "`#{name}`" }.join(', ')
  desc += "\n\nYour Prisma: **#{prisma_bal}** #{EMOJI_STRINGS['prisma']}"
  desc += "\n\nUse `#{PREFIX}buy <Name>` to purchase!"

  embed = Discordrb::Webhooks::Embed.new
  embed.title = "#{EMOJI_STRINGS['prisma']} Prisma Shop"
  embed.description = desc
  embed.color = 0x9370DB

  view = Discordrb::Components::View.new do |v|
    v.row do |r|
      r.button(custom_id: "shop_home_#{user_id}", label: 'Back to Shop', style: :secondary, emoji: '🔙')
    end
  end
  [embed, view]
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
          when 'rare'      then EMOJI_STRINGS['neonsparkle']
          else '⭐'
          end
          
  desc = "You have collected **#{total_collected} / #{total_available}** unique #{rarity_page.capitalize} characters.\n\n"
  
  if page_chars.empty?
    desc += "*You haven't pulled any characters of this rarity yet!*"
  else
    list = page_chars.map do |name, data|
      str = "`#{name}` (x#{data['count']})"
      str += " #{EMOJI_STRINGS['neonsparkle']}*(Ascended x#{data['ascended']})*" if data['ascended'].to_i > 0
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
      r.button(custom_id: "coll_rare_#{target_uid}", label: 'Rare', style: current_page == 'rare' ? :success : :secondary, emoji: EMOJI_OBJECTS['neonsparkle'], disabled: current_page == 'rare')
      r.button(custom_id: "coll_legendary_#{target_uid}", label: 'Legendary', style: current_page == 'legendary' ? :success : :secondary, emoji: '🌟', disabled: current_page == 'legendary')
      if owns_goddess
        r.button(custom_id: "coll_goddess_#{target_uid}", label: 'Goddess', style: current_page == 'goddess' ? :success : :secondary, emoji: '💎', disabled: current_page == 'goddess')
      end
    end
  end
end