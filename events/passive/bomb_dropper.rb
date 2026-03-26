# ==========================================
# EVENT: Passive Bomb Dropper
# DESCRIPTION: Counts messages in active servers and randomly
# drops a "bomb" of coins when the threshold is reached.
# ==========================================

$bot.message do |event|
  next unless event.server
  next if event.author.bot_account?

  sid = event.server.id
  config = SERVER_BOMB_CONFIGS[sid]
  
  # Only track messages if the server has the feature enabled
  next unless config && config['enabled']

  uid = event.author.id

  # Prevent a single user from spamming to trigger the bomb
  if config['last_user_id'] != uid
    config['message_count'] += 1
    config['last_user_id'] = uid

    # Save the updated message count to the database
    DB.save_bomb_config(sid, true, config['channel_id'], config['threshold'], config['message_count'])

    # If the threshold is hit, drop the bomb!
    if config['message_count'] >= config['threshold']
      target_channel = $bot.channel(config['channel_id'], event.server)
      
      if target_channel
        embed = Discordrb::Webhooks::Embed.new(
          title: "#{EMOJIS['bomb']} INCOMING BOMB!",
          description: "A rogue bomb just dropped into the chat!\nQuick, click the button below to defuse it and steal the coins inside!",
          color: 0xFF0000
        )
        
        view = Discordrb::Components::View.new do |v|
          v.row { |r| r.button(custom_id: "defuse_drop_#{sid}", label: 'Cut the Wire!', style: :danger, emoji: '✂️') }
        end
        
        target_channel.send_message(nil, false, embed, nil, nil, nil, view)
      end

      # Reset the tracker and generate a new random threshold
      config['message_count'] = 0
      config['last_user_id'] = nil
      config['threshold'] = rand(BOMB_MIN_MESSAGES..BOMB_MAX_MESSAGES)
      
      DB.save_bomb_config(sid, true, config['channel_id'], config['threshold'], 0)
    end
  end
end