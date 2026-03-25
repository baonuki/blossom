# ==========================================
# COMMAND: suggest
# DESCRIPTION: Send a private suggestion embed to the bot developer.
# CATEGORY: Utility
# ==========================================

# ------------------------------------------
# LOGIC: Suggestion Execution
# ------------------------------------------
def execute_suggest(event, suggestion_text)
  # 1. Validation: Ensure the user actually typed a suggestion
  if suggestion_text.nil? || suggestion_text.strip.empty?
    return send_embed(
      event, 
      title: "⚠️ Missing Suggestion", 
      description: "Please tell me what you'd like to suggest!\nExample: `#{PREFIX}suggest Add a fishing minigame!`"
    )
  end

  # 2. Retrieval: Locate the developer user object in the bot's cache
  dev_user = event.bot.user(DEV_ID)

  unless dev_user
    return send_embed(
      event, 
      title: "❌ Error", 
      description: "I couldn't find my developer in my cache! Try again later."
    )
  end

  # 3. Context: Determine the origin of the suggestion (Server name or DM)
  server_name = event.server ? event.server.name : "Direct Messages"
  
  # 4. UI: Construct the Developer-Facing Embed
  dev_embed = Discordrb::Webhooks::Embed.new(
    title: "💡 New Bot Suggestion",
    description: "**From:** #{event.user.mention} *(#{event.user.distinct})*\n" \
                 "**Server:** #{server_name}\n\n" \
                 "**Suggestion:**\n#{suggestion_text}",
    color: 0xFFD700, # Gold (Important feedback color)
    timestamp: Time.now
  )
  dev_embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "User ID: #{event.user.id}")

  begin
    # 5. Delivery: Open a DM channel with the developer and send the report
    pm_channel = dev_user.pm
    pm_channel.send_message(nil, false, dev_embed)
    
    # 6. Feedback: Confirm successful delivery to the user
    send_embed(
      event, 
      title: "✅ Suggestion Sent!", 
      description: "Thank you! Your suggestion has been sent directly to my developer. 🌸"
    )
  rescue => e
    # 7. Error Handling: Catch instances where the developer has DMs disabled
    puts "[SUGGEST ERROR] #{e.message}"
    send_embed(
      event, 
      title: "❌ Delivery Failed", 
      description: "I couldn't send the suggestion. My developer might have their DMs closed right now!"
    )
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!suggest)
# ------------------------------------------
bot.command(:suggest, 
  description: 'Send a suggestion directly to the developer!', 
  category: 'Utility'
) do |event, *args|
  # Joins the argument array into a single string
  execute_suggest(event, args.join(' '))
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/suggest)
# ------------------------------------------
bot.application_command(:suggest) do |event|
  execute_suggest(event, event.options['suggestion'])
end