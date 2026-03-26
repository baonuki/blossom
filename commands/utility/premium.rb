# ==========================================
# COMMAND: premium
# DESCRIPTION: Showcases the benefits of supporting Blossom via server boosting.
# CATEGORY: Utility
# ==========================================

def execute_premium(event)
  components = [
    {
      type: 17,
      accent_color: 0x00FFFF,
      components: [
        { type: 10, content: "## #{EMOJI_STRINGS['prisma']} Blossom Premium" },
        { type: 14, spacing: 1 },
        {
          type: 10,
          content: "Wanna go full whale mode? I respect the hustle.\n\n" \
                   "**#{EMOJI_STRINGS['prisma']} Premium Perks:**\n" \
                   "⏱️ **50% Faster Cooldowns** — grind harder, rest less\n" \
                   "#{EMOJI_STRINGS['s_coin']} **+10% Coin Boost** — cha-ching on everything\n" \
                   "🍀 **Boosted Gacha Odds** — Rares, Legendaries, Goddesses hit different\n" \
                   "#{EMOJI_STRINGS['neonsparkle']} **1% Secret Chance** to insta-pull a Shiny Ascended. ACTUALLY POG."
        },
        { type: 14, spacing: 1 },
        {
          type: 10,
          content: "Boost the Tsukiyo Server to unlock all this. Do it. You won't.\n" \
                   "**https://discord.gg/tsukiyo**"
        }
      ]
    }
  ]

  send_cv2(event, components)
end

# ------------------------------------------
# TRIGGERS
# ------------------------------------------
$bot.command(:premium,
  description: 'View the benefits of Blossom Premium!',
  category: 'Utility'
) do |event|
  execute_premium(event)
  nil
end

$bot.application_command(:premium) do |event|
  execute_premium(event)
end
