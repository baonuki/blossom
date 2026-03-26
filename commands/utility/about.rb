# ==========================================
# COMMAND: about
# DESCRIPTION: Displays the bot's purpose, features, and developer credits.
# CATEGORY: Utility
# ==========================================

def execute_about(event)
  components = [
    {
      type: 17,
      accent_color: 0xFF69B4,
      components: [
        { type: 10, content: "## #{EMOJI_STRINGS['hearts']} About Blossom" },
        { type: 14, spacing: 1 },
        {
          type: 10,
          content: "Yo, what's good chat! I'm **Blossom** — streamer, gacha degen, and the one keeping this whole Neon Arcade running. " \
                   "You're in MY server now, so buckle up.\n\n" \
                   "Type `/help` and I'll show you around. Try to keep up. #{EMOJI_STRINGS['stream']}#{EMOJI_STRINGS['neonsparkle']}"
        },
        { type: 14, spacing: 1 },
        {
          type: 10,
          content: "💻 **The Content Grind**\n" \
                   "Stream, post, collab — hustle your way to the top. Coins don't farm themselves, bestie."
        },
        {
          type: 10,
          content: "🎲 **VTuber Gacha**\n" \
                   "Blow your hard-earned coins on gacha pulls. Get a Goddess or get rekt. No refunds~"
        },
        {
          type: 10,
          content: "#{EMOJI_STRINGS['bomb']} **A Little Bit of Trolling**\n" \
                   "Bombs drop in chat randomly. Be fast or be broke. First click eats good tonight."
        },
        { type: 14, spacing: 1 },
        {
          type: 10,
          content: "#{EMOJI_STRINGS['developer']} Built by **Kyvrixon Dev.** — coded by **en.vvy** in **.rb** (Ruby). Yeah, I'm handcrafted. You're welcome."
        }
      ]
    }
  ]

  send_cv2(event, components)
end

# ------------------------------------------
# TRIGGERS
# ------------------------------------------
$bot.command(:about,
  description: 'Learn more about Blossom!',
  category: 'Utility'
) do |event|
  execute_about(event)
  nil
end

$bot.application_command(:about) do |event|
  execute_about(event)
end
