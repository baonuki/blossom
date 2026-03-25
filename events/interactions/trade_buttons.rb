# ==========================================
# EVENT: Player Trading Handlers
# DESCRIPTION: Listens for "Accept" or "Decline" button clicks 
# on active trade offers. Safely verifies inventory before swapping 
# to prevent duplication exploits.
# ==========================================

bot.button(custom_id: /^trade_\d+_\d+_(accept|decline)$/) do |event|
  # Extract the trade ID and the action (accept/decline) from the button
  match_data = event.custom_id.match(/^(trade_\d+_\d+)_(accept|decline)$/)
  trade_id = match_data[1]
  action   = match_data[2]

  # Validation 1: Check if the trade is still actively pending in Blossom's memory
  unless ACTIVE_TRADES.key?(trade_id)
    event.respond(content: '⚠️ *This trade has expired or already been processed!*', ephemeral: true)
    next
  end

  trade_data = ACTIVE_TRADES[trade_id]

  # Validation 2: Ensure ONLY the person receiving the offer can click the buttons!
  if event.user.id != trade_data[:user_b]
    event.respond(content: "❌ *Only the person receiving the trade offer can click this!*", ephemeral: true)
    next
  end

  # Delete it from memory immediately to prevent double-click glitches
  ACTIVE_TRADES.delete(trade_id)

  # Handle the Decline action instantly
  if action == 'decline'
    declined_embed = Discordrb::Webhooks::Embed.new(
      title: '🚫 Trade Declined', 
      description: "#{event.user.mention} rejected the trade offer.", 
      color: 0xFF0000
    )
    event.update_message(content: nil, embeds: [declined_embed], components: [])
    next
  end

  # --- ACCEPT LOGIC ---
  uid_a = trade_data[:user_a]
  uid_b = trade_data[:user_b]
  char_a = trade_data[:char_a]
  char_b = trade_data[:char_b]

  coll_a = DB.get_collection(uid_a)
  coll_b = DB.get_collection(uid_b)

  # Validation 3 (Exploit Protection): Check if either player no longer has the character 
  # (e.g., they sold it or traded it to someone else while this offer was pending)
  if coll_a[char_a].nil? || coll_a[char_a]['count'] < 1 || coll_b[char_b].nil? || coll_b[char_b]['count'] < 1
    error_embed = Discordrb::Webhooks::Embed.new(
      title: '❌ Trade Failed', 
      description: "Someone no longer has the character they offered! The trade has been automatically cancelled to prevent errors.", 
      color: 0xFF0000
    )
    event.update_message(content: nil, embeds: [error_embed], components: [])
    next
  end

  # Fetch the rarities before we delete them
  rarity_a = coll_a[char_a]['rarity']
  rarity_b = coll_b[char_b]['rarity']

  # Remove the characters from their original owners
  DB.remove_character(uid_a, char_a, 1)
  DB.remove_character(uid_b, char_b, 1)

  # Add the swapped characters to their new owners
  DB.add_character(uid_a, char_b, rarity_b, 1)
  DB.add_character(uid_b, char_a, rarity_a, 1)

  # Check and award the trading achievement for both players
  check_achievement(event.channel, uid_a, 'first_trade')
  check_achievement(event.channel, uid_b, 'first_trade')

  success_embed = Discordrb::Webhooks::Embed.new(
    title: '🎉 Trade Successful!',
    description: "The trade was a success!\n\n<@#{uid_a}> received **#{char_b}**.\n<@#{uid_b}> received **#{char_a}**.",
    color: 0x00FF00
  )
  
  # Replace the original pending message with the final receipt
  event.update_message(content: nil, embeds: [success_embed], components: [])
end