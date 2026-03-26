# ==========================================
# SYSTEM: Slash Command Registry
# DESCRIPTION: Tells Discord's servers what commands
# Blossom has available and what options they require.
# ==========================================

puts "🌸 Registering slash commands to Discord API..."

=begin

# =========================
# CORE & UTILITY
# =========================

bot.register_application_command(:ping, 'Check bot latency')
bot.register_application_command(:help, 'Shows a paginated list of all available commands')
bot.register_application_command(:about, 'Learn more about Blossom and her creator!')
bot.register_application_command(:support, 'Get a link to the official support server')
bot.register_application_command(:premium, 'View the benefits of Blossom Premium!')
bot.register_application_command(:serverinfo, 'Displays information about the current server')
bot.register_application_command(:suggest, 'Send a suggestion directly to the developer!') do |cmd|
  cmd.string('suggestion', 'What would you like to see added or changed?', required: true)
end

# =========================
# FUN & SOCIAL
# =========================

bot.register_application_command(:kettle, 'Pings a specific user with a yay emoji')
bot.register_application_command(:interactions, 'Show your hug/slap stats')
bot.register_application_command(:hug, 'Send a hug with a random GIF') do |cmd|
  cmd.user('user', 'The person you want to hug', required: true)
end
bot.register_application_command(:slap, 'Send a playful slap with a random GIF') do |cmd|
  cmd.user('user', 'The person you want to slap', required: true)
end

# =========================
# ECONOMY & ARCADE
# =========================

bot.register_application_command(:balance, "Show a user's coin balance, gacha stats, and inventory") do |cmd|
  cmd.user('user', 'The user to check (optional)', required: false)
end
bot.register_application_command(:daily, 'Claim your daily coin reward')
bot.register_application_command(:work, 'Work for some coins')
bot.register_application_command(:stream, 'Go live and earn some coins!')
bot.register_application_command(:post, 'Post on social media for some quick coins!')
bot.register_application_command(:collab, 'Ask the server to do a collab stream! (30m cooldown)')
bot.register_application_command(:cooldowns, 'Check your active timers for economy commands')
bot.register_application_command(:givecoins, 'Give your coins to another user') do |cmd|
  cmd.user('user', 'Who?', required: true)
  cmd.integer('amount', 'How much?', required: true)
end
bot.register_application_command(:remindme, 'Toggle your daily reward reminder ping')
bot.register_application_command(:event, 'Open the Limited Time Event Hub!')
bot.register_application_command(:leaderboard, 'Show top users by level for this server')
bot.register_application_command(:level, 'Show a user\'s level and XP for this server') do |cmd|
  cmd.user('user', 'The user to check (optional)', required: false)
end

# Casino & Betting
bot.register_application_command(:coinflip, 'Bet your stream revenue on a coinflip!') do |cmd|
  cmd.integer('amount', 'How many coins to bet', required: true)
  cmd.string('choice', 'Heads or Tails', required: true, choices: { 'Heads' => 'heads', 'Tails' => 'tails' })
end
bot.register_application_command(:slots, 'Spin the neon slots!') do |cmd|
  cmd.integer('amount', 'How many coins to bet', required: true)
end
bot.register_application_command(:roulette, 'Bet on the roulette wheel!') do |cmd|
  cmd.integer('amount', 'How many coins to bet', required: true)
  cmd.string('bet', 'red, black, even, odd, or 0-36', required: true)
end
bot.register_application_command(:scratch, 'Buy a neon scratch-off ticket for 500 coins!')
bot.register_application_command(:dice, 'Roll 2d6! Bet on high (8-12), low (2-6), or 7.') do |cmd|
  cmd.integer('amount', 'How many coins to bet', required: true)
  cmd.string('bet', 'high, low, or 7', required: true, choices: { 'High (8-12)' => 'high', 'Low (2-6)' => 'low', 'Seven (7)' => '7' })
end
bot.register_application_command(:cups, 'Guess which cup hides the coin (1, 2, or 3)!') do |cmd|
  cmd.integer('amount', 'How many coins to bet', required: true)
  cmd.integer('guess', 'Cup 1, 2, or 3', required: true, choices: { 'Cup 1' => 1, 'Cup 2' => 2, 'Cup 3' => 3 })
