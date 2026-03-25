def execute_disablebombs(event)
  sid = event.server.id
  
  if SERVER_BOMB_CONFIGS[sid]
    SERVER_BOMB_CONFIGS[sid]['enabled'] = false
    DB.save_bomb_config(sid, false, SERVER_BOMB_CONFIGS[sid]['channel_id'], 0, 0)
    
    if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
      event.respond(content: "💣 Bomb drops disabled for this server.")
    else
      event.respond("💣 Bomb drops disabled for this server.")
    end
  end
end

bot.command(:disablebombs, category: 'Admin') do |event|
  execute_disablebombs(event)
  nil
end

bot.application_command(:disablebombs) do |event|
  execute_disablebombs(event)
end