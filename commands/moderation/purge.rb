def execute_purge(event, amount)
  return mod_reply(event, "❌ *You don't have permission to do that!*", is_ephemeral: true) unless event.user.permission?(:manage_messages, event.channel)
  
  amt = amount.to_i
  return mod_reply(event, "🌸 *Please provide a number between 1 and 100!*", is_ephemeral: true) unless amt.between?(1, 100)

  is_slash = event.is_a?(Discordrb::Events::ApplicationCommandEvent)
  event.defer(ephemeral: true) if is_slash

  begin
    delete_count = is_slash ? amt : amt + 1
    event.channel.prune(delete_count)
    
    success_msg = "🧹 Successfully swept away #{amt} messages!"
    
    if is_slash
      event.edit_response(content: success_msg)
    else
      msg = event.respond(success_msg)
      sleep 3
      msg.delete rescue nil
    end
  rescue => e
    error_msg = "❌ *I couldn't delete messages! Error:* `#{e.message}`"
    if is_slash
      event.edit_response(content: error_msg)
    else
      mod_reply(event, error_msg, is_ephemeral: true)
    end
  end
end

bot.command(:purge, description: 'Deletes a number of messages', required_permissions: [:manage_messages]) do |event, amount|
  execute_purge(event, amount)
  nil
end

bot.application_command(:purge) do |event|
  execute_purge(event, event.options['amount'])
end