end
bot.register_application_command(:lottery, 'Enter the hourly global lottery!') do |cmd|
  cmd.integer('tickets', 'How many 1000-coin tickets to buy', required: false)
end
bot.register_application_command(:lotteryinfo, 'View current lottery stats and your tickets')

# =========================
# GACHA & INVENTORY
# =========================

bot.register_application_command(:summon, 'Roll the gacha!')
bot.register_application_command(:collection, 'View all the characters you own') do |cmd|
  cmd.user('user', 'The user whose collection you want to view', required: false)
end
bot.register_application_command(:banner, 'Check which characters are in the gacha pool this week!')
bot.register_application_command(:shop, 'View the character shop and direct-buy prices!')
bot.register_application_command(:buy, 'Buy a character or tech upgrade') do |cmd|
  cmd.string('item', 'Name of the character or item to buy', required: true)
end
bot.register_application_command(:view, 'Look at a specific character you own') do |cmd|
  cmd.string('character', 'Name of the character', required: true)
end
bot.register_application_command(:ascend, 'Fuse 5 duplicate characters into a Shiny Ascended version!') do |cmd|
  cmd.string('character', 'Name of the character', required: true)
end
bot.register_application_command(:trade, 'Trade a character with someone') do |cmd|
  cmd.user('user', 'The user you want to trade with', required: true)
  cmd.string('offer', 'The character you are giving', required: true)
  cmd.string('request', 'The character you want from them', required: true)
end
bot.register_application_command(:givecard, 'Give a VTuber card to another user') do |cmd|
  cmd.user('user', 'The user you want to give the card to', required: true)
  cmd.string('character', 'The name of the character', required: true)
end
bot.register_application_command(:sell, 'Sell your duplicate VTuber cards for coins') do |cmd|
  cmd.string('filter', 'How do you want to sell?', required: true, choices: {
    'All Dupes (Keep 1 of each)' => 'all',
    'Over 5 (Save copies for ascending)' => 'over5',
    'Specific Rarity' => 'rarity'
  })
  cmd.string('rarity', 'If filtering by rarity, which one?', required: false, choices: {
    'Common' => 'common', 'Rare' => 'rare', 'Legendary' => 'legendary', 'Goddess' => 'goddess'
  })
end

# =========================
# ADMINISTRATION
# =========================

bot.register_application_command(:giveaway, 'Start a giveaway (Admin only)') do |cmd|
  cmd.channel('channel', 'The channel to host the giveaway in', required: true)
  cmd.string('time', 'Duration (e.g., 10m, 2h, 1d)', required: true)
  cmd.string('prize', 'What are you giving away?', required: true)
end
bot.register_application_command(:bomb, 'Enable or disable bomb drops (Admin Only)') do |cmd|
  cmd.string('action', 'Enable or disable', required: true, choices: { 'Enable' => 'enable', 'Disable' => 'disable' })
  cmd.channel('channel', 'The channel to drop bombs in (required for enable)', required: false)
end
bot.register_application_command(:setxp, 'Manage user XP/Level — add, remove, set, or level (Admin Only)') do |cmd|
  cmd.string('action', 'What to do', required: true, choices: { 'Add XP' => 'add', 'Remove XP' => 'remove', 'Set XP' => 'set', 'Set Level' => 'level' })
  cmd.user('user', 'The user to modify', required: true)
  cmd.integer('amount', 'Amount of XP or target level', required: true)
end
bot.register_application_command(:levelup, 'Configure where level-up messages go (Admin Only)') do |cmd|
  cmd.string('state', 'Turn messages on or off', required: false, choices: { 'On' => 'on', 'Off' => 'off' })
  cmd.channel('channel', 'Pick a specific channel for the messages', required: false)
end
bot.register_application_command(:purge, 'Deletes a number of messages (Admin only)') do |cmd|
  cmd.integer('amount', 'Number of messages to delete (1-100)', required: true)
end
bot.register_application_command(:kick, 'Kicks a user from the server (Admin only)') do |cmd|
  cmd.user('user', 'The user to kick', required: true)
  cmd.string('reason', 'Why are they being kicked?', required: false)
