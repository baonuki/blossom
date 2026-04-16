# ==========================================
# COMMAND: dapplysetup
# DESCRIPTION: Posts a mod application panel embed with select menu.
# CATEGORY: Developer
# ==========================================

APPLICATION_OPTIONS = [
  { value: 'twitch_mod',  label: 'Twitch Moderator',  emoji: '🟣', desc: 'Apply to moderate Twitch chat and streams' },
  { value: 'discord_mod', label: 'Discord Moderator', emoji: '🔵', desc: 'Apply to moderate the Discord server' }
].freeze

def execute_dapplysetup(event, channel_id)
  return unless DEV_IDS.include?(event.user.id)

  unless channel_id
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Missing Channel" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Usage: `#{PREFIX}dapplysetup #channel`" }
    ]}])
  end

  # Build the select menu options
  select_options = APPLICATION_OPTIONS.map { |opt|
    { label: opt[:label], value: opt[:value], description: opt[:desc], emoji: { name: opt[:emoji] } }
  }

  # Post the panel embed in the target channel
  body = {
    content: '', flags: CV2_FLAG,
    components: [{
      type: 17, accent_color: 0x2563EB,
      components: [
        { type: 10, content: "## 📝 Staff Applications" },
        { type: 14, spacing: 1 },
        { type: 10, content: "Want to join the team? We're looking for dedicated moderators!\n\nSelect a position below to open an application. A private channel will be created where you can fill out your application.\n\n**Positions Available:**\n🟣 **Twitch Moderator** — Help manage chat during live streams\n🔵 **Discord Moderator** — Help maintain the Discord community\n\n*Please only apply if you're serious. One application at a time.*" },
        { type: 14, spacing: 1 },
        { type: 1, components: [
          { type: 3, custom_id: "ticket_apply_open", placeholder: "Select a position to apply for...", options: select_options }
        ]}
      ]
    }],
    allowed_mentions: { parse: [] }
  }.to_json

  Discordrb::API.request(
    :channels_cid_messages_mid, channel_id, :post,
    "#{Discordrb::API.api_base}/channels/#{channel_id}/messages",
    body, Authorization: $bot.token, content_type: :json
  )

  send_cv2(event, [{ type: 17, accent_color: 0x00FF00, components: [
    { type: 10, content: "## #{EMOJI_STRINGS['checkmark']} Application Panel Posted!" },
    { type: 14, spacing: 1 },
    { type: 10, content: "Mod application panel is live in <##{channel_id}>.#{mom_remark(event.user.id, 'dev')}" }
  ]}])
end

$bot.command(:dapplysetup,
  description: 'Post mod application panel (Dev Only)',
  category: 'Developer'
) do |event, channel_mention|
  channel_id = channel_mention ? channel_mention.gsub(/[<#>]/, '').to_i : nil
  execute_dapplysetup(event, channel_id)
  nil
end

$bot.application_command(:dapplysetup) do |event|
  channel_id = event.options['channel']&.to_i
  execute_dapplysetup(event, channel_id)
end
