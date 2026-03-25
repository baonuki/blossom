# ==========================================
# COMMAND: premium
# DESCRIPTION: Showcases the benefits of supporting Blossom via server boosting.
# CATEGORY: Utility
# ==========================================

# ------------------------------------------
# LOGIC: Premium Perks Display Execution
# ------------------------------------------
def execute_premium(event)
  # 1. UI: Construct the perks description list
  # We use bolding and emojis to make the high-value perks pop.
  desc = "Support Blossom's development and unlock amazing global perks!\n\n"
  
  desc += "**💎 Premium Bonuses:**\n"
  desc += "⏱️ **50% Faster Cooldowns** on `!work`, `!stream`, and `!post`\n"
  desc += "💰 **+10% Coin Boost** from all sources (daily, work, streams, bombs, collabs!)\n"
  desc += "🍀 **Boosted Gacha Odds** (Much higher chance to pull Rares, Legendaries, and Goddesses)\n"
  desc += "✨ **1% Secret Chance** to instantly pull a Shiny Ascended character from the portal!\n\n"
  
  # 2. CTA: Direct the user to the support server
  desc += "To unlock these perks, join the Tsukiyo Server and boost it!:\n**https://discord.gg/tsukiyo**"
  
  # 3. Messaging: Send the finalized Premium Info Embed
  send_embed(
    event, 
    title: "💎 Blossom Premium", 
    description: desc,
    color: 0x00FFFF # Cyan/Diamond color
  )
end

# ------------------------------------------
# TRIGGER: Prefix Command (b!premium)
# ------------------------------------------
bot.command(:premium, 
  description: 'View the benefits of Blossom Premium!', 
  category: 'Utility'
) do |event|
  execute_premium(event)
  nil # Suppress default return
end

# ------------------------------------------
# TRIGGER: Slash Command (/premium)
# ------------------------------------------
bot.application_command(:premium) do |event|
  execute_premium(event)
end