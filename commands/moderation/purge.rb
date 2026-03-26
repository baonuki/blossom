# ==========================================
# COMMAND: purge
# DESCRIPTION: Bulk-delete messages from the current channel.
# CATEGORY: Moderation
# ==========================================

# ------------------------------------------
# LOGIC: Purge Execution
# ------------------------------------------
def execute_purge(event, amount)
  # 1. Security: Verify 'Manage Messages' permission in the specific channel
  unless event.user.permission?(:manage_messages, event.channel)
    return event.respond(content: "#{EMOJI_STRINGS['x_']} *You don't have permission to do that!*", ephemeral: true)
  end

  # 2. Validation: Ensure the amount is within Discord's API limits (1-100)
  amt = amount.to_i
  unless amt.between?(1, 100)
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['confused']} Invalid Amount" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Give me a number between **1** and **100**.\n`#{PREFIX}purge <amount>`" }
    ]}])
  end

  # 3. Preparation: Identify trigger type and 'defer' Slash interactions to prevent timeouts
  is_slash = event.is_a?(Discordrb::Events::ApplicationCommandEvent)
  event.defer(ephemeral: true) if is_slash

  begin
    # 4. Math: If using Prefix, we delete 'amt + 1' to include the 'b!purge' message itself.
    # Slash commands don't have a trigger message in the channel, so we use the raw amount.
    delete_count = is_slash ? amt : amt + 1
    event.channel.prune(delete_count)

    success_msg = ":broom: Successfully swept away **#{amt}** messages!"

    # 5. UI: Handle success feedback
    if is_slash
      # Edit the deferred interaction response
      event.edit_response(content: success_msg)
    else
      # Send a fresh message and delete it after 3 seconds to keep the chat clean
      msg = event.respond(success_msg)
      sleep 3
      msg.delete rescue nil
    end

  rescue => e
    # 6. Error Handling: Catch 2-week-old message limits or permission errors
    error_msg = "#{EMOJI_STRINGS['x_']} *I couldn't delete messages! Error:* `#{e.message}`"
    if is_slash
      event.edit_response(content: error_msg)
    else
      event.respond(error_msg)
    end
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!purge)
# ------------------------------------------
$bot.command(:purge,
  description: 'Deletes a number of messages',
  required_permissions: [:manage_messages]
) do |event, amount|
  execute_purge(event, amount)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/purge)
# ------------------------------------------
$bot.application_command(:purge) do |event|
  execute_purge(event, event.options['amount'])
end
