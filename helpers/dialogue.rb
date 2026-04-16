# ==========================================
# HELPER: Blossom Dialogue Expansion
# DESCRIPTION: Contextual remarks based on time, streaks, and patterns.
# ==========================================

# Time-of-day remarks (appended to command responses randomly ~30% of the time)
def time_remark
  return nil unless rand(100) < 30

  hour = Time.now.hour
  case hour
  when 0..4
    [
      "\n\n*...Why are you up at #{hour} AM? Go to sleep, chat.*",
      "\n\n*It's literally #{hour} AM. The Neon Arcade never closes but YOU should.*",
      "\n\n*Late night grind? I respect it. Also, go to bed.*",
      "\n\n*The arcade lights are dimmed at this hour. Just saying.*",
      "\n\n*#{hour} AM and you're STILL here? The commitment is concerning but appreciated.*",
      "\n\n*The janitor bots are cleaning the arcade floor right now. You're in their way.*",
      "\n\n*Fun fact: the neon lights run on low power between midnight and 5 AM. Just like you should be.*"
    ].sample
  when 5..7
    [
      "\n\n*Early bird gets the coins, I guess. Respect.*",
      "\n\n*Up at dawn? That's either dedication or insomnia.*",
      "\n\n*Morning grind. The arcade machines are still warming up.*",
      "\n\n*You're up before the neon signs? That's raw dedication right there.*",
      "\n\n*The sunrise is hitting the arcade windows. Very aesthetic. Now go grind.*"
    ].sample
  when 8..11
    [
      "\n\n*Peak morning hours. The arcade is buzzing!*",
      "\n\n*Good morning, grinder. The machines are warmed up and ready.*"
    ].sample
  when 12..13
    [
      "\n\n*Lunchtime gaming? Eating at the arcade like a true degenerate. Respect.*",
      "\n\n*Midday grind session! Don't forget to actually eat something, chat.*"
    ].sample
  when 17..19
    [
      "\n\n*After-work arcade session? This is what peak relaxation looks like.*",
      "\n\n*Evening rush hour at the Neon Arcade! The machines are running hot.*"
    ].sample
  when 22..23
    [
      "\n\n*One more command before bed? Sure, I believe you.*",
      "\n\n*Night owl energy. The neon lights hit different at this hour.*",
      "\n\n*Late night session? The jackpots are supposedly better. (They're not.)*",
      "\n\n*The arcade is getting quiet. Perfect time to grind without distractions.*",
      "\n\n*Almost midnight. The neon glows brighter when the crowd thins out.*"
    ].sample
  else
    nil
  end
end

# Streak context (for daily command)
def streak_remark(streak)
  return nil if streak < 3

  case streak
  when 3..6
    [
      "\n*Not bad, you're building something here. Don't mess it up.*",
      "\n*Three days in? Baby steps. Keep it going, chat.*",
      "\n*The streak is alive! Don't you DARE forget tomorrow.*"
    ].sample
  when 7..13
    [
      "\n*A full week+! Okay, I see you. Keep it going.*",
      "\n*Seven straight? The discipline is real. The neon signs are flickering in approval.*",
      "\n*Over a week! You're in the groove now, don't stop.*"
    ].sample
  when 14..29
    [
      "\n*Two weeks deep? You're actually dedicated. I'm... slightly impressed.*",
      "\n*Fourteen days and counting. I'm starting to believe in you.*",
      "\n*Half a month! The arcade regulars are taking notice.*"
    ].sample
  when 30..49
    [
      "\n*A MONTH of consistency? Who even are you? \u{1F525}*",
      "\n*30+ days?! Your name is going on the Neon Arcade Hall of Fame wall. Maybe.*",
      "\n*Over a month! At this point you're basically furniture here. Welcome home.*"
    ].sample
  when 50..99
    [
      "\n*Over 50 days. You're built different and I mean that.*",
      "\n*Fifty days?? The arcade machines literally recognize your footsteps now.*",
      "\n*Half a hundred. The legends speak of players like you.*"
    ].sample
  when 100..199
    [
      "\n*Triple digits. You are genuinely terrifying. In a good way.*",
      "\n*100+ DAYS. I'm getting your face engraved on a coin. A REAL coin.*",
      "\n*The century club! You've officially outlasted three seasonal events.*"
    ].sample
  when 200..364
    [
      "\n*200+ days?! You're not a player anymore, you're an INSTITUTION.*",
      "\n*At this point the Neon Arcade should be paying YOU rent.*",
      "\n*I've seen empires rise and fall in less time than your streak.*"
    ].sample
  else
    [
      "\n*Over a YEAR? You absolute legend. I'm naming an arcade machine after you.*",
      "\n*365+ DAYS. You have transcended. You ARE the Neon Arcade now.*",
      "\n*A full year?! Okay, I'm actually emotional. Don't tell anyone. \u{1F338}*"
    ].sample
  end
