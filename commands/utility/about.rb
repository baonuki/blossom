def execute_about(event)
  fields = [
    { name: "#{EMOJIS['play']} The Content Grind", value: "We are on that monetization grind! I manage the server's economy so you can earn #{EMOJIS['s_coin']} by hitting that `b!stream` button, getting engagement with a quick `b!post` on socials, or doing a `b!collab` with other chatters.", inline: false },
    { name: "#{EMOJIS['sparkle']} VTuber Gacha", value: "Spend your hard-earned stream revenue to `b!summon` your favorite VTubers! Will you pull common indie darlings, or hit the legendary RNG for Gura, Calli, or Ironmouse? Build your `b!collection` and flex your pulls!", inline: false },
    { name: "#{EMOJIS['like']} Just Chatting & Vibes", value: "Lurkers don't get XP here! I track your chat activity and reward you with levels the more you type. Plus, you can `b!hug` your friends or `b!slap` a troll.", inline: false },
    { name: "#{EMOJIS['bomb']} A Little Bit of Trolling", value: "Sometimes chat gets too cozy, so the admins let me drop a literal `b!bomb` in the channel. You have to scramble to defuse it for a massive coin payout, or the whole chat goes BOOM!", inline: false },
    { name: "#{EMOJIS['developer']} Behind the Scenes", value: "Blossom is a Kyvrixon Dev. product. Developed by **en.vvy** and written in **.rb** (Ruby).", inline: false }
  ]
  send_embed(event, title: "#{EMOJIS['heart']} About Blossom", description: "Hey Chat! I'm **Blossom**, your server's dedicated head mod, hype-woman, and resident gacha addict. I'm here to turn your Discord server into the ultimate content creator community.\n\nDrop a `/help` in chat and let's go live! #{EMOJIS['stream']}#{EMOJIS['neonsparkle']}", fields: fields)
end

bot.command(:about, description: 'Learn more about Blossom!', category: 'Utility') { |e| execute_about(e); nil }
bot.application_command(:about) { |e| execute_about(e) }