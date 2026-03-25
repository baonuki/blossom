def execute_enablebombs(event, channel_id)
  unless event.user.permission?(:administrator, event.channel) || event.user.id == DEV_ID
    return event.respond("#{EMOJIS['x_']} You need Administrator permissions to set this up!")
  end

  target_channel = event.bot.channel(channel_id, event.server)

  if target_channel.nil?
    return event.respond("#{EMOJIS['x_']} Please mention a valid channel! Usage: `#{PREFIX}enablebombs #channel-name`")
  end

  sid = event.server.id
  threshold = rand(BOMB_MIN_MESSAGES..BOMB_MAX_MESSAGES)

  SERVER_BOMB_CONFIGS[sid] = {
    'enabled' => true,
    'channel_id' => channel_id,
    'message_count' => 0,
    'last_user_id' => nil,
    'threshold' => threshold
  }

  DB.save_bomb_config(sid, true, channel_id, threshold, 0)
  send_embed(event, title: "#{EMOJIS['bomb']} Bomb Drops Enabled!", description: "I will now randomly drop bombs in <##{channel_id}> as people chat!")
end

bot.command(:enablebombs, description: 'Enable random bomb drops in a specific channel (Admin Only)', min_args: 1, category: 'Admin') do |event, channel_mention|
  execute_enablebombs(event, channel_mention.gsub(/[<#>]/, '').to_i)
  nil
end

bot.application_command(:enablebombs) do |event|
  execute_enablebombs(event, event.options['channel'].to_i)
end