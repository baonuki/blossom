# ==========================================
# EVENT: Player Trading Handlers
# DESCRIPTION: Listens for "Accept" or "Decline" button clicks 
# on active trade offers. Safely verifies inventory before swapping 
# to prevent duplication exploits.
# ==========================================

$bot.button(custom_id: /^trade_\d+_\d+_(accept|decline)$/) do |event|
  # Extract the trade ID and the action (accept/decline) from the button
  match_data = event.custom_id.match(/^(trade_\d+_\d+)_(accept|decline)$/)
  trade_id = match_data[1]
  action   = match_data[2]

  # Validation 1: Check if the trade is still actively pending in Blossom's memory
  unless ACTIVE_TRADES.key?(trade_id)
    event.respond(content: "#{EMOJI_STRINGS['error']} *That trade is dead. Gone. Expired. Move on.*", ephemeral: true)
    next
  end

  trade_data = ACTIVE_TRADES[trade_id]

  # Validation 2: Ensure ONLY the person receiving the offer can click the buttons!
  if event.user.id != trade_data[:user_b]
    event.respond(content: "#{EMOJI_STRINGS['x_']} *Hands off! This trade isn't for you.*", ephemeral: true)
    next
  end

  # Delete it from memory immediately to prevent double-click glitches
  ACTIVE_TRADES.delete(trade_id)

  # Handle the Decline action instantly
  if action == 'decline'
    declined_embed = Discordrb::Webhooks::Embed.new(
      title: '🚫 Trade Declined',
      description: "#{event.user.mention} said nah. Tough break.",
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
      title: "#{EMOJI_STRINGS['x_']} Trade Failed",
      description: "Someone already got rid of their character. Caught in 4K. Trade cancelled.",
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

  # Check and award the trading achievements for both players
  check_achievement(event.channel, uid_a, 'first_trade')
  check_achievement(event.channel, uid_b, 'first_trade')

  trades_a = DB.increment_trade_count(uid_a)
  trades_b = DB.increment_trade_count(uid_b)
  check_achievement(event.channel, uid_a, 'trade_10') if trades_a >= 10
  check_achievement(event.channel, uid_b, 'trade_10') if trades_b >= 10

  # Friendship & challenge tracking
  begin
    DB.add_affinity(uid_a, uid_b, AFFINITY_TRADE)
    track_challenge(uid_a, 'trades_completed', 1)
    track_challenge(uid_b, 'trades_completed', 1)
  rescue => e
    puts "[TRADE TRACKING ERROR] #{e.message}"
  end

  # Easter eggs
  envvy_comment = ""
  envvy_comment = "\n\n*...you're trading away my MOM'S PAST LIFE?? I'm watching you. She better be going to a good home.*" if char_a == 'Envvy' || char_b == 'Envvy'
  envvy_comment = "\n\n*You're trading baonuki?! That's my mama's current VTuber persona. This better be the safest trade in history.*" if char_a.downcase == 'baonuki' || char_b.downcase == 'baonuki'
  envvy_comment = "\n\n*Hold up— I'M being traded?? Like a Pokémon card at recess?? This is so dehumanizing. ...Debot-izing? Whatever. I hope whoever got me knows they're holding ROYALTY.*" if char_a == 'Blossom' || char_b == 'Blossom'

  success_embed = Discordrb::Webhooks::Embed.new(
    title: "#{EMOJI_STRINGS['surprise']} Trade Complete!",
    description: "Not bad, chat. Not bad at all.\n\n<@#{uid_a}> snagged **#{char_b}**.\n<@#{uid_b}> snagged **#{char_a}**.#{envvy_comment}#{mom_remark(uid_a, 'gacha')}#{mom_remark(uid_b, 'gacha')}",
    color: 0x00FF00
  )
  
  # Replace the original pending message with the final receipt
  event.update_message(content: nil, embeds: [success_embed], components: [])
end