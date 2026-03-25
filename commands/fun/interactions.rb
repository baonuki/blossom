# ==========================================
# COMMAND: interactions
# DESCRIPTION: Displays the user's total sent and received hugs and slaps.
# CATEGORY: Social / Fun
# ==========================================

# ------------------------------------------
# LOGIC: Interaction Stats Execution
# ------------------------------------------
def execute_interactions(event)
  # 1. Data Retrieval: Fetch the full interaction hash for the user
  # This returns a structure like: { 'hug' => { 'sent' => 0, 'received' => 0 }, ... }
  data = DB.get_interactions(event.user.id)
  
  # 2. UI: Construct the Stats Embed
  send_embed(
    event, 
    title: "📊 #{event.user.display_name}'s Interaction Stats", 
    description: "Here is your history of social interactions on the server!", 
    fields: [
      # Hugs Field: Sent vs Received
      { 
        name: "#{EMOJIS['hearts']} Hugs", 
        value: "Sent: **#{data['hug']['sent']}**\nReceived: **#{data['hug']['received']}**", 
        inline: true 
      },
      # Slaps Field: Sent vs Received
      { 
        name: "#{EMOJIS['bonk']} Slaps", 
        value: "Sent: **#{data['slap']['sent']}**\nReceived: **#{data['slap']['received']}**", 
        inline: true 
      }
    ]
  )
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!interactions)
# ------------------------------------------
bot.command(:interactions, 
  description: 'Show your hug/slap stats', 
  category: 'Fun'
) do |event|
  execute_interactions(event)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/interactions)
# ------------------------------------------
bot.application_command(:interactions) do |event|
  execute_interactions(event)
end