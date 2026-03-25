def execute_prisma(event, action, target, amount)
  return if target.nil?
  
  uid = target.id
  amt = amount.to_i.abs 

  case action.downcase
  when 'add'
    DB.add_prisma(uid, amt)
    action_word = "Added **#{amt}** to"
  when 'remove'
    current = DB.get_prisma(uid)
    remove_amt = [amt, current].min 
    DB.add_prisma(uid, -remove_amt)
    action_word = "Removed **#{remove_amt}** from"
  when 'set'
    DB.set_prisma(uid, amt)
    action_word = "Set balance to **#{amt}** for"
  else
    error_msg = "❌ Invalid action! Use `add`, `remove`, or `set`."
    if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
      return event.respond(content: error_msg, ephemeral: true)
    else
      return event.respond(error_msg)
    end
  end

  new_bal = DB.get_prisma(uid)
  
  embed = Discordrb::Webhooks::Embed.new(
    title: "<:prisma:1486142162805723196> Prisma Updated",
    description: "#{action_word} #{target.mention}!\n\n**New Balance:** #{new_bal} <:prisma:1486142162805723196>",
    color: 0x9370DB 
  )

  if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
    event.respond(embeds: [embed])
  else
    event.channel.send_message(nil, false, embed)
  end
end

bot.command(:prisma, description: 'Manage user Prisma (Dev Only)', category: 'Developer') do |event, action, user_mention, amount|
  return unless event.user.id == DEV_ID
  
  target = event.message.mentions.first
  if target.nil? || action.nil? || amount.nil?
    event.respond("⚠️ *Usage: `#{PREFIX}prisma <add/remove/set> @user <amount>`*")
    return nil
  end
  
  execute_prisma(event, action, target, amount)
  nil
end

bot.application_command(:prisma) do |event|
  return event.respond(content: "❌ Developer only!", ephemeral: true) unless event.user.id == DEV_ID
  
  target_id = event.options['user']
  target = event.bot.user(target_id.to_i)
  
  execute_prisma(event, event.options['action'], target, event.options['amount'])
end