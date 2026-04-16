# ==========================================
# COMMAND: automod
# DESCRIPTION: Configure auto-moderation settings.
# CATEGORY: Admin
# ==========================================

def execute_automod(event, action = nil, *args)
  unless event.user.permission?(:administrator, event.channel) || DEV_IDS.include?(event.user.id)
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Access Denied" },
      { type: 14, spacing: 1 },
      { type: 10, content: "You need Admin perms to configure auto-mod." }
    ]}])
  end

  sid = event.server.id
  config = DB.get_automod_config(sid)

  # No action = show status
  if action.nil?
    word_count = DB.get_automod_words(sid).size

    return send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
      { type: 10, content: "## \u{1F6E1}\u{FE0F} Auto-Mod Settings" },
      { type: 14, spacing: 1 },
      { type: 10, content: "**Link Filter:** #{config['link_filter'] ? "\u2705 ON" : "\u274C OFF"}\n**Spam Filter:** #{config['spam_filter'] ? "\u2705 ON" : "\u274C OFF"}\n**Banned Words:** #{word_count} word#{word_count == 1 ? '' : 's'} banned\n\n**Commands:**\n`#{PREFIX}automod links` \u2014 Toggle link filter\n`#{PREFIX}automod spam` \u2014 Toggle spam filter\n`#{PREFIX}automod words add <word>` \u2014 Add banned word\n`#{PREFIX}automod words remove <word>` \u2014 Remove banned word\n`#{PREFIX}automod words list` \u2014 View banned words (DM only)#{mom_remark(event.user.id, 'admin')}" }
    ]}])
  end

  case action.downcase
  when 'links'
    new_state = DB.toggle_automod_setting(sid, 'link_filter')
    status = new_state ? "\u2705 **ON**" : "\u274C **OFF**"
    send_cv2(event, [{ type: 17, accent_color: new_state ? 0x00FF00 : 0xFF0000, components: [
      { type: 10, content: "## \u{1F6E1}\u{FE0F} Link Filter" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Link filter is now #{status}.\n#{new_state ? "Messages containing links from non-admins will be deleted." : "Links are allowed again."}#{mom_remark(event.user.id, 'admin')}" }
    ]}])

  when 'spam'
    new_state = DB.toggle_automod_setting(sid, 'spam_filter')
    status = new_state ? "\u2705 **ON**" : "\u274C **OFF**"
    send_cv2(event, [{ type: 17, accent_color: new_state ? 0x00FF00 : 0xFF0000, components: [
      { type: 10, content: "## \u{1F6E1}\u{FE0F} Spam Filter" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Spam filter is now #{status}.\n#{new_state ? "Users sending #{SPAM_MESSAGE_LIMIT}+ messages in #{SPAM_TIME_WINDOW}s will be timed out for #{SPAM_MUTE_DURATION}s." : "Spam detection is off."}#{mom_remark(event.user.id, 'admin')}" }
    ]}])

  when 'words'
    sub_action = args[0]&.downcase
    word = args[1]

    case sub_action
    when 'add'
      unless word && !word.empty?
        return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
          { type: 10, content: "## #{EMOJI_STRINGS['confused']} Add What?" },
          { type: 14, spacing: 1 },
          { type: 10, content: "Specify a word to ban.\n`#{PREFIX}automod words add <word>`" }
        ]}])
      end

      DB.add_automod_word(sid, word)
      send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: [
        { type: 10, content: "## \u{1F6E1}\u{FE0F} Word Added" },
        { type: 14, spacing: 1 },
        { type: 10, content: "Added `#{word.downcase}` to the banned words list. Messages containing this word will be deleted.#{mom_remark(event.user.id, 'admin')}" }
      ]}])

    when 'remove'
      unless word && !word.empty?
        return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
          { type: 10, content: "## #{EMOJI_STRINGS['confused']} Remove What?" },
          { type: 14, spacing: 1 },
          { type: 10, content: "Specify a word to remove.\n`#{PREFIX}automod words remove <word>`" }
        ]}])
      end

      DB.remove_automod_word(sid, word)
      send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
        { type: 10, content: "## \u{1F6E1}\u{FE0F} Word Removed" },
        { type: 14, spacing: 1 },
        { type: 10, content: "Removed `#{word.downcase}` from the banned words list.#{mom_remark(event.user.id, 'admin')}" }
      ]}])

    when 'list'
      words = DB.get_automod_words(sid)
      word_list = words.empty? ? "*No banned words set*" : words.map { |w| "`#{w}`" }.join(', ')
      begin
        event.user.pm("## \u{1F6E1}\u{FE0F} Banned Words for #{event.server.name}\n\n#{word_list}")
        send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
          { type: 10, content: "## \u{1F6E1}\u{FE0F} Banned Words" },
          { type: 14, spacing: 1 },
          { type: 10, content: "Sent the banned words list to your DMs! Check your inbox.#{mom_remark(event.user.id, 'admin')}" }
        ]}])
      rescue
        send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
          { type: 10, content: "## #{EMOJI_STRINGS['error']} DMs Closed" },
          { type: 14, spacing: 1 },
          { type: 10, content: "I can't DM you the list. Open your DMs and try again!" }
        ]}])
      end

    else
      send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
        { type: 10, content: "## #{EMOJI_STRINGS['confused']} Words Action" },
        { type: 14, spacing: 1 },
        { type: 10, content: "Use `add`, `remove`, or `list`.\n`#{PREFIX}automod words add <word>`\n`#{PREFIX}automod words remove <word>`\n`#{PREFIX}automod words list`" }
      ]}])
    end

  else
    send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['confused']} Invalid Option" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Available options: `links`, `spam`, `words`\n`#{PREFIX}automod` to see current settings." }
    ]}])
  end
end

# ------------------------------------------
# TRIGGERS
# ------------------------------------------
$bot.command(:automod,
  description: 'Configure auto-moderation (Admin Only)',
  category: 'Admin'
) do |event, action, *args|
  execute_automod(event, action, *args)
  nil
end

$bot.application_command(:automod) do |event|
  action = event.options['action']
  sub_action = event.options['subaction']
  word = event.options['word']
  execute_automod(event, action, sub_action, word)
end
