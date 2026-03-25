# ==========================================
# COMMAND: devhelp
# DESCRIPTION: Lists all developer-only commands for the bot owner/developer.
# CATEGORY: Developer
# ==========================================

def execute_devhelp(event)
  return unless event.user.id == DEV_ID

  dev_commands = [
    'addcoins',
    'removecoins',
    'setcoins',
    'prisma',
    'blacklist',
    'card',
    'givepremium',
    'removepremium',
    'syncachievements',
    'devhelp'
  ]

  descs = {
    'addcoins' => 'Add or remove coins from a user',
    'removecoins' => 'Remove coins from a user',
    'setcoins' => 'Set a user\'s balance to an exact amount',
    'prisma' => 'Manage user Prisma balance',
    'blacklist' => 'Toggle blacklist for a user',
    'card' => 'Manage user cards',
    'givepremium' => 'Give a user lifetime premium',
    'removepremium' => 'Remove lifetime premium from a user',
    'syncachievements' => 'Retroactively grant achievements to everyone',
    'devhelp' => 'Show this list of developer commands'
  }

  msg = "**Developer Commands:**\n"
  dev_commands.each do |cmd|
    msg += "`#{PREFIX}#{cmd}` - #{descs[cmd]}\n"
  end

  event.send_message(msg)
end

$bot.command(:devhelp, description: 'List all developer commands (Dev Only)') do |event|
  execute_devhelp(event)
  nil
end
