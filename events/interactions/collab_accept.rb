# ==========================================
# EVENT: Collab Request Accepted
# DESCRIPTION: Handles when a user clicks "Accept Collab".
# Distributes coins to both players and triggers achievements.
# ==========================================

bot.button(custom_id: /^collab_/) do |event|
  collab_id = event.custom_id

  # Check if the collab is still active in our memory cache
  if ACTIVE_COLLABS.key?(collab_id)
    author_id = ACTIVE_COLLABS[collab_id]

    # Prevent the user from accepting their own request
    if event.user.id == author_id
      event.respond(content: "❌ *You can't accept your own collab request!*", ephemeral: true)
      next
    end

    # Remove it from the cache so nobody else can click it
    ACTIVE_COLLABS.delete(collab_id)
    
    # Award the coins to both users (award_coins handles the DB update)
    author_final = award_coins(event.bot, author_id, COLLAB_REWARD)
    user_final = award_coins(event.bot, event.user.id, COLLAB_REWARD)
    
    # Trigger achievements for both users
    check_achievement(event.channel, author_id, 'first_collab') # Fixed from host_id
    check_achievement(event.channel, event.user.id, 'first_collab')

    author_user = event.bot.user(author_id)
    author_mention = author_user ? author_user.mention : "<@#{author_id}>"

    success_embed = Discordrb::Webhooks::Embed.new(
      title: "#{EMOJIS['neonsparkle']} Collab Stream Started!",
      description: "#{event.user.mention} accepted the collab with #{author_mention}!\n\nBoth streamers got a baseline of **#{COLLAB_REWARD}** #{EMOJIS['s_coin']} for an awesome stream! *(Subscribers received a 10% bonus!)*",
      color: 0x00FF00
    )

    # Replace the original request message with the success embed
    event.update_message(content: nil, embeds: [success_embed], components: [])
  else
    event.respond(content: '⚠️ *This collab request has already expired or been accepted!*', ephemeral: true)
  end
end