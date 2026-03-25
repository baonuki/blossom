# ==========================================
# COMMAND: shop
# DESCRIPTION: Opens the interactive shop to browse character prices and tech upgrades.
# CATEGORY: Economy / Gacha
# ==========================================

# ------------------------------------------
# LOGIC: Shop Display Execution
# ------------------------------------------
def execute_shop(event)
  # 1. Initialization: Call the UI helper to generate the Shop Embed and Components
  # This helper typically pulls from SHOP_PRICES and BLACK_MARKET_ITEMS.
  embed, view = build_shop_home(event.user.id)
  
  # 2. Messaging: Handle execution context (Slash vs. Prefix)
  if event.is_a?(Discordrb::Events::ApplicationCommandEvent)
    # Slash Command: Standard interaction response
    event.respond(embeds: [embed], components: view)
  else
    # Prefix Command: Send as a reply to the user's message
    # { replied_user: false } keeps the chat clean by not pinging the user again.
    event.channel.send_message(
      nil,            # content
      false,          # tts
      embed,          # embed object
      nil,            # attachments
      { replied_user: false }, 
      event.message,  # original message for the reply reference
      view            # components (buttons/select menus)
    )
  end
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!shop)
# ------------------------------------------
bot.command(:shop, 
  description: 'View the character shop and direct-buy prices!', 
  category: 'Economy'
) do |event|
  execute_shop(event)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/shop)
# ------------------------------------------
bot.application_command(:shop) do |event|
  execute_shop(event)
end