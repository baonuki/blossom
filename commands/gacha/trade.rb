# ==========================================
# COMMAND: trade
# DESCRIPTION: Propose a 1-for-1 character swap with another user.
# CATEGORY: Gacha
# ==========================================

# ------------------------------------------
# LOGIC: Trade Execution & State Management
# ------------------------------------------
def execute_trade(event, target_user, offer_str, request_str)
  # 1. Validation: Ensure the target is valid and not the sender
  if target_user.nil? || target_user.id == event.user.id
    return send_embed(
      event, 
      title: "#{EMOJIS['confused']} Invalid Trade", 
      description: "You must select a valid user to trade with (not yourself)!\n" \
                   "**Prefix Usage:** `#{PREFIX}trade @user <Your Char> for <Their Char>`\n" \
                   "**Slash Usage:** `/trade user:@user offer:<Your Char> request:<Their Char>`"
    )
  end

  # 2. Validation: Ensure both sides of the deal are specified
  if offer_str.nil? || offer_str.strip.empty? || request_str.nil? || request_str.strip.empty?
    return send_embed(
      event, 
      title: "#{EMOJIS['error']} Trade Formatting", 
      description: "Please specify both the character you are offering and the one you are requesting."
    )
  end

  # 3. Initialization: Normalize names and fetch collections
  my_char_search = offer_str.strip.downcase
  their_char_search = request_str.strip.downcase
  uid_a = event.user.id
  uid_b = target_user.id

  coll_a = DB.get_collection(uid_a)
  coll_b = DB.get_collection(uid_b)

  # 4. Verification: Check ownership for both parties (Case-Insensitive)
  my_char_real = coll_a.keys.find { |k| k.downcase == my_char_search }
  their_char_real = coll_b.keys.find { |k| k.downcase == their_char_search }

  if my_char_real.nil? || coll_a[my_char_real]['count'] < 1
    return send_embed(event, title: "#{EMOJIS['x_']} Missing Character", description: "You don't own **#{offer_str}** to trade!")
  end

  if their_char_real.nil? || coll_b[their_char_real]['count'] < 1
    return send_embed(event, title: "#{EMOJIS['x_']} Missing Character", description: "#{target_user.mention} doesn't own **#{request_str}**!")
  end

  # 5. State Persistence: Create a temporary trade record
  expire_time = Time.now + 120 # 2 Minute Window
  trade_id = "trade_#{expire_time.to_i}_#{rand(1000)}"

  ACTIVE_TRADES[trade_id] = {
    user_a: uid_a,
    user_b: uid_b,
    char_a: my_char_real,
    char_b: their_char_real,
    expires: expire_time
  }

  # 6. UI: Construct the Trade Proposal Embed
  embed = Discordrb::Webhooks::Embed.new(
    title: '🤝 Trade Offer!',
    description: "#{target_user.mention}, #{event.user.mention} wants to trade with you!\n\n" \
                 "They are offering **#{my_char_real}** in exchange for your **#{their_char_real}**.\n\n" \
                 "Do you accept? (Offer expires <t:#{expire_time.to_i}:R>)",
    color: NEON_COLORS.sample
  )

  # 7. Components: Attach Accept/Decline Buttons
  view = Discordrb::Components::View.new do |v|
    v.row do |r|
      r.button(custom_id: "#{trade_id}_accept", label: 'Accept', style: :success, emoji: '✅')
      r.button(custom_id: "#{trade_id}_decline", label: 'Decline', style: :danger, emoji: '❌')
    end
  end

  # 8. Dispatch: Send the message and handle Slash/Prefix differences
  if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
    event.respond(content: "Sent trade request!", ephemeral: true)
    msg = event.channel.send_message(nil, false, embed, nil, nil, nil, view)
  else
    msg = event.channel.send_message(nil, false, embed, nil, nil, event.message, view)
  end

  # 9. Cleanup Task: Automatically expire the trade after 120 seconds
  Thread.new do
    sleep 120
    if ACTIVE_TRADES.key?(trade_id)
      ACTIVE_TRADES.delete(trade_id)
      failed_embed = Discordrb::Webhooks::Embed.new(title: '⏳ Trade Expired', description: 'The trade offer timed out.', color: 0x808080)
      msg.edit(nil, failed_embed, Discordrb::Components::View.new) if msg
    end
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!trade)
# ------------------------------------------
bot.command(:trade, 
  description: 'Trade a character with someone (Usage: !trade @user <My Char> for <Their Char>)', 
  category: 'Gacha'
) do |event, *args|
  target_user = event.message.mentions.first
  
  # Parsing Logic: Remove the mention and split at the " for " keyword
  full_text = args.join(' ')
  clean_text = target_user ? full_text.gsub(/<@!?#{target_user.id}>/, '').strip : full_text
  parts = clean_text.split(/ for /i)
  
  if parts.size != 2
    send_embed(event, 
      title: "#{EMOJIS['error']} Trade Formatting", 
      description: "Please format it exactly like this:\n`#{PREFIX}trade @user Gawr Gura for Filian`"
    )
    next
  end

  execute_trade(event, target_user, parts[0], parts[1])
  nil
end

# ------------------------------------------
# TRIGGER: Slash Command (/trade)
# ------------------------------------------
bot.application_command(:trade) do |event|
  target_id = event.options['user']
  target = target_id ? event.bot.user(target_id.to_i) : nil
  execute_trade(event, target, event.options['offer'], event.options['request'])
end