end

# Losing streak remarks (for arcade games)
def losing_remark(consecutive_losses)
  return nil unless consecutive_losses && consecutive_losses >= 3

  case consecutive_losses
  when 3..4
    [
      "\n\n*...That's #{consecutive_losses} L's in a row. Maybe take a breather?*",
      "\n\n*#{consecutive_losses} losses? The machines smell fear, you know.*",
      "\n\n*#{consecutive_losses} in a row. The neon lights are dimming in secondhand embarrassment.*"
    ].sample
  when 5..7
    [
      "\n\n*#{consecutive_losses} losses straight. The machines are EATING you alive, chat.*",
      "\n\n*#{consecutive_losses} L's. Should I call someone? A therapist maybe?*",
      "\n\n*At #{consecutive_losses} losses, the arcade is technically bullying you and I'm allowing it.*"
    ].sample
  when 8..10
    [
      "\n\n*#{consecutive_losses} consecutive losses. At this point it's performance art.*",
      "\n\n*#{consecutive_losses} losses. I've seen gacha addicts with more self-control.*",
      "\n\n*#{consecutive_losses} straight L's. The arcade janitor is sweeping your dignity off the floor.*"
    ].sample
  else
    [
      "\n\n*#{consecutive_losses} losses. I'm genuinely concerned. Do you need a hug?*",
      "\n\n*#{consecutive_losses} losses?! I'm cutting you off. This is an intervention.*",
      "\n\n*#{consecutive_losses} L's in a row. Congratulations, that's actually a record. A BAD record, but still.*"
    ].sample
  end
end

# First-time command usage (check if stat counter is 0 or 1)
def first_time_remark(command_type)
  case command_type
  when 'summon'
    "\n\n*Oh, first pull? Welcome to gacha hell, chat. There's no escape. \u{1F338}*"
  when 'coinflip'
    "\n\n*First gamble? Careful \u2014 the arcade is addictive. Don't say I didn't warn you.*"
  when 'collab'
    "\n\n*First collab! Look at you being social. I'm proud. Kind of.*"
  when 'trade'
    "\n\n*First trade! Welcome to the marketplace. Try not to get scammed. \u{1F338}*"
  when 'trivia'
    "\n\n*First trivia! Let's see if you actually know anything or just got lucky.*"
  when 'crew'
    "\n\n*First crew action! Squads up, chat. The +5% coin bonus is no joke.*"
  when 'craft'
    "\n\n*First time in the workshop! Turn those scraps into something beautiful. \u{2699}\u{FE0F}*"
  when 'salvage'
    "\n\n*First salvage! Those duplicates are worth more as materials, trust me.*"
  when 'hug'
    "\n\n*First hug! Aww, look at you spreading warmth in the Neon Arcade. \u{1F338}*"
  when 'invest'
    "\n\n*First investment! Passive income arc begins. The coins make coins make coins...*"
  when 'fish'
    "\n\n*First time fishing! Cast your line and pray to the RNG gods. \u{1F3A3}*"
  when 'boss'
    "\n\n*First boss attack! Every hit counts toward that sweet Prisma reward. Go get 'em!*"
  else
    nil
  end
end

