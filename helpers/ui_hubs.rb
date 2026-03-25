# ==========================================
# HELPER: Interactive UI Builders (Hubs & Menus)
# DESCRIPTION: Generates the embeds and component views 
# for Blossom's general navigation tools.
# ==========================================

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
        
        emoji_map = { 'Economy' => '💰', 'Gacha' => '🌟', 'Arcade' => '🕹️', 'Fun' => '🎉', 'Utility' => '🔧', 'Admin' => '🛡️' }
        visible_categories = COMMAND_CATEGORIES.keys - ['Developer']
        
        visible_categories.each do |cat|
          s.option(label: cat, value: cat, emoji: emoji_map[cat] || '🌸')
        end
      end
    end
  end
end

def balance_select_menu(user_id, current_page, ach_page = 1, total_ach_pages = 1)
  Discordrb::Components::View.new do |v|
    v.row do |r|
      r.select_menu(custom_id: "bal_menu_#{user_id}", placeholder: "Select a page to view...", max_values: 1) do |s|
        s.option(label: 'Balance & Stats', value: 'home', emoji: '💰', default: current_page == 'home')
        s.option(label: 'Inventory', value: 'inv', emoji: '🎒', default: current_page == 'inv')
        s.option(label: 'VTuber Totals', value: 'vtubers', emoji: '🌟', default: current_page == 'vtubers')
        s.option(label: 'Achievements', value: 'achievements', emoji: '🏆', default: current_page == 'achievements')
      end
    end

    if current_page == 'achievements' && total_ach_pages > 1
      v.row do |r|
        r.button(custom_id: "achpage_#{user_id}_#{ach_page - 1}", label: 'Previous', style: :primary, emoji: '◀️', disabled: ach_page <= 1)
        r.button(custom_id: "achpage_noop", label: "Page #{ach_page}/#{total_ach_pages}", style: :secondary, disabled: true)
        r.button(custom_id: "achpage_#{user_id}_#{ach_page + 1}", label: 'Next', style: :primary, emoji: '▶️', disabled: ach_page >= total_ach_pages)
      end
    end
  end
end

def leaderboard_select_menu(user_id, current_page)
  Discordrb::Components::View.new do |v|
    v.row do |r|
      r.select_menu(custom_id: "lb_menu_#{user_id}", placeholder: "Select a leaderboard...", max_values: 1) do |s|
        s.option(label: 'Server Members (XP)', value: 'server_users', emoji: '👥', description: 'Top chatters in this server', default: current_page == 'server_users')
        s.option(label: 'Global Communities', value: 'global_servers', emoji: '🌍', description: 'Most active servers on Blossom', default: current_page == 'global_servers')
        s.option(label: 'Global Richest (Coins)', value: 'global_coins', emoji: '💰', description: 'Wealthiest players globally', default: current_page == 'global_coins')
      end
    end
  end
end

def generate_leaderboard_page(bot, server, action)
  embed = Discordrb::Webhooks::Embed.new(color: 0xFFD700)
  
  case action
  when 'server_users'
    embed.title = "👥 #{server.name} Leaderboard"
    raw_top = DB.get_top_users(server.id, 50) 
    
    active_humans = []
    raw_top.each do |row|
      user_obj = bot.user(row['user_id'])
      if user_obj && !user_obj.bot_account? && server.member(user_obj.id)
        active_humans << row
        break if active_humans.size >= 10
      end
    end

    if active_humans.empty?
      embed.description = "*No humans have gained XP yet in this server!*"
    else
      desc = active_humans.each_with_index.map do |row, index|
        user_obj = bot.user(row['user_id'])
        name = user_obj.display_name
        medal = ["🥇", "🥈", "🥉"][index] || "🏅"
        "**#{index + 1}.** #{medal} **#{name}** — Level **#{row['level']}** *(#{row['xp']} XP)*"
      end.join("\n\n")
      embed.description = desc
    end

  when 'global_servers'
    embed.title = "🌍 Global Community Leaderboard"
    top_servers = DB.get_global_server_leaderboard(10) 

    if top_servers.empty?
      embed.description = "*No communities have earned XP yet!*"
    else
      desc = top_servers.each_with_index.map do |row, index|
        sid = row['server_id'].to_i
        server_obj = bot.server(sid)
        name = server_obj ? server_obj.name : "Unknown Server"
        medal = ["🏆", "🥈", "🥉"][index] || "🏅"
        bolding = (server.id == sid) ? "**" : "" 
        
        "#{bolding}**#{index + 1}.** #{medal} **#{name}** — Level **#{row['level']}** *(#{row['xp']} XP)*#{bolding}"
      end.join("\n\n")
      embed.description = desc
    end

  when 'global_coins'
    embed.title = "💰 Global Wealth Leaderboard"
    raw_top = DB.get_top_coins(50) 
    
    active_humans = []
    raw_top.each do |row|
      user_obj = bot.user(row['user_id'])
      if user_obj && !user_obj.bot_account?
        active_humans << row
        break if active_humans.size >= 10
      end
    end

    if active_humans.empty?
      embed.description = "*The global bank is currently empty!*"
    else
      desc = active_humans.each_with_index.map do |row, index|
        user_obj = bot.user(row['user_id'])
        name = user_obj ? user_obj.username : "User #{row['user_id']}"
        medal = ["🥇", "🥈", "🥉"][index] || "🏅"
        
        "**#{index + 1}.** #{medal} **#{name}** — **#{row['coins']}** #{EMOJIS['s_coin']}" 
      end.join("\n\n")
      embed.description = desc
    end
  end
  embed
end

def carnival_back_view(owner_id)
  Discordrb::Components::View.new do |v|
    v.row { |r| r.button(custom_id: "carnival_hub_#{owner_id}", label: 'Back to Carnival Hub', style: :secondary, emoji: '🎪') }
  end
end