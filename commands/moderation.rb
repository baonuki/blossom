module Moderation
  extend Discordrb::Commands::CommandContainer
  extend Discordrb::EventContainer

  def self.parse_member(event, input)
    return nil unless input
    id = input.to_s.gsub(/[^\d]/, '').to_i
    event.server.member(id)
  end

  def self.parse_id(input)
    return nil unless input
    id = input.to_s.gsub(/[^\d]/, '').to_i
    id > 0 ? id : nil
  end

  def self.reply(event, text, is_ephemeral: false)
    if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
      event.respond(content: text, ephemeral: is_ephemeral)
    else
      msg = event.respond(text)
      if text.include?("swept away") && !is_ephemeral
        sleep 3
        msg.delete rescue nil
      end
    end
  end

  def self.parse_role(event, input)
    return nil unless input
    id = input.to_s.gsub(/[^\d]/, '').to_i
    event.server.role(id)
  end

  # ==========================================
  # LOGGING SETUP COMMANDS
  # ==========================================

  def self.execute_logsetup(event, channel)
    unless event.user.permission?(:manage_server) || event.user.id == DEV_ID
      return reply(event, "❌ *You need the Manage Server permission to set up logging!*", is_ephemeral: true)
    end

    if channel.nil?
      return reply(event, "⚠️ *Please tag the channel you want logs sent to. Example: `#{PREFIX}logsetup #logs`*", is_ephemeral: true)
    end

    DB.set_log_channel(event.server.id, channel.id)
    reply(event, "✅ **Logging Configured**\nAll server logs will now be sent to #{channel.mention}.\n\n*Use `#{PREFIX}logtoggle` to choose what gets logged!*")
  end

  def self.execute_logtoggle(event, type)
    unless event.user.permission?(:manage_server) || event.user.id == DEV_ID
      return reply(event, "❌ *You need the Manage Server permission to do this!*", is_ephemeral: true)
    end

    valid_types = { 'deletes' => 'log_deletes', 'edits' => 'log_edits', 'mod' => 'log_mod', 'dms' => 'dm_mods' }
    type = type&.downcase

    unless valid_types.key?(type)
      return reply(event, "⚠️ *Please specify what you want to toggle: `deletes`, `edits`, `mod`, or `dms`.*", is_ephemeral: true)
    end

    db_column = valid_types[type]
    is_now_on = DB.toggle_log_setting(event.server.id, db_column)
    status = is_now_on ? "**ON** 🟢" : "**OFF** 🔴"

    reply(event, "⚙️ **Logging Updated**\nLogging for **#{type}** is now #{status}.")
  end

  # ==========================================
  # CORE MODERATION ENGINES
  # ==========================================
  
  def self.execute_purge(event, amount)
    return reply(event, "❌ *You don't have permission to do that!*", is_ephemeral: true) unless event.user.permission?(:manage_messages, event.channel)
    
    amt = amount.to_i
    return reply(event, "🌸 *Please provide a number between 1 and 100!*", is_ephemeral: true) unless amt.between?(1, 100)

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
        reply(event, error_msg, is_ephemeral: true)
      end
    end
  end

  def self.execute_kick(event, member, reason)
    return reply(event, "❌ *You don't have permission to do that!*", is_ephemeral: true) unless event.user.permission?(:kick_members)
    return reply(event, "🌸 *I couldn't find that user in this server!*", is_ephemeral: true) unless member
    
    reason = "No reason provided." if reason.nil? || reason.to_s.strip.empty?

    begin
      config = DB.get_log_config(event.server.id)
      member.pm("You have been kicked from **#{event.server.name}**.\nReason: #{reason}") rescue nil if config[:dm_mods]
      event.server.kick(member, reason)
      reply(event, "👢 Successfully kicked **#{member.display_name}**.\n*Reason:* #{reason}")

      log_mod_action(
        event.bot, 
        event.server.id, 
        "👢 Member Kicked", 
        "**User:** #{member.mention} (#{member.distinct})\n**Moderator:** #{event.user.mention}\n**Reason:** #{reason}",
        0xFF8C00
      )
    rescue => e
      reply(event, "❌ *Action Failed! Error:* `#{e.message}`\n*(Make sure my Bot Role is placed higher than theirs!)*", is_ephemeral: true)
    end
  end

  def self.execute_ban(event, user_input, reason)
    return reply(event, "❌ *You don't have permission to do that!*", is_ephemeral: true) unless event.user.permission?(:ban_members)
    
    target_id = parse_id(user_input)
    return reply(event, "🌸 *Please provide a valid user ID or mention!*", is_ephemeral: true) unless target_id
    
    reason = "No reason provided." if reason.nil? || reason.to_s.strip.empty?

    begin
      member = event.server.member(target_id)
      config = DB.get_log_config(event.server.id)
      member.pm("You have been timed out in **#{event.server.name}** for #{duration_str}.\nReason: #{reason}") rescue nil if config[:dm_mods]

      event.server.ban(target_id, 0, reason: reason)
      reply(event, "🔨 Successfully banned ID **#{target_id}**.\n*Reason:* #{reason}")

      mention = member ? member.mention : "<@#{target_id}>"
      distinct = member ? member.distinct : "Unknown Tag"

      log_mod_action(
        event.bot, 
        event.server.id, 
        "🔨 Member Banned", 
        "**User:** #{mention} (#{distinct})\n**Moderator:** #{event.user.mention}\n**Reason:** #{reason}",
        0x8B0000
      )
    rescue => e
      reply(event, "❌ *Action Failed! Error:* `#{e.message}`\n*(Make sure my Bot Role is placed higher than theirs!)*", is_ephemeral: true)
    end
  end

  def self.execute_timeout(event, member, duration_str, reason)
    return reply(event, "❌ *You don't have permission to do that!*", is_ephemeral: true) unless event.user.permission?(:moderate_members) || event.user.permission?(:kick_members)
    return reply(event, "🌸 *I couldn't find that user in this server!*", is_ephemeral: true) unless member
    return reply(event, "🌸 *Please provide a duration! (e.g., 10m, 1h)*", is_ephemeral: true) unless duration_str

    duration_str = duration_str.to_s 

    minutes = duration_str.to_i
    minutes *= 60 if duration_str.end_with?('h')
    minutes *= 1440 if duration_str.end_with?('d')

    return reply(event, "🌸 *Please provide a valid number of minutes!*", is_ephemeral: true) if minutes <= 0

    reason = "No reason provided." if reason.nil? || reason.to_s.strip.empty?
    expire_time = (Time.now.utc + (minutes * 60)).iso8601

    begin
      config = DB.get_log_config(event.server.id)
      member.pm("You have been timed out in **#{event.server.name}** for #{duration_str}.\nReason: #{reason}") rescue nil if config[:dm_mods]
      
      Discordrb::API::Server.update_member(
        event.bot.token,
        event.server.id,
        member.id,
        communication_disabled_until: expire_time,
        reason: reason
      )
      
      reply(event, "⏱️ **#{member.display_name}** has been timed out for #{duration_str}.\n*Reason:* #{reason}")

      log_mod_action(
        event.bot, 
        event.server.id, 
        "⏳ Member Timed Out", 
        "**User:** #{member.mention} (#{member.distinct})\n**Moderator:** #{event.user.mention}\n**Duration:** #{duration_str}\n**Reason:** #{reason}",
        0xFFFF00
      )
    rescue => e
      reply(event, "❌ *Action Failed! Error:* `#{e.message}`\n*(Make sure my Bot Role is placed higher than theirs!)*", is_ephemeral: true)
    end
  end

  def self.execute_verifysetup(event, channel_input, role_input)
    unless event.user.permission?(:manage_server) || event.user.id == DEV_ID
      return reply(event, "❌ *You need the Manage Server permission to do this!*", is_ephemeral: true)
    end

    channel = nil
    if channel_input.to_s.match(/<#(\d+)>/)
      channel = event.bot.channel($1.to_i)
    elsif channel_input.is_a?(Discordrb::Channel)
      channel = channel_input
    end

    role = parse_role(event, role_input)

    return reply(event, "⚠️ *Please mention a valid channel and a role! Example: `#{PREFIX}verifysetup #welcome @Verified`*", is_ephemeral: true) if channel.nil? || role.nil?

    embed = Discordrb::Webhooks::Embed.new(
      title: "🛡️ Server Verification",
      description: "Welcome to **#{event.server.name}**!\n\nPlease press the button below to prove you are human and gain access to the rest of the server.",
      color: 0x98FB98 # Pale Green
    )

    view = Discordrb::Components::View.new do |v|
      v.row do |r|
        r.button(custom_id: 'verify_start', label: 'Start Verification', style: :success, emoji: '✅')
      end
    end

    begin
      channel.send_message(nil, false, embed, nil, nil, nil, view)
      DB.set_verification(event.server.id, channel.id, role.id)
      reply(event, "✅ **Verification Set Up!**\nThe verification panel has been sent to #{channel.mention} and will grant the **#{role.name}** role.")
    rescue => e
      reply(event, "❌ *I couldn't send the message! Do I have permission to type in that channel?*", is_ephemeral: true)
    end
  end

  # ==========================================
  # PREFIX COMMAND LISTENERS
  # ==========================================

  command(:logsetup, description: 'Set the channel for server logs (Admin)') do |event, channel_mention|
    channel = nil
    if channel_mention && channel_mention.match(/<#(\d+)>/)
      channel_id = $1.to_i
      channel = event.bot.channel(channel_id)
    end
    execute_logsetup(event, channel)
    nil
  end

  command(:logtoggle, description: 'Toggle logging for deletes, edits, or mod actions') do |event, type|
    execute_logtoggle(event, type)
    nil
  end

  command(:purge, description: 'Deletes a number of messages', required_permissions: [:manage_messages]) do |event, amount|
    execute_purge(event, amount)
    nil
  end

  command(:kick, description: 'Kicks a user', required_permissions: [:kick_members]) do |event, user_input, *reason_array|
    member = parse_member(event, user_input)
    reason = reason_array.join(' ')
    execute_kick(event, member, reason)
    nil
  end

  command(:ban, description: 'Bans a user (or ID)', required_permissions: [:ban_members]) do |event, user_input, *reason_array|
    reason = reason_array.join(' ')
    execute_ban(event, user_input, reason)
    nil
  end

  command(:timeout, description: 'Timeouts a user', required_permissions: [:moderate_members]) do |event, user_input, duration, *reason_array|
    member = parse_member(event, user_input)
    reason = reason_array.join(' ')
    execute_timeout(event, member, duration, reason)
    nil
  end

  command(:verifysetup, description: 'Set up the verification panel', required_permissions: [:manage_server]) do |event, channel_mention, role_mention|
    execute_verifysetup(event, channel_mention, role_mention)
    nil
  end

  # ==========================================
  # SLASH COMMAND LISTENERS
  # ==========================================

  application_command(:logsetup) do |event|
    channel_id = event.options['channel'].to_i
    channel = event.bot.channel(channel_id)
    execute_logsetup(event, channel)
  end

  application_command(:logtoggle) do |event|
    execute_logtoggle(event, event.options['type'])
  end

  application_command(:purge) do |event|
    execute_purge(event, event.options['amount'])
  end

  application_command(:kick) do |event|
    member = parse_member(event, event.options['user'])
    execute_kick(event, member, event.options['reason'])
  end

  application_command(:ban) do |event|
    execute_ban(event, event.options['user'], event.options['reason'])
  end

  application_command(:timeout) do |event|
    member = parse_member(event, event.options['user'])
    execute_timeout(event, member, event.options['duration'] || event.options['minutes'], event.options['reason'])
  end

  application_command(:verifysetup) do |event|
    channel = event.bot.channel(event.options['channel'].to_i)
    execute_verifysetup(event, channel, event.options['role'])
  end

end