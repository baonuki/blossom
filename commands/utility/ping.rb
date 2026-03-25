def execute_ping(event, timestamp)
  time_diff = Time.now - timestamp
  latency_ms = (time_diff * 1000).round 
  send_embed(event, title: "#{EMOJIS['play']} Pong!", description: "My connection to Discord is **#{latency_ms}ms**.\nChat is moving fast!")
end

bot.command(:ping, description: 'Check bot latency', category: 'Utility') { |e| execute_ping(e, e.message.timestamp); nil }
bot.application_command(:ping) { |e| execute_ping(e, (e.interaction.creation_time rescue Time.now)) }