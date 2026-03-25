# ==========================================
# COMMAND: disablebombs
# DESCRIPTION: Deactivates the server's message-based bomb drop system.
# CATEGORY: Admin
# ==========================================

# ------------------------------------------
# LOGIC: Disable Bomb Execution
# ------------------------------------------
def execute_disablebombs(event)
  # 1. Identifier: Capture the current Server ID
  sid = event.server.id
  
  # 2. State Check: Only proceed if a configuration exists for this server
  if SERVER_BOMB_CONFIGS[sid]
    # 3. Memory Update: Toggle the local active state to false
    SERVER_BOMB_CONFIGS[sid]['enabled'] = false
    
    # 4. Database Sync: Persist the disabled status to PostgreSQL
    # We pass 0 for threshold and count as they are no longer relevant while disabled.
    DB.save_bomb_config(sid, false, SERVER_BOMB_CONFIGS[sid]['channel_id'], 0, 0)
    
    # 5. UI Feedback: Detect and handle response based on event type
    if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
      event.respond(content: "💣 Bomb drops disabled for this server.")
    else
      event.respond("💣 Bomb drops disabled for this server.")
    end
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!disablebombs)
# ------------------------------------------
bot.command(:disablebombs, 
  description: 'Disable message bomb drops in this server.',
  category: 'Admin'
) do |event|
  execute_disablebombs(event)
  nil # Suppress automatic message return
end

# ------------------------------------------
# TRIGGER: Slash Command (/disablebombs)
# ------------------------------------------
bot.application_command(:disablebombs) do |event|
  execute_disablebombs(event)
end