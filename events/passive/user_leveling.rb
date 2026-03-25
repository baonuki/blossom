# ==========================================
# EVENT: Individual User Leveling
# DESCRIPTION: Grants personal XP and Coins for chatting.
# Handles automatic role-grants for the main server and 
# routes level-up announcements.
# ==========================================

bot.message do |event|
  next if event.user.bot_account?
  next unless event.server 

  sid  = event.server.id
  uid  = event.user.id
  user = DB.get_user_xp(sid, uid)

  now = Time.now
  
  # Anti-Spam: Check if they are still on cooldown since their last message
  if user['last_xp_at'] && (now - user['last_xp_at']) < MESSAGE_COOLDOWN
    next
  end

  new_xp = user['xp'] + XP_PER_MESSAGE
  new_level = user['level']
  
  # Give them a little pocket change for chatting!
  DB.add_coins(uid, COINS_PER_MESSAGE)

  needed = new_level * 100
  
  # Check if they crossed the threshold for the next level
  if new_xp >= needed
    new_xp -= needed
    new_level += 1

    # --- CUSTOM SERVER ROLE REWARDS ---
    # This block only executes if the message was sent in your specific main server
    if sid == 1472509438010065070
      member = event.server.member(uid)
      
      if member
        level_roles = {
          100 => 1473524725127970817,
          75  => 1473524687593013259,
          50  => 1473524652629430530,
          40  => 1473524612032757964,
          30  => 1473524563299012731,
          20  => 1473524496773288071,
          10  => 1473524452875833465,
          5   => 1473524374970568967
        }

        earned_role_id = nil
        
        # Find the highest role they qualify for
        level_roles.each do |req_level, role_id|
          if new_level >= req_level
            earned_role_id = role_id
            break 
          end
        end

        # Remove the lower tier roles and grant the new one
        if earned_role_id
          roles_to_remove = level_roles.values - [earned_role_id]
          begin
            roles_to_remove.each do |role_id|
              member.remove_role(role_id) if member.role?(role_id)
            end
            member.add_role(earned_role_id) unless member.role?(earned_role_id)
          rescue StandardError => e
            puts "!!! [WARNING] Role hierarchy error: #{e.message}"
          end
        end
      end
    end

    # --- UNIFIED LEVEL UP MESSAGE LOGIC ---
    config = DB.get_levelup_config(sid)
    
    if config[:enabled]
      chan_id = config[:channel]

      # Check if the server configured a specific channel for level-up spam
      if chan_id && chan_id.to_i > 0
        target_channel = event.bot.channel(chan_id.to_i, event.server)
        
        if target_channel
          embed = Discordrb::Webhooks::Embed.new
          embed.title = "🎉 Level Up!"
          embed.description = "Congratulations #{event.user.mention}! You just advanced to **Level #{new_level}**!"
          embed.color = NEON_COLORS.sample
          embed.add_field(name: 'XP Remaining', value: "#{new_xp}/#{new_level * 100}", inline: true)
          embed.add_field(name: 'Coins', value: "#{DB.get_coins(uid)} #{EMOJIS['s_coin']}", inline: true)

          target_channel.send_message(nil, false, embed)
        else
          # Fallback: Send to the channel they just typed in if the custom channel is broken/deleted
          send_embed(
            event,
            title: "🎉 Level Up!",
            description: "Congratulations #{event.user.mention}! You just advanced to **Level #{new_level}**!",
            fields: [
              { name: 'XP Remaining', value: "#{new_xp}/#{new_level * 100}", inline: true },
              { name: 'Coins', value: "#{DB.get_coins(uid)} #{EMOJIS['s_coin']}", inline: true }
            ]
          )
        end
      else
        # Fallback: Send to the channel they just typed in if no custom channel is set
        send_embed(
          event,
          title: "🎉 Level Up!",
          description: "Congratulations #{event.user.mention}! You just advanced to **Level #{new_level}**!",
          fields: [
            { name: 'XP Remaining', value: "#{new_xp}/#{new_level * 100}", inline: true },
            { name: 'Coins', value: "#{DB.get_coins(uid)} #{EMOJIS['s_coin']}", inline: true }
          ]
        )
      end
    end
  end
  
  # Save the updated stats to the database!
  DB.update_user_xp(sid, uid, new_xp, new_level, now)
end