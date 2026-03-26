# ==========================================
# COMMAND: givecoins
# DESCRIPTION: Transfer coins from your balance to another user.
# CATEGORY: Economy
# ==========================================

# ------------------------------------------
# LOGIC: Give Coins Execution
# ------------------------------------------
def execute_givecoins(event, target, amount_str)
  # 1. Initialization: Get the sender's ID and convert input to integer
  uid = event.user.id
  amount = amount_str.to_i

  # 2. Validation: Prevent self-gifting or gifting to nobody
  if target.nil? || target.id == uid
    components = [
      {
        type: 17,
        accent_color: 0xFF0000,
        components: [
          { type: 10, content: "## #{EMOJI_STRINGS['error']} Invalid Target" },
          { type: 14, spacing: 1 },
          { type: 10, content: "You gotta actually tag someone, chat. I can't read minds." }
        ]
      }
    ]
    return send_cv2(event, components)
  end

  # 3. Validation: Ensure the amount is a positive number
  if amount <= 0
    components = [
      {
        type: 17,
        accent_color: 0xFF0000,
        components: [
          { type: 10, content: "## #{EMOJI_STRINGS['error']} Invalid Amount" },
          { type: 14, spacing: 1 },
          { type: 10, content: "You can't give zero coins, that's just embarrassing. At least 1 #{EMOJI_STRINGS['s_coin']}." }
        ]
      }
    ]
    return send_cv2(event, components)
  end

  # 4. Validation: Check if the sender has enough funds in the Database
  if DB.get_coins(uid) < amount
    components = [
      {
        type: 17,
        accent_color: 0xFF0000,
        components: [
          { type: 10, content: "## #{EMOJI_STRINGS['nervous']} Insufficient Funds" },
          { type: 14, spacing: 1 },
          { type: 10, content: "You're broke, bestie. You don't have **#{amount}** #{EMOJI_STRINGS['s_coin']} to throw around." }
        ]
      }
    ]
    return send_cv2(event, components)
  end

  # 5. Transaction: Deduct from sender and add to recipient
  # Note: Since these are two separate calls, ensure your DB module handles errors gracefully.
  DB.add_coins(uid, -amount)
  DB.add_coins(target.id, amount)

  # 6. Achievements
  check_achievement(event.channel, uid, 'first_givecoins')

  # 7. UI: Confirm the successful transfer via CV2
  components = [
    {
      type: 17,
      accent_color: 0x00FF00,
      components: [
        { type: 10, content: "## #{EMOJI_STRINGS['coins']} Coins Transferred!" },
        { type: 14, spacing: 1 },
        { type: 10, content: "#{event.user.mention} just dropped **#{amount}** #{EMOJI_STRINGS['s_coin']} on #{target.mention}! Big spender energy.\n\nYour balance: **#{DB.get_coins(uid)}** #{EMOJI_STRINGS['s_coin']}" }
      ]
    }
  ]
  send_cv2(event, components)
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!givecoins)
# ------------------------------------------
$bot.command(:givecoins, 
  description: 'Give your coins to another user', 
  category: 'Economy'
) do |event, mention, amount|
  # Capture the first user mention in the message
  execute_givecoins(event, event.message.mentions.first, amount)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/givecoins)
# ------------------------------------------
$bot.application_command(:givecoins) do |event|
  # Fetch target user from options and pass Slash data to the executor
  target = event.bot.user(event.options['user'].to_i)
  execute_givecoins(event, target, event.options['amount'])
end