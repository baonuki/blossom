# ==========================================
# COMMAND: Event Hub
# DESCRIPTION: Opens the interactive dropdown menu for users
# to access limited-time seasonal events and minigames.
# ==========================================

def execute_event_hub(event)
  embed = Discordrb::Webhooks::Embed.new(
    title: "🗓️ Blossom Event Hub",
    description: "Welcome to the limited-time Event Hub!\n\nUse the dropdown below to select an active event. Participate in minigames, earn exclusive currency, and unlock limited-time VTubers!",
    color: 0xFF69B4 # Classic Blossom Pink
  )
  
  view = Discordrb::Components::View.new do |v|
    v.row do |r|
      r.select_menu(custom_id: "event_hub_#{event.user.id}", placeholder: "Select an active event...", max_values: 1) do |s|
        # You can easily swap these out as the seasons change!
        s.option(label: "Spring Carnival", value: "spring_carnival", emoji: "🎪", description: "April Exclusive Event!")
      end
    end
  end

  # Handle both Slash and Prefix execution smoothly
  if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
    event.respond(embeds: [embed], components: view)
  else
    event.channel.send_message(nil, false, embed, nil, nil, nil, view)
  end
end

# PREFIX COMMAND
bot.command(:event, description: 'Open the Limited Time Event Hub!', category: 'Economy') do |event|
  execute_event_hub(event)
  nil
end

# SLASH COMMAND
bot.application_command(:event) do |event|
  execute_event_hub(event)
end