end
bot.register_application_command(:ban, 'Bans a user from the server (Admin only)') do |cmd|
  cmd.user('user', 'The user to ban', required: true)
  cmd.string('reason', 'Why are they being banned?', required: false)
end
bot.register_application_command(:timeout, 'Timeouts a user for X minutes (Admin only)') do |cmd|
  cmd.user('user', 'The user to timeout', required: true)
  cmd.integer('minutes', 'How many minutes?', required: true)
  cmd.string('reason', 'Why are they being timed out?', required: false)
end
bot.register_application_command(:logsetup, 'Set the channel for server logs (Admin Only)') do |cmd|
  cmd.channel('channel', 'The channel to send logs to', required: true)
end
bot.register_application_command(:logtoggle, 'Toggle logging for specific events (Admin Only)') do |cmd|
  cmd.string('type', 'What to toggle', required: true, choices: { 'Message Deletes' => 'deletes', 'Message Edits' => 'edits', 'Mod Actions' => 'mod' })
end
bot.register_application_command(:verifysetup, 'Set up a verification panel (Admin Only)') do |cmd|
  cmd.channel('channel', 'The channel to send the panel to', required: true)
  cmd.role('role', 'The role to give verified members', required: true)
end

# =========================
bot.register_application_command(:addcoins, 'Add or remove coins from a user (Dev Only)') do |cmd|
  cmd.user('user', 'The user to modify', required: true)
  cmd.integer('amount', 'Amount of coins (use negative to remove)', required: true)
end
bot.register_application_command(:removecoins, 'Remove coins from a user (Dev Only)') do |cmd|
  cmd.user('user', 'Who?', required: true)
  cmd.integer('amount', 'How much?', required: true)
end
bot.register_application_command(:setcoins, 'Set a user\'s balance to an exact amount (Dev Only)') do |cmd|
  cmd.user('user', 'The user to modify', required: true)
  cmd.integer('amount', 'The new balance', required: true)
end
bot.register_application_command(:prisma, 'Manage user Prisma balance (Dev Only)') do |cmd|
  cmd.string('action', 'Add, remove, or set', required: true, choices: { 'Add' => 'add', 'Remove' => 'remove', 'Set' => 'set' })
  cmd.user('user', 'Target user', required: true)
  cmd.integer('amount', 'Amount of Prisma', required: true)
end
bot.register_application_command(:blacklist, 'Toggle blacklist for a user (Dev Only)') do |cmd|
  cmd.user('user', 'The user to blacklist or forgive', required: true)
end
bot.register_application_command(:card, 'Manage user cards (Dev Only)') do |cmd|
  cmd.string('action', 'add / remove / giveascended / takeascended', required: true)
  cmd.user('user', 'The user to modify', required: true)
  cmd.string('character', 'The character name', required: true)
end
bot.register_application_command(:givepremium, 'Give a user lifetime premium (Dev only)') do |cmd|
  cmd.user('user', 'The user to upgrade', required: true)
end
bot.register_application_command(:removepremium, 'Remove lifetime premium (Dev only)') do |cmd|
  cmd.user('user', 'The user to downgrade', required: true)
end
bot.register_application_command(:backup, 'Manually trigger a database backup (Dev Only)')
bot.register_application_command(:syncachievements, 'Retroactively grant achievements to everyone! (Dev Only)')




# --- Register new/updated slash commands ---
$bot.register_application_command(:bomb, 'Enable or disable bomb drops (Admin Only)') do |cmd|
  cmd.string('action', 'Enable or disable', required: true, choices: { 'Enable' => 'enable', 'Disable' => 'disable' })
  cmd.channel('channel', 'The channel to drop bombs in (required for enable)', required: false)
end

$bot.register_application_command(:setxp, 'Manage user XP/Level — add, remove, set, or level (Admin Only)') do |cmd|
  cmd.string('action', 'What to do', required: true, choices: { 'Add XP' => 'add', 'Remove XP' => 'remove', 'Set XP' => 'set', 'Set Level' => 'level' })
  cmd.user('user', 'The user to modify', required: true)
  cmd.integer('amount', 'Amount of XP or target level', required: true)
end

=end

puts "✅ All slash commands registered!"
