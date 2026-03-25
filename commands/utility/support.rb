def execute_support(event)
  send_embed(event, title: "🛠️ Support Server", description: "Need assistance, have questions, or want to report a bug?\nJoin the Tsukiyo Server here:\n\n**https://discord.gg/tsukiyo**")
end

bot.command(:support, description: 'Get a link to the official support server', category: 'Utility') { |e| execute_support(e); nil }
bot.application_command(:support) { |e| execute_support(e) }