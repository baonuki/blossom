def execute_premium(event)
  desc = "Support Blossom's development and unlock amazing global perks!\n\n"
  desc += "**💎 Premium Bonuses:**\n"
  desc += "⏱️ **50% Faster Cooldowns** on `!work`, `!stream`, and `!post`\n"
  desc += "💰 **+10% Coin Boost** from all sources (daily, work, streams, bombs, collabs!)\n"
  desc += "🍀 **Boosted Gacha Odds** (Much higher chance to pull Rares, Legendaries, and Goddesses)\n"
  desc += "✨ **1% Secret Chance** to instantly pull a Shiny Ascended character from the portal!\n\n"
  desc += "To unlock these perks, join the Tsukiyo Server and boost it!:\n**https://discord.gg/tsukiyo**"
  send_embed(event, title: "💎 Blossom Premium", description: desc)
end

bot.command(:premium, description: 'View the benefits of Blossom Premium!', category: 'Utility') { |e| execute_premium(e); nil }
bot.application_command(:premium) { |e| execute_premium(e) }