# ==========================================
# COMMAND: devhelp
# DESCRIPTION: Lists all developer-only commands for the bot owner/developer.
# CATEGORY: Developer
# ==========================================

def execute_devhelp(event)
  return unless DEV_IDS.include?(event.user.id)

  cmd_list = [
    "`#{PREFIX}dcoin <add/remove/set> @user <amount>` — Manage user coins",
    "`#{PREFIX}dpremium <give/remove> @user` — Manage lifetime premium",
    "`#{PREFIX}prisma <add/remove/set> @user <amount>` — Manage user Prisma",
    "`#{PREFIX}blacklist @user` — Toggle user blacklist",
    "`#{PREFIX}card <add/remove/giveascended/takeascended> @user <name>` — Manage user cards",
    "`#{PREFIX}dbomb` — Plant a manual bomb",
    "`#{PREFIX}syncachievements` — Retroactively grant missing achievements",
    "`#{PREFIX}dticketsetup #channel` — Post support ticket panel",
    "`#{PREFIX}dapplysetup #channel` — Post mod application panel",
    "`#{PREFIX}devhelp` — This list"
  ].join("\n")

  send_cv2(event, [{ type: 17, accent_color: NEON_COLORS.sample, components: [
    { type: 10, content: "## #{EMOJI_STRINGS['developer']} Developer Commands" },
    { type: 14, spacing: 1 },
    { type: 10, content: "#{cmd_list}#{mom_remark(event.user.id, 'dev')}" }
  ]}])
end

$bot.command(:devhelp, aliases: [:dh], description: 'List all developer commands (Dev Only)') do |event|
  execute_devhelp(event)
  nil
end
