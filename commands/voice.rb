# =========================
# VOICE & MUSIC COMMANDS
# =========================

bot.command(:join, description: 'Make Blossom join your voice channel', category: 'Voice') do |event|
  channel = event.user.voice_channel
  unless channel
    send_embed(event, title: "⚠️ Error", description: "You need to be in a voice channel first!")
    next
  end

  bot.voice_connect(channel)
  send_embed(event, title: "🎤 Connected!", description: "Successfully joined **#{channel.name}**! Ready to drop a beat.")
  nil
end

bot.command(:leave, description: 'Make Blossom leave the voice channel', category: 'Voice') do |event|
  bot.voice_destroy(event.server.id)
  send_embed(event, title: "👋 Disconnected", description: "Packed up the DJ booth and left the channel.")
  nil
end

bot.command(:play, description: 'Play an MP3 file (Usage: b!play <filename>)', min_args: 1, category: 'Voice') do |event, *args|
  filename = args.join(' ')
  
  # This tells Blossom to look in the "music" folder for the file
  filepath = "./music/#{filename}.mp3" 

  channel = event.user.voice_channel
  unless channel
    send_embed(event, title: "⚠️ Error", description: "You need to be in a voice channel so I can play this!")
    next
  end

  # Auto-connect to the channel
  bot.voice_connect(channel)

  # Check if the file actually exists before trying to play it
  unless File.exist?(filepath)
    send_embed(event, title: "❌ Track Not Found", description: "I couldn't find an MP3 named **#{filename}** in my music folder. Check your spelling!")
    next
  end

  send_embed(event, title: "▶️ Now Playing", description: "Spinning up **#{filename}** in #{channel.mention}!")
  
  # Stream the audio to Discord
  event.voice.play_file(filepath)
  nil
end

bot.command(:stop, description: 'Stop the currently playing audio', category: 'Voice') do |event|
  if event.voice
    event.voice.stop_playing
    send_embed(event, title: "🛑 Audio Stopped", description: "Cut the music!")
  else
    send_embed(event, title: "⚠️ Error", description: "I'm not playing anything right now!")
  end
  nil
end