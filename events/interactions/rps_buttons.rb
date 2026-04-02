# ==========================================
# EVENT: Rock Paper Scissors Handlers
# DESCRIPTION: Accept/Decline challenges and handle choice selection.
# ==========================================

# --- ACCEPT / DECLINE ---
$bot.button(custom_id: /^rps_\d+_\d+_\d+_(accept|decline)$/) do |event|
  match = event.custom_id.match(/^(rps_\d+_\d+_\d+)_(accept|decline)$/)
  rps_id = match[1]
  action = match[2]

  unless ACTIVE_RPS.key?(rps_id)
    event.respond(content: "#{EMOJI_STRINGS['error']} *That challenge is old news.*", ephemeral: true)
    next
  end

  game = ACTIVE_RPS[rps_id]

  # Only the opponent can accept/decline
  if event.user.id != game[:opponent]
    event.respond(content: "#{EMOJI_STRINGS['x_']} *Not your fight, back off.*", ephemeral: true)
    next
  end

  if action == 'decline'
    ACTIVE_RPS.delete(rps_id)
    embed = Discordrb::Webhooks::Embed.new(title: '🚫 Challenge Declined', description: "#{event.user.mention} chickened out. No contest.", color: 0xFF0000)
    event.update_message(content: nil, embeds: [embed], components: [])
    next
  end

  # Verify both players still have the coins
  if DB.get_coins(game[:challenger]) < game[:bet] || DB.get_coins(game[:opponent]) < game[:bet]
    ACTIVE_RPS.delete(rps_id)
    embed = Discordrb::Webhooks::Embed.new(title: "#{EMOJI_STRINGS['x_']} RPS Cancelled", description: "Someone doesn't have enough coins anymore. Deal's off.", color: 0xFF0000)
    event.update_message(content: nil, embeds: [embed], components: [])
    next
  end

  # Show choice buttons
  game[:state] = :choosing
  embed = Discordrb::Webhooks::Embed.new(
    title: '✂️ THROW YOUR PICK!',
    description: "Both players: click your choice below! First to pick waits for the other.\n\n**Bet:** #{game[:bet]} #{EMOJI_STRINGS['s_coin']}",
    color: NEON_COLORS.sample
  )

  view = Discordrb::Components::View.new do |v|
    v.row do |r|
      r.button(custom_id: "#{rps_id}_rock", label: 'Rock', style: :primary, emoji: '🪨')
      r.button(custom_id: "#{rps_id}_paper", label: 'Paper', style: :primary, emoji: '📄')
      r.button(custom_id: "#{rps_id}_scissors", label: 'Scissors', style: :primary, emoji: '✂️')
    end
  end

  event.update_message(content: nil, embeds: [embed], components: view)
end

# --- CHOICE SELECTION ---
$bot.button(custom_id: /^rps_\d+_\d+_\d+_(rock|paper|scissors)$/) do |event|
  match = event.custom_id.match(/^(rps_\d+_\d+_\d+)_(rock|paper|scissors)$/)
  rps_id = match[1]
  choice = match[2]

  unless ACTIVE_RPS.key?(rps_id)
    event.respond(content: "#{EMOJI_STRINGS['error']} *Game's over.*", ephemeral: true)
    next
  end

  game = ACTIVE_RPS[rps_id]
  uid = event.user.id

  # Only the two players can pick
  unless [game[:challenger], game[:opponent]].include?(uid)
    event.respond(content: "#{EMOJI_STRINGS['x_']} *This isn't your game.*", ephemeral: true)
    next
  end

  # Prevent changing choice
  if game[:choices][uid]
    event.respond(content: "#{EMOJI_STRINGS['info']} *You already picked. No take-backsies.*", ephemeral: true)
    next
  end

  game[:choices][uid] = choice
  event.respond(content: "You picked **#{RPS_EMOJIS[choice]} #{choice.capitalize}**! Waiting on your opponent...", ephemeral: true)

  # Check if both have chosen
  next unless game[:choices].size == 2

  ACTIVE_RPS.delete(rps_id)

  c_choice = game[:choices][game[:challenger]]
  o_choice = game[:choices][game[:opponent]]
  bet = game[:bet]

  # Determine winner
  if c_choice == o_choice
    # Draw — no money changes hands
    result_title = '🤝 DRAW!'
    result_desc = "Both threw **#{RPS_EMOJIS[c_choice]} #{c_choice.capitalize}**. Nobody wins, nobody loses.\n\nCoins returned. Go again?"
    result_color = 0xFFFF00
  elsif RPS_WINS[c_choice] == o_choice
    # Challenger wins
    DB.add_coins(game[:challenger], bet)
    DB.add_coins(game[:opponent], -bet)
    DB.increment_arcade_wins(game[:challenger])
    DB.increment_arcade_losses(game[:opponent])
    result_title = "#{RPS_EMOJIS[c_choice]} WINNER!"
    result_desc = "<@#{game[:challenger]}> threw **#{RPS_EMOJIS[c_choice]} #{c_choice.capitalize}** vs <@#{game[:opponent]}>'s **#{RPS_EMOJIS[o_choice]} #{o_choice.capitalize}**!\n\n" \
                  "<@#{game[:challenger]}> wins **#{bet}** #{EMOJI_STRINGS['s_coin']}!"
    result_color = 0x00FF00
  else
    # Opponent wins
    DB.add_coins(game[:opponent], bet)
    DB.add_coins(game[:challenger], -bet)
    DB.increment_arcade_wins(game[:opponent])
    DB.increment_arcade_losses(game[:challenger])
    result_title = "#{RPS_EMOJIS[o_choice]} WINNER!"
    result_desc = "<@#{game[:opponent]}> threw **#{RPS_EMOJIS[o_choice]} #{o_choice.capitalize}** vs <@#{game[:challenger]}>'s **#{RPS_EMOJIS[c_choice]} #{c_choice.capitalize}**!\n\n" \
                  "<@#{game[:opponent]}> wins **#{bet}** #{EMOJI_STRINGS['s_coin']}!"
    result_color = 0x00FF00
  end

  embed = Discordrb::Webhooks::Embed.new(title: result_title, description: result_desc, color: result_color)
  event.update_message(content: nil, embeds: [embed], components: [])
end
