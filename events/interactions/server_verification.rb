# ==========================================
# EVENT: Captcha / Server Verification
# DESCRIPTION: Handles the visual emoji captcha system 
# that grants the verified role upon success.
# ==========================================

bot.button(custom_id: 'verify_start') do |event|
  role_id = DB.get_verify_role(event.server.id)
  
  if role_id.nil?
    event.respond(content: "⚠️ Verification hasn't been fully configured yet!", ephemeral: true)
    next
  end

  emojis = ['🍎', '🍉', '🍇', '🍓', '🍒', '🍑', '🍍', '🥝', '🍅', '🥥', '🍔', '🍕', '🍩', '🍦', '🍪', '🍯', '🍩', '🥞', '🥐']
  selected_emojis = emojis.sample(9).shuffle
  correct_emoji = selected_emojis.sample

  view = Discordrb::Components::View.new
  selected_emojis.each_slice(3) do |row_emojis|
    view.row do |r|
      row_emojis.each do |emoji|
        if emoji == correct_emoji
          r.button(custom_id: "verify_pass_#{role_id}", style: :secondary, emoji: emoji)
        else
          r.button(custom_id: "verify_fail_#{rand(10000)}", style: :secondary, emoji: emoji)
        end
      end
    end
  end

  event.respond(content: "🤖 **Human Check!**\nTo gain access to the server, please click on the **#{correct_emoji}** from the buttons below!", ephemeral: true, components: view)
end

bot.button(custom_id: /^verify_pass_/) do |event|
  role_id = event.custom_id.split('_').last.to_i
  role = event.server.role(role_id)
  
  if role
    begin
      event.user.add_role(role)
      event.update_message(content: "✅ **Verification successful!** Welcome to the server! 🌸", components: [])
    rescue => e
      event.update_message(content: "❌ I don't have permission to give you the role! Please tell an Admin to move my bot role higher up in the settings.", components: [])
    end
  else
    event.update_message(content: "❌ The verification role no longer exists! An Admin needs to run `#{PREFIX}verifysetup` again.", components: [])
  end
end

bot.button(custom_id: /^verify_fail_/) do |event|
  event.update_message(content: "❌ **Incorrect!** That was the wrong emoji. Please dismiss this message and click the 'Start Verification' button to try again.", components: [])
end