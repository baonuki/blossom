# ==========================================
# COMMAND: dticketsetup
# DESCRIPTION: Posts a support ticket panel embed with select menu.
# CATEGORY: Developer
# ==========================================

TICKET_CATEGORY_ID = 1494158010979844190
TICKET_SERVER_ID   = 1499998845873033316
TICKET_STAFF_ROLE  = 1472692333588779143

SUPPORT_TICKET_OPTIONS = [
  { value: 'general',    label: 'General Support',    emoji: '💬', desc: 'General questions or help with the server' },
  { value: 'report',     label: 'Report a User',      emoji: '🚨', desc: 'Report someone breaking server rules' },
  { value: 'role',       label: 'Role Request',        emoji: '🏷️', desc: 'Request a role or report role issues' },
  { value: 'collab',     label: 'Collaboration',       emoji: '🤝', desc: 'Inquire about collabs or partnerships' },
  { value: 'bot',        label: 'Bot Issue',           emoji: '🤖', desc: 'Report a Blossom bug or bot-related issue' },
  { value: 'feedback',   label: 'Feedback',            emoji: '💡', desc: 'Suggestions, ideas, or server feedback' },
  { value: 'other',      label: 'Other',               emoji: '📋', desc: 'Anything else not listed above' }
].freeze

def execute_dticketsetup(event, channel_id)
  return unless DEV_IDS.include?(event.user.id)

  unless channel_id
    return send_cv2(event, [{ type: 17, accent_color: 0xFF0000, components: [
      { type: 10, content: "## #{EMOJI_STRINGS['x_']} Missing Channel" },
      { type: 14, spacing: 1 },
      { type: 10, content: "Usage: `#{PREFIX}dticketsetup #channel`" }
    ]}])
  end

  # Build the select menu options
  select_options = SUPPORT_TICKET_OPTIONS.map { |opt|
    { label: opt[:label], value: opt[:value], description: opt[:desc], emoji: { name: opt[:emoji] } }
  }

  # Post the panel embed in the target channel
  body = {
    content: '', flags: CV2_FLAG,
    components: [{
      type: 17, accent_color: 0x7C3AED,
      components: [
        { type: 10, content: "## 🎫 Support Tickets" },
        { type: 14, spacing: 1 },
        { type: 10, content: "Need help? Have a question? Want to report something?\n\nSelect a category below to open a support ticket. A staff member will be with you shortly!\n\n**Please don't open duplicate tickets** — one at a time, chat." },
        { type: 14, spacing: 1 },
        { type: 1, components: [
          { type: 3, custom_id: "ticket_support_open", placeholder: "Select a ticket category...", options: select_options }
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
    { type: 10, content: "## #{EMOJI_STRINGS['checkmark']} Ticket Panel Posted!" },
    { type: 14, spacing: 1 },
    { type: 10, content: "Support ticket panel is live in <##{channel_id}>.#{mom_remark(event.user.id, 'dev')}" }
  ]}])
end

$bot.command(:dticketsetup,
  description: 'Post support ticket panel (Dev Only)',
  category: 'Developer'
) do |event, channel_mention|
  channel_id = channel_mention ? channel_mention.gsub(/[<#>]/, '').to_i : nil
  execute_dticketsetup(event, channel_id)
  nil
end

$bot.application_command(:dticketsetup) do |event|
  channel_id = event.options['channel']&.to_i
  execute_dticketsetup(event, channel_id)
end
