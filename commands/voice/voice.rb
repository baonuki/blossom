# ==========================================
# COMMAND: join
# DESCRIPTION: Summon Blossom to your current voice channel.
# ==========================================
bot.command(:join, 
  description: 'Make Blossom join your voice channel', 
  category: 'Voice'
) do |event|
  channel = event.user.voice_channel
  
  # 1. Validation: Ensure the user is actually in a channel to "pull" the bot into
  unless channel
    send_embed(event, title: "⚠️ Error", description: "You need to be in a voice channel first!")
    next
  end

  # 2. Action: Establish the voice connection
  bot.voice_connect(channel)
  send_embed(event, title: "🎤 Connected!", description: "Successfully joined **#{channel.name}**! Ready to drop a beat.")
  nil
end

# ==========================================
# COMMAND: leave
# DESCRIPTION: Disconnect Blossom and clear the voice state.
# ==========================================
bot.command(:leave, 
  description: 'Make Blossom leave the voice channel', 
  category: 'Voice'
) do |event|
  # Destroys the voice bot instance for this specific server
  bot.voice_destroy(event.server.id)
  send_embed(event, title: "👋 Disconnected", description: "Packed up the DJ booth and left the channel.")
  nil
end

# ==========================================
# COMMAND: play
# DESCRIPTION: Plays a specific MP3 file located in the bot's /music directory.
# ==========================================
bot.command(:play, 
  description: 'Play an MP3 file (Usage: b!play <filename>)', 
  min_args: 1, 
  category: 'Voice'
) do |event, *args|
  filename = args.join(' ')
  
  # 1. Pathing: Blossom looks in the local "music" folder
  filepath = "./music/#{filename}.mp3" 

  channel = event.user.voice_channel
  unless channel
    send_embed(event, title: "⚠️ Error", description: "You need to be in a voice channel so I can play this!")
    next
  end

  # 2. Logic: Auto-connect if not already in the channel
  bot.voice_connect(channel)

  # 3. Validation: Prevent crashes by checking if the file actually exists
  unless File.exist?(filepath)
    send_embed(
      event, 
      title: "❌ Track Not Found", 
      description: "I couldn't find an MP3 named **#{filename}** in my music folder. Check your spelling!"
    )
    next
  end

  # 4. Action: Stream the audio file to the Discord Voice Gateway
  send_embed(event, title: "▶️ Now Playing", description: "Spinning up **#{filename}** in #{channel.mention}!")
  event.voice.play_file(filepath)
  nil
end

# ==========================================
# COMMAND: stop
# DESCRIPTION: Immediately halts the current audio stream.
# ==========================================
bot.command(:stop, 
  description: 'Stop the currently playing audio', 
  category: 'Voice'
) do |event|
  if event.voice
    event.voice.stop_playing
    send_embed(event, title: "🛑 Audio Stopped", description: "Cut the music!")
  else
    send_embed(event, title: "⚠️ Error", description: "I'm not playing anything right now!")
  end
  nil
end