# ==========================================
# COMMAND: enablebombs (Admin Only)
# DESCRIPTION: Activates the random bomb drop system in a specific channel.
# CATEGORY: Admin
# ==========================================

# ------------------------------------------
# LOGIC: Enable Bomb Execution
# ------------------------------------------
def execute_enablebombs(event, channel_id)
  # 1. Security: Permission Check (Admins or Developer Only)
  unless event.user.permission?(:administrator, event.channel) || event.user.id == DEV_ID
    return event.respond("#{EMOJIS['x_']} You need Administrator permissions to set this up!")
  end

  # 2. Validation: Verify the existence of the target channel
  target_channel = event.bot.channel(channel_id, event.server)

  if target_channel.nil?
    return event.respond("#{EMOJIS['x_']} Please mention a valid channel! Usage: `#{PREFIX}enablebombs #channel-name`")
  end

  # 3. Initialization: Capture Server ID and generate a random drop threshold
  sid = event.server.id
  threshold = rand(BOMB_MIN_MESSAGES..BOMB_MAX_MESSAGES)

  # 4. Memory Update: Store the configuration in the global tracking hash
  SERVER_BOMB_CONFIGS[sid] = {
    'enabled' => true,
    'channel_id' => channel_id,
    'message_count' => 0,
    'last_user_id' => nil,
    'threshold' => threshold
  }

  # 5. Database: Save the active configuration to the PostgreSQL 'server_bombs' table
  DB.save_bomb_config(sid, true, channel_id, threshold, 0)

  # 6. UI: Success confirmation via Embed
  send_embed(event, 
    title: "#{EMOJIS['bomb']} Bomb Drops Enabled!", 
    description: "I will now randomly drop bombs in <##{channel_id}> as people chat!"
  )
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!enablebombs)
# ------------------------------------------
bot.command(:enablebombs, 
  description: 'Enable random bomb drops in a specific channel (Admin Only)', 
  min_args: 1, 
  category: 'Admin'
) do |event, channel_mention|
  # Strip the mention syntax (<#ID>) to extract the raw ID
  execute_enablebombs(event, channel_mention.gsub(/[<#>]/, '').to_i)
  nil
end

# ------------------------------------------
# TRIGGER: Slash Command (/enablebombs)
# ------------------------------------------
bot.application_command(:enablebombs) do |event|
  execute_enablebombs(event, event.options['channel'].to_i)
end