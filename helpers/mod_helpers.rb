# ==========================================
# HELPER: Moderation & Input Parsing
# DESCRIPTION: Sanitizes user inputs, mentions, and IDs.
# Handles ephemeral responses for moderation commands.
# ==========================================

# Safely extracts a user ID from a raw string or mention, 
# then fetches the actual Member object from the server.
def parse_member(event, input)
  return nil unless input
  id = input.to_s.gsub(/[^\d]/, '').to_i
  event.server.member(id)
end

# Strips all formatting (like <@&...>) and returns just the raw numerical ID
def parse_id(input)
  return nil unless input
  id = input.to_s.gsub(/[^\d]/, '').to_i
  id > 0 ? id : nil
end

# Safely extracts a role ID from a raw string or mention,
# then fetches the actual Role object from the server.
def parse_role(event, input)
  return nil unless input
  id = input.to_s.gsub(/[^\d]/, '').to_i
  event.server.role(id)
end

# A specialized reply method for Moderation commands.
# If a command (like /purge) deletes messages, this handles 
# sending the success message and then auto-deleting it 3 seconds later!
def mod_reply(event, text, is_ephemeral: false)
  if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
    event.respond(content: text, ephemeral: is_ephemeral)
  else
    msg = event.respond(text)
    
    # Auto-delete the success message for clear/purge commands so it doesn't clutter chat
    if text.include?("swept away") && !is_ephemeral
      sleep 3
      msg.delete rescue nil
    end
  end
end