# Wealth-based flavor (for balance/economy commands)
def wealth_remark(coins)
  return nil unless rand(100) < 25

  case coins
  when 0
    [
      "\n\n*Broke. Absolutely broke. The arcade ATM is judging you.*",
      "\n\n*Zero coins. The vending machine won't even look at you.*"
    ].sample
  when 1..99
    [
      "\n\n*Scraping the bottom of the coin jar, huh?*",
      "\n\n*That balance is giving 'borrowed someone's lunch money' energy.*"
    ].sample
  when 100..999
    "\n\n*Getting there. Baby steps toward not being completely broke.*"
  when 10_000..99_999
    "\n\n*Five figures! You're officially an arcade middle class citizen.*"
  when 100_000..999_999
    [
      "\n\n*Six figures? The Neon Arcade VIP lounge awaits.*",
      "\n\n*100K+ club. The neon lights literally shine brighter when you walk in.*"
    ].sample
  when 1_000_000..Float::INFINITY
    [
      "\n\n*A millionaire walks among us. Someone alert the paparazzi.*",
      "\n\n*Seven figures?! You could buy the entire Black Market inventory twice.*",
      "\n\n*At this point the arcade owes YOU money.*"
    ].sample
  else
    nil
  end
end

# Crew-specific remarks (for crew commands)
def crew_remark
  return nil unless rand(100) < 30
  [
    "\n\n*Crew power! Strength in numbers, chat.*",
    "\n\n*The crew that grinds together, shines together.*",
    "\n\n*Squad goals. Literally.*",
    "\n\n*Nothing hits harder than a coordinated crew grind session.*",
    "\n\n*Crew XP going UP. The leaderboard is shaking.*"
  ].sample
end

# Crafting remarks (for craft/salvage commands)
def craft_remark
  return nil unless rand(100) < 35
  [
    "\n\n*The forge is HOT today. Keep crafting, chat.*",
    "\n\n*Turning scrap into treasure. The Neon Arcade workshop never sleeps.*",
    "\n\n*Another one crafted! Your cosmetic game is about to be UNMATCHED.*",
    "\n\n*The sound of materials being forged into something beautiful. Chef's kiss.*",
    "\n\n*Salvage, craft, flex. The circle of arcade life.*"
  ].sample
end

# Friendship tier milestone remarks
def friendship_milestone_remark(tier_name)
  case tier_name
  when 'Acquaintance'
    "\n\n*Look at that — you've gone from strangers to acquaintances! The power of bonking each other with hugs.*"
  when 'Friend'
    "\n\n*Official friends now! Your collabs are gonna hit different with that bonus. \u{1F338}*"
  when 'Close Friend'
    "\n\n*CLOSE FRIENDS?? The bond is REAL. That collab bonus is looking juicy.*"
  when 'Best Friend'
    "\n\n*BEST FRIENDS!! \u{1F31F} The highest tier! Your collabs are gonna be LEGENDARY. I'm not crying, you're crying.*"
  else
    nil
  end
end

# Challenge completion remarks
def challenge_remark
  return nil unless rand(100) < 40
  [
    "\n\n*Another challenge down! Keep grinding those weeklies, chat.*",
    "\n\n*Challenge progress going crazy. You love to see it.*",
    "\n\n*The weekly grind is REAL. That bonus is calling your name.*",
    "\n\n*One step closer to that sweet, sweet challenge bonus. Don't stop now.*"
  ].sample
end

# Gacha-specific mood remarks based on rarity
def pull_mood_remark(rarity)
  return nil unless rand(100) < 25
  case rarity
  when :common
    [
      "\n\n*Another common. The gacha gods are testing your faith.*",
      "\n\n*Common pull energy. We go again.*"
    ].sample
  when :rare
    "\n\n*Rare! Not bad. The neon signs flickered in approval.*"
  when :legendary
    "\n\n*LEGENDARY?! The arcade machines just went haywire! LET'S GO!*"
  when :goddess
    "\n\n*GODDESS TIER. I think the mainframe just short-circuited. THIS IS NOT A DRILL.*"
  else
    nil
  end
end

# Get friendship tier name from affinity value
def friendship_tier(affinity)
  tier = FRIENDSHIP_TIERS.select { |min, _| affinity >= min }.max_by { |min, _| min }
  tier ? tier[1][:name] : 'Stranger'
end

# Get friendship collab bonus from affinity value
def friendship_bonus(affinity)
  tier = FRIENDSHIP_TIERS.select { |min, _| affinity >= min }.max_by { |min, _| min }
  tier ? tier[1][:bonus] : 0
end
