# ==========================================
# EVENT: Collab Request Accepted
# DESCRIPTION: Handles when a user clicks "Accept Collab".
# Distributes coins to both players and triggers achievements.
# ==========================================

$bot.button(custom_id: /^collab_/) do |event|
  collab_id = event.custom_id

  # Check if the collab is still active in our memory cache
  if ACTIVE_COLLABS.key?(collab_id)
    author_id = ACTIVE_COLLABS[collab_id]

    # Prevent the user from accepting their own request
    if event.user.id == author_id
      event.respond(content: "#{EMOJI_STRINGS['x_']} *Collabing with yourself? That's just... sad.*", ephemeral: true)
      next
    end

    # Remove it from the cache so nobody else can click it
    ACTIVE_COLLABS.delete(collab_id)
    
    # Award the coins to both users (award_coins handles the DB update)
    author_final = award_coins(event.bot, author_id, COLLAB_REWARD)
    user_final = award_coins(event.bot, event.user.id, COLLAB_REWARD)
    
    # Trigger achievements for both users
    check_achievement(event.channel, author_id, 'first_collab')
    check_achievement(event.channel, event.user.id, 'first_collab')

    # Friendship & challenge tracking
    begin
      DB.add_affinity(author_id, event.user.id, AFFINITY_COLLAB)
      track_challenge(author_id, 'collab_completed', 1)
      track_challenge(event.user.id, 'collab_completed', 1)
      track_challenge(author_id, 'coins_earned', COLLAB_REWARD)
      track_challenge(event.user.id, 'coins_earned', COLLAB_REWARD)
    rescue => e
      puts "[COLLAB TRACKING ERROR] #{e.message}"
    end

    author_user = event.bot.user(author_id)
    author_mention = author_user ? author_user.mention : "<@#{author_id}>"

    success_embed = Discordrb::Webhooks::Embed.new(
      title: "#{EMOJI_STRINGS['neonsparkle']} Collab Stream Started!",
      description: "#{event.user.mention} linked up with #{author_mention}! ACTUALLY POG.\n\nBoth of you earned **#{COLLAB_REWARD}** #{EMOJI_STRINGS['s_coin']} for the collab! *(Premium users got a sneaky 10% bonus~)*#{mom_remark(author_id, 'economy')}#{mom_remark(event.user.id, 'economy')}",
      color: 0x00FF00
    )

    # Replace the original request message with the success embed
    event.update_message(content: nil, embeds: [success_embed], components: [])
  else
    event.respond(content: "#{EMOJI_STRINGS['error']} *That collab is old news. Too late!*", ephemeral: true)
  end
end