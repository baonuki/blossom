# ==========================================
# COMMAND: ping
# DESCRIPTION: Measures the round-trip latency between the bot and Discord.
# CATEGORY: Utility
# ==========================================

# ------------------------------------------
# LOGIC: Latency Calculation Execution
# ------------------------------------------
def execute_ping(event, timestamp)
  # 1. Calculation: Determine the time elapsed since the command was triggered
  # Latency is calculated as:
  # $$Latency_{ms} = \text{round}((T_{current} - T_{trigger}) \times 1000)$$
  time_diff = Time.now - timestamp
  latency_ms = (time_diff * 1000).round 

  # 2. UI: Send a clean embed with the result
  send_embed(
    event, 
    title: "#{EMOJIS['play']} Pong!", 
    description: "My connection to Discord is **#{latency_ms}ms**.\nChat is moving fast!"
  )
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!ping)
# ------------------------------------------
bot.command(:ping, 
  description: 'Check bot latency', 
  category: 'Utility'
) do |event|
  # Uses the timestamp from the user's message
  execute_ping(event, event.message.timestamp)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/ping)
# ------------------------------------------
bot.application_command(:ping) do |event|
  # Uses the interaction creation time with a safety fallback to current time
  execute_ping(event, (event.interaction.creation_time rescue Time.now))
end