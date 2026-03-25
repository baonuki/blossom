def execute_suggest(event, suggestion_text)
  if suggestion_text.nil? || suggestion_text.strip.empty?
    return send_embed(event, title: "⚠️ Missing Suggestion", description: "Please tell me what you'd like to suggest!\nExample: `#{PREFIX}suggest Add a fishing minigame!`")
  end

  dev_user = event.bot.user(DEV_ID)

  unless dev_user
    return send_embed(event, title: "❌ Error", description: "I couldn't find my developer in my cache! Try again later.")
  end

  server_name = event.server ? event.server.name : "Direct Messages"
  
  dev_embed = Discordrb::Webhooks::Embed.new(
    title: "💡 New Bot Suggestion",
    description: "**From:** #{event.user.mention} *(#{event.user.distinct})*\n**Server:** #{server_name}\n\n**Suggestion:**\n#{suggestion_text}",
    color: 0xFFD700, # Gold
    timestamp: Time.now
  )
  dev_embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "User ID: #{event.user.id}")

  begin
    pm_channel = dev_user.pm
    pm_channel.send_message(nil, false, dev_embed)
    
    send_embed(event, title: "✅ Suggestion Sent!", description: "Thank you! Your suggestion has been sent directly to my developer. 🌸")
  rescue => e
    puts "[SUGGEST ERROR] #{e.message}"
    send_embed(event, title: "❌ Delivery Failed", description: "I couldn't send the suggestion. My developer might have their DMs closed right now!")
  end
end

bot.command(:suggest, description: 'Send a suggestion directly to the developer!', category: 'Utility') do |event, *args|
  execute_suggest(event, args.join(' '))
  nil
end

bot.application_command(:suggest) do |event|
  execute_suggest(event, event.options['suggestion'])
end