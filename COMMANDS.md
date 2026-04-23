# Blossom Bot - Command Reference

> **Version:** 1.3 &bull; **Prefix:** `b!` &bull; **Slash Commands:** Supported
> All commands can be used with either the `b!` prefix or as Discord slash commands (`/`).

---

## Table of Contents

- [Economy](#economy)
- [Gacha & Collection](#gacha--collection)
- [Arcade](#arcade)
- [Fun & Social](#fun--social)
- [Moderation](#moderation)
- [Server Administration](#server-administration)
- [Voice](#voice)
- [Utility](#utility)
- [Premium Perks](#premium-perks)
- [Achievements](#achievements)
- [Seasonal Events](#seasonal-events)
- [Items & Black Market](#items--black-market)

---

## Economy

Commands for earning, managing, and spending coins.

### `/daily`
Claim your daily coin reward with a visual monthly login calendar. Consecutive claims build a streak that increases your payout. The calendar shows your claimed days each month with milestone bonuses.

| Detail | Value |
|--------|-------|
| **Aliases** | `d` |
| **Cooldown** | 24 hours |
| **Base Reward** | 350 coins + (streak &times; 30) |
| **Streak Reset** | Resets if more than 48 hours pass between claims |
| **14-Day Milestone** | 1,000 coins (2,000 for Premium) |
| **28-Day Milestone** | 5,000 coins (10,000 coins + 10 Prisma for Premium) |

**Calendar Grid:** Shows a visual monthly grid with claimed days (&#9608;), missed days (&middot;), today (&#9654;), and future days (-).

**Bonuses:**
- **Holographic Neon Sign** (item): Doubles payout
- **Marriage bonus:** +50 coins
- **Premium:** +10% coins and 1-3 Prisma (scales with streak)
- **Happy Hour:** 2x coins (3x for Premium) when active

**Streak Achievements:** 7 days, 30 days, 69 days, 100 days, 365 days

---

### `/invest`
Invest coins into a passive income portfolio that earns compound interest over time. Premium only.

| Detail | Value |
|--------|-------|
| **Usage** | `/invest <amount>` |
| **Min Investment** | 1,000 coins |
| **Rate** | 0.5% per hour (compounding) |
| **Max Return** | 2x your principal (100% profit cap) |
| **Requirement** | Premium |

Use `/portfolio` to check your current investment value and `/withdraw` to cash out at any time.

---

### `/portfolio`
View your current investment status, profit earned, and progress toward max return. Premium only.

---

### `/withdraw`
Cash out your active investment, receiving your principal plus all earned profit. Premium only.

---

### `/autoclaim`
Toggle automatic daily reward claiming. When enabled, Blossom will automatically claim your daily reward whenever it's ready and DM you with the results. Premium only.

| Detail | Value |
|--------|-------|
| **Requirement** | Premium |
| **Behavior** | Auto-claims daily when cooldown expires |
| **Notification** | DM with reward summary |
| **Streak Protection** | Prevents streak loss from forgetting to claim |

---

### `/work`
Perform a work task to earn coins.

| Detail | Value |
|--------|-------|
| **Aliases** | `w` |
| **Cooldown** | 10 minutes (5 min for Premium) |
| **Reward** | 35-75 coins |

**Bonuses:**
- **RGB Keyboard** (item): +25% boost
- **Gamer Fuel** (consumable): Bypasses cooldown

---

### `/stream`
Go live on a random game to earn coins.

| Detail | Value |
|--------|-------|
| **Aliases** | `str` |
| **Cooldown** | 30 minutes (15 min for Premium) |
| **Reward** | 75-150 coins |

**Bonuses:**
- **Studio Mic** (item): +10% boost
- **Gamer Fuel** (consumable): Bypasses cooldown

**Games Pool:** Minecraft, Valorant, Just Chatting, Apex Legends, Lethal Company, Elden Ring, Genshin Impact, Phasmophobia, Overwatch 2, VRChat

---

### `/post`
Upload a social media post for engagement coins.

| Detail | Value |
|--------|-------|
| **Aliases** | `p` |
| **Cooldown** | 5 minutes (2.5 min for Premium) |
| **Reward** | 15-35 coins |

**Bonuses:**
- **Headset** (item): +25% boost
- **Gamer Fuel** (consumable): Bypasses cooldown

**Platforms:** Twitter/X, TikTok, Instagram, YouTube Shorts, Bluesky, Threads, Reddit

---

### `/collab`
Send out a collaboration signal for another player to accept. Both players earn coins when the collab succeeds.

| Detail | Value |
|--------|-------|
| **Aliases** | `colab` |
| **Cooldown** | 30 minutes |
| **Reward** | 150 coins (each player) |
| **Window** | 180 seconds (300 seconds for Premium) |

**Notes:**
- Creates a public message with an "Accept Collab" button
- Another player must accept before the window expires
- **Gamer Fuel** (consumable): Bypasses cooldown

---

### `/balance`
View your (or another player's) balance, cosmetics, and profile.

| Detail | Value |
|--------|-------|
| **Aliases** | `bal` |
| **Usage** | `/balance` or `/balance user:@player` |

**Displays:** Coins, Prisma, reputation, daily streak, title, badge, marriage status, favorite cards (Premium), pet, and bio (Premium). Includes a dropdown menu to navigate to inventory, VTubers, or achievements.

---

### `/givecoins`
Transfer coins to another player.

| Detail | Value |
|--------|-------|
| **Aliases** | `give` |
| **Usage** | `/givecoins user:@player amount:500` |

**Rules:**
- Cannot send coins to yourself
- Amount must be greater than 0
- You must have sufficient balance

---

### `/cooldowns`
View a paginated dashboard of all your active cooldowns.

| Detail | Value |
|--------|-------|
| **Aliases** | `cd`, `timers` |

**Pages:**
1. **Content & Income** — Work, Stream, Post, Summon
2. **Activities & Social** — Collab, Fish, Spin, Rep
3. **Daily & Reminders** — Daily status with streak info

Navigate between pages using the arrow buttons.

---

### `/lottery`
Purchase tickets for the hourly global lottery.

| Detail | Value |
|--------|-------|
| **Aliases** | `lotto` |
| **Ticket Cost** | 100 coins each |
| **Usage** | `/lottery tickets:5` (default: 1) |

**Prize Pool:** 100 base + (100 &times; total tickets sold globally). Drawing occurs at the top of each hour.

---

### `/lotteryinfo`
View the current lottery status without purchasing tickets.

| Detail | Value |
|--------|-------|
| **Aliases** | `lotinfo` |

**Displays:** Next drawing time, current prize pool, total tickets sold, and your ticket count.

---

### `/sell`
Mass-sell duplicate VTuber cards for coins.

| Detail | Value |
|--------|-------|
| **Aliases** | `selldupes` |
| **Usage** | `/sell filter:all`, `/sell filter:over5`, `/sell filter:rarity rarity:common` |

**Filters:**
- `all` — Keep 1 of each card, sell the rest
- `over5` — Keep 5 copies, sell extras
- `rarity <type>` — Sell duplicates of a specific rarity (common, rare, legendary, goddess)

**Sell Prices:**

| Rarity | Price per Card |
|--------|---------------|
| Common | 50 coins |
| Rare | 250 coins |
| Legendary | 1,000 coins |
| Goddess | 5,000 coins |

**Premium Perk:** 5-minute undo window with an Undo button.

---

### `/event`
Access the seasonal limited-time event hub.

| Detail | Value |
|--------|-------|
| **Aliases** | `ev` |

Opens an interactive menu to browse and participate in the current seasonal event. See [Seasonal Events](#seasonal-events) for details.

---

### `/remindme`
Toggle daily reward reminder notifications. Available to all users.

| Detail | Value |
|--------|-------|
| **Aliases** | `remind` |

When enabled, Blossom will ping you in the channel when your daily reward is ready to claim.

---

## Gacha & Collection

Commands for summoning, collecting, trading, and managing VTuber cards.

### `/summon`
Spend coins to pull a random VTuber card from the gacha.

| Detail | Value |
|--------|-------|
| **Aliases** | `pull`, `roll` |
| **Cost** | 150 coins (300 with Shiny Hunting Mode) |
| **Cooldown** | 10 minutes (5 min with Gacha Pass item) |

**Rarity Tiers:** Common, Rare, Legendary, Goddess

**Mechanics:**
- **Pity System (Premium):** Guaranteed Legendary or Goddess after 30 pulls without a Rare+ result
- **Shiny Ascended Chance:** 1% normally, 2% with Shiny Hunting Mode (Premium)
- **Event Pull Chance:** 5% chance to pull an event character during event months
- **Auto-Sell (Premium):** Automatically sells common duplicates (5+ owned) if enabled
- **RNG Manipulator** (consumable): Guarantees Rare+ on the next pull
- **Stamina Pill** (consumable): Bypasses summon cooldown
- **Custom Banner:** If active, pulls only from your selected characters
- **Roster Update:** Expanded Common/Rare/Legendary pools with new indie VTubers, plus new Goddess cards including `baonuki`, `Katoh Eli`, and `Megrocks.exe`

---

### `/shop`
Browse the VTuber shop and Black Market.

| Detail | Value |
|--------|-------|
| **Aliases** | `store` |

Opens an interactive shop browser with character prices and Black Market items. Use the navigation buttons and dropdowns to browse.

---

### `/buy`
Purchase a character or item directly from the shop.

| Detail | Value |
|--------|-------|
| **Aliases** | `purchase` |
| **Usage** | `/buy item:character_name` or `/buy item:gamer_fuel quantity:5` |

**Character Prices:**

| Rarity | Price |
|--------|-------|
| Common | 1,000 coins |
| Rare | 5,000 coins |
| Legendary | 25,000 coins |
| Goddess | 100 Prisma |

**Notes:**
- Event characters cannot be purchased here (use the Event Hub)
- Tech upgrades can only be purchased once
- Consumables can be bought in bulk with the `quantity` option
- See [Items & Black Market](#items--black-market) for the full item list

---

### `/view`
View detailed information about any VTuber character.

| Detail | Value |
|--------|-------|
| **Aliases** | `v` |
| **Usage** | `/view character:name` |

**Displays:** Character art/GIF, rarity, your ownership count (base + ascended), and availability info. Premium users can favorite the character directly from this view.

---

### `/collection`
Browse your (or another player's) VTuber card collection.

| Detail | Value |
|--------|-------|
| **Aliases** | `coll`, `cards` |
| **Usage** | `/collection` or `/collection user:@player` |

**Features:**
- Paginated display (10 cards per page)
- Filter by rarity using the dropdown menu
- Shows ascended cards with a sparkle indicator
- Supports collection themes (customizable via `/profile`)

---

### `/trade`
Propose a 1-for-1 card trade with another player.

| Detail | Value |
|--------|-------|
| **Aliases** | `tr` |
| **Usage (Prefix)** | `b!trade @user My Character for Their Character` |
| **Usage (Slash)** | `/trade user:@player offer:character request:character` |
| **Window** | 60 seconds (180 seconds for Premium) |

The other player must accept or decline using the buttons before the window expires.

---

### `/givecard`
Gift a card to another player for free (no acceptance required).

| Detail | Value |
|--------|-------|
| **Aliases** | `gift` |
| **Usage** | `/givecard user:@player character:name` |

**Rules:**
- You must own the card
- Only base copies are gifted (not ascended)
- The transfer is immediate and one-way

---

### `/giftlog`
View your history of sent and received card gifts.

| Detail | Value |
|--------|-------|
| **Aliases** | `gifts`, `gifthistory` |
| **Usage** | `/giftlog` or `/giftlog page:2` |

Paginated list showing character names, rarity, the other player, and the date.

---

### `/ascend`
Fuse 5 duplicate copies of a character into 1 Shiny Ascended version.

| Detail | Value |
|--------|-------|
| **Aliases** | `asc` |
| **Cost** | 5,000 coins + 5 duplicate cards |
| **Usage** | `/ascend character:name` |

---

### `/autosell`
Toggle automatic selling of common duplicates (5+ owned) during summons. **Premium only.**

| Detail | Value |
|--------|-------|
| **Aliases** | `as` |

When enabled, any common card you already own 5+ copies of is automatically sold during `/summon` at the standard sell price.

---

### `/shinymode`
Toggle Shiny Hunting Mode, which doubles your summon cost but doubles your shiny chance. **Premium only.**

| Detail | Value |
|--------|-------|
| **Aliases** | `shiny`, `shinyhunt` |

- **Normal:** 150 coin summon cost, 1% shiny chance
- **Shiny Mode:** 300 coin summon cost, 2% shiny chance

---

### `/custombanner`
Create a temporary custom summon banner with your chosen characters. **Premium only.**

| Detail | Value |
|--------|-------|
| **Aliases** | `cb`, `mybanner` |
| **Cost** | 20 Prisma |
| **Duration** | 1 hour |

**Usage (Prefix):**
```
b!custombanner Char1, Char2, Char3, Char4, Char5 | Rare1, Rare2, Rare3, Rare4, Rare5 | Leg1, Leg2, Leg3, Leg4, Leg5 | God1, God2, God3
```

**Usage (Slash):**
```
/custombanner commons:... rares:... legendaries:... goddesses:...
```

**Requirements:**
- 5 commons, 5 rares, 5 legendaries, 3 goddesses (pipe-separated tiers, comma-separated names)
- All characters must exist in the universal pool at their correct rarity
- No duplicates within the same tier

While active, all your `/summon` pulls draw exclusively from this banner.

---

### `/craft`
Craft exclusive cosmetics (badges, titles, themes, pets) from materials.

| Detail | Value |
|--------|-------|
| **Usage** | `/craft` (view recipes) or `/craft recipe:craftsman` |

**Materials:**
- **Scrap** ⚙️ — Obtained from salvaging Common cards
- **Essence** 💎 — Obtained from salvaging Rare+ cards

**Craftable Items:**

| Recipe | Type | Materials | Coin Cost |
|--------|------|-----------|-----------|
| Craftsman | Badge | 10 Scrap | 500 |
| Forgemaster | Badge | 5 Essence | 2,000 |
| Scrap King | Badge | 50 Scrap | 1,000 |
| Tinkerer | Title | 15 Scrap | 500 |
| Engineer | Title | 10 Essence | 3,000 |
| Scrapyard Boss | Title | 30 Scrap + 3 Essence | 1,500 |
| Forge | Theme | 20 Scrap + 5 Essence | 2,000 |
| Circuit | Theme | 30 Scrap | 3,000 |
| Scrap Golem | Pet | 25 Scrap + 10 Essence | 5,000 |
| Spark Wisp | Pet | 15 Essence | 3,000 |

These items are **craft-exclusive** and cannot be purchased in the shop.

---

### `/salvage`
Break down duplicate VTuber cards into crafting materials.

| Detail | Value |
|--------|-------|
| **Usage** | `/salvage amount:5 rarity:common` |
| **Default** | Salvages 1 common card |

**Salvage Rates:**

| Rarity | Material | Per Card |
|--------|----------|----------|
| Common | Scrap | 1 |
| Rare | Essence | 2 |
| Legendary | Essence | 5 |
| Goddess | Essence | 10 |

**Notes:**
- Always keeps at least 1 copy of each card
- Only salvages duplicates (count > 1)

---

## Arcade

Casino and minigame commands. All gambling commands deduct your bet upfront.

### `/coinflip`
Flip a coin and bet on the outcome.

| Detail | Value |
|--------|-------|
| **Aliases** | `cf`, `flip` |
| **Usage** | `/coinflip amount:500 choice:heads` |
| **Payout** | Win: 2&times; bet &bull; Loss: Lose bet |

---

### `/slots`
Spin a 3-reel slot machine.

| Detail | Value |
|--------|-------|
| **Aliases** | `slot` |
| **Usage** | `/slots amount:500` |

**Symbols:** &#x1F352; &#x1F34B; &#x1F514; &#x1F48E; 7&#xFE0F;&#x20E3;

| Result | Payout |
|--------|--------|
| 3 matching symbols (Jackpot) | 5&times; bet |
| 2 matching symbols | 2&times; bet |
| No match | Lose bet |

---

### `/blackjack`
Play a hand of blackjack against Blossom as the dealer.

| Detail | Value |
|--------|-------|
| **Aliases** | `blk` |
| **Usage** | `/blackjack amount:500` |

**Actions:** Hit, Stand, Double Down (if affordable and on a 2-card hand)

| Result | Payout |
|--------|--------|
| Natural 21 (Blackjack) | 2.5&times; bet |
| Player wins | 2&times; bet |
| Push (tie) | Bet returned |
| Bust or loss | Lose bet |

Only one active blackjack game per player at a time.

---

### `/roulette`
Bet on a European roulette wheel (numbers 0-36).

| Detail | Value |
|--------|-------|
| **Aliases** | `rl` |
| **Usage** | `/roulette amount:500 bet:red` or `/roulette amount:500 bet:17` |

**Valid Bets:** `red`, `black`, `even`, `odd`, or a specific number (0-36)

| Result | Payout |
|--------|--------|
| Exact number | 36&times; bet |
| Color or parity | 2&times; bet |
| Loss | Lose bet |

---

### `/dice`
Roll two dice and bet on the total being high, low, or exactly 7.

| Detail | Value |
|--------|-------|
| **Aliases** | `di` |
| **Usage** | `/dice amount:500 bet:high` |

**Bet Options:**
- `high` (8-12): 2&times; payout
- `low` (2-6): 2&times; payout
- `7` (exactly 7): 4&times; payout

---

### `/cups`
Pick which of 3 cups hides the coin.

| Detail | Value |
|--------|-------|
| **Aliases** | `cup` |
| **Usage** | `/cups amount:500 guess:2` |
| **Payout** | Correct: 3&times; bet &bull; Wrong: Lose bet |

---

### `/scratch`
Purchase and scratch a scratch-off ticket.

| Detail | Value |
|--------|-------|
| **Aliases** | `sc` |
| **Cost** | 500 coins (fixed) |

Scratch 3 random symbols. Triple matches win:

| Symbols | Prize |
|---------|-------|
| &#x1F31F; &#x1F31F; &#x1F31F; | 10,000 coins |
| &#x1F48E; &#x1F48E; &#x1F48E; | 5,000 coins |
| &#x1F34B; &#x1F34B; &#x1F34B; | 2,500 coins |
| &#x1F352; &#x1F352; &#x1F352; | 1,000 coins |
| &#x1F480; &#x1F480; &#x1F480; | 500 coins |
| No match | Lose ticket price |

---

### `/spin`
Spin the daily prize wheel.

| Detail | Value |
|--------|-------|
| **Aliases** | `wheel` |
| **Cooldown** | 24 hours |
| **Cost** | Free |

**Prize Pool (weighted):**
- Coins: 50, 100, 250, 500, 1,000, 2,500, 5,000
- Prisma: 5, 10
- Cards: Random Legendary, Random Goddess

**Premium Perk:** One free reroll per spin.

---

### `/rps`
Challenge another player to Rock Paper Scissors with a coin bet.

| Detail | Value |
|--------|-------|
| **Aliases** | `rockpaperscissors` |
| **Usage** | `/rps user:@player bet:500` |
| **Window** | 60 seconds to accept |
| **Payout** | Winner takes 2&times; the bet |

Both players must be able to afford the bet. The opponent accepts or declines via buttons, then both players submit hidden choices.

---

### `/fish`
Cast your line and catch fish for coins.

| Detail | Value |
|--------|-------|
| **Aliases** | `fishing`, `cast` |
| **Cooldown** | 5 minutes (2.5 min for Premium) |
| **Cost** | Free |

**Catch Table:**

| Tier | Catch | Reward |
|------|-------|--------|
| Junk | Old Boot | 5 coins |
| Junk | Tin Can | 10 coins |
| Junk | Seaweed | 15 coins |
| Common | Guppy | 30 coins |
| Common | Sardine | 50 coins |
| Common | Clownfish | 75 coins |
| Uncommon | Pufferfish | 100 coins |
| Uncommon | Electric Eel | 150 coins |
| Rare | Octopus | 250 coins |
| Rare | Sea Turtle | 400 coins |
| Epic | Shark | 750 coins |
| Legendary | Whale | 1,500 coins |
| Mythic | Golden Koi | 3,000 coins |

**Premium-Only Catches (Gold Rod):**

| Tier | Catch | Reward |
|------|-------|--------|
| Uncommon | Neon Jellyfish | 500 coins |
| Epic | Abyssal Leviathan | 2,000 coins |
| Special | Prisma Crab | 5 Prisma |

Premium users also receive a +10% coin bonus on all catches.

---

### `/trivia`
Answer VTuber-themed trivia questions for coins. Questions are generated from the character pool data and general VTuber knowledge.

| Detail | Value |
|--------|-------|
| **Cooldown** | 2 minutes |
| **Reward** | 50-100 coins (100-200 for Premium) |
| **Time Limit** | 15 seconds to answer |

**Question Types:**
- Rarity tier identification
- "Which VTuber is rarer?"
- "Which is NOT in the collection?" (odd one out)
- General VTuber and Blossom knowledge
- Character pool membership

Four multiple-choice answer buttons (A/B/C/D). Answer before time runs out!

---

### `/boss`
View and attack the monthly boss. Each month a new boss spawns with 100,000 HP. All players can attack once per hour. When defeated, all participants earn 50 Prisma.

| Detail | Value |
|--------|-------|
| **Boss HP** | 100,000 |
| **Damage** | 50-200 (100-400 for Premium) |
| **Attack Cooldown** | 1 hour |
| **Defeat Reward** | 50 Prisma to ALL participants |
| **Reset** | New boss each month |

**Boss Names Rotate:** Glitch Hydra, The Lag Beast, Corrupted Firewall, Neon Phantom, Data Leviathan, and more.

---

## Fun & Social

Social interactions, profiles, and community features.

### `/hug`
Send a hug to another player with a random GIF.

| Detail | Value |
|--------|-------|
| **Aliases** | `embrace` |
| **Usage** | `/hug user:@player` |

Tracks sent and received hug stats. Hugging Blossom triggers a special response. Achievements unlock at 10, 50, and 100 hugs (both sent and received).

---

### `/slap`
Send a playful slap to another player with a random GIF.

| Detail | Value |
|--------|-------|
| **Aliases** | `smack` |
| **Usage** | `/slap user:@player` |

Tracks sent and received slap stats. Slapping Blossom triggers a "Bot Abuse Detected" response. Achievements unlock at 10, 50, and 100 slaps (both sent and received).

---

### `/pat`
Give someone a gentle head pat with a random GIF.

| Detail | Value |
|--------|-------|
| **Aliases** | `headpat` |
| **Usage** | `/pat user:@player` |

Tracks sent and received pat stats. Patting Blossom triggers a special response.

---

### `/interactions`
View your total sent and received counts for hugs, slaps, and pats.

| Detail | Value |
|--------|-------|
| **Aliases** | `int` |

---

### `/rep`
Give reputation to another player.

| Detail | Value |
|--------|-------|
| **Usage** | `/rep user:@player` |
| **Limit** | 1 per day (3 per day for Premium) |

**Rules:**
- Cannot rep yourself or bots
- Cannot rep the same player twice in one day

---

### `/marry`
Propose marriage to another player for profile flair and a daily bonus.

| Detail | Value |
|--------|-------|
| **Usage** | `/marry user:@player` |

The other player must accept or decline via buttons. Once married, both players receive a +50 coin bonus on `/daily` claims, and the partnership appears on your `/balance` profile.

---

### `/divorce`
End your current marriage.

| Detail | Value |
|--------|-------|
| **Usage** | `/divorce` |

---

### `/birthday`
Set or view your birthday. Receive a 1,000 coin reward on your special day.

| Detail | Value |
|--------|-------|
| **Aliases** | `bday` |
| **Usage** | `/birthday date:MM/DD` (set) or `/birthday` (view) |

**Rules:**
- Date format: `MM/DD` (e.g., `04/20`)
- Can only be set once (no changes allowed)

---

### `/level`
View your (or another player's) level, XP, and profile card.

| Detail | Value |
|--------|-------|
| **Aliases** | `lvl`, `rank` |
| **Usage** | `/level` or `/level user:@player` |

**Displays:** Level, XP progress bar, coins, reputation, daily streak, marriage status, favorite cards (Premium), pet, and bio.

**XP System:** Earn 5 XP per message (10-second cooldown between XP gains).

---

### `/leaderboard`
View server and global rankings for coins, Prisma, or levels.

| Detail | Value |
|--------|-------|
| **Aliases** | `lb`, `top` |

Use the dropdown menu to switch between leaderboard categories. Server-only command.

---

### `/serverinfo`
View server statistics and the community level.

| Detail | Value |
|--------|-------|
| **Aliases** | `si`, `server` |

**Displays:** Server owner, member count, community level and XP, and creation date. Server-only command.

---

### `/giveaway`
Start a giveaway in a channel. **Admin only.**

| Detail | Value |
|--------|-------|
| **Aliases** | `gw` |
| **Usage** | `/giveaway channel:#channel time:2h prize:1000 Coins` |

**Time Formats:** `10m` (minutes), `2h` (hours), `1d` (days)

Creates an embed with a participation button in the specified channel. A winner is randomly selected when the timer expires.

---

### `/crew`
Create, manage, and compete in global crews. Crew members get a +5% coin bonus on all earnings.

| Detail | Value |
|--------|-------|
| **Usage** | `/crew` (view your crew) |
| **Create Cost** | 5,000 coins |
| **Max Members** | 15 |
| **Crew Bonus** | +5% coins for all members |

**Subcommands:**
- `crew create <name> <tag>` — Create a crew (name 3-30 chars, tag 2-5 chars)
- `crew invite @user` — Invite a player (leaders/officers only)
- `crew leave` — Leave your current crew
- `crew kick @user` — Remove a member (leaders/officers only)
- `crew promote @user` — Transfer leadership (leader only)
- `crew disband` — Delete the crew (leader only)
- `crew leaderboard` — View top 10 crews by XP

**Crew XP:** Earned passively when members earn coins (1 XP per 50 coins earned). Crews level up as they accumulate XP.

---

### `/friends`
View your friendship levels and affinity with other players.

| Detail | Value |
|--------|-------|
| **Aliases** | `friendship` |
| **Usage** | `/friends` (list) or `/friends user:@player` (specific) |

**Affinity Sources:**

| Action | Affinity Gained |
|--------|----------------|
| Collab | +5 |
| Gift Card | +5 |
| Give Coins | +5 |
| Trade | +3 |
| Hug | +1 |
| Pat | +1 |
| Slap | +1 |

**Friendship Tiers:**

| Affinity | Tier | Collab Bonus |
|----------|------|-------------|
| 0 | Stranger | — |
| 10 | Acquaintance | — |
| 25 | Friend | +5% |
| 50 | Close Friend | +10% |
| 100 | Best Friend | +15% |

---

### `/kettle`
A special inside-joke command. You know who you are.

| Detail | Value |
|--------|-------|
| **Aliases** | `ket` |

---

## Moderation

Commands for server moderation. Require appropriate Discord permissions.

### `/kick`
Kick a member from the server.

| Detail | Value |
|--------|-------|
| **Permission** | Kick Members |
| **Usage** | `/kick user:@player reason:Being silly` |

The kicked user receives a DM notification (if DM logging is enabled). The action is logged to the mod log channel.

---

### `/ban`
Ban a member (or user ID) from the server.

| Detail | Value |
|--------|-------|
| **Permission** | Ban Members |
| **Usage** | `/ban user:@player reason:Rule violation` |

Supports banning by user ID for users who have already left the server. The banned user receives a DM notification (if DM logging is enabled). The action is logged to the mod log channel.

---

### `/timeout`
Temporarily restrict a user's ability to communicate.

| Detail | Value |
|--------|-------|
| **Aliases** | `mute` |
| **Permission** | Moderate Members or Kick Members |
| **Usage** | `/timeout user:@player duration:30m reason:Spam` |

**Duration Formats:** `10m` (minutes), `1h` (hours), `2d` (days)

The timed-out user receives a DM notification (if DM logging is enabled). The action is logged to the mod log channel.

---

### `/purge`
Bulk-delete messages from the current channel.

| Detail | Value |
|--------|-------|
| **Aliases** | `clear`, `prune` |
| **Permission** | Manage Messages |
| **Usage** | `/purge amount:50` |
| **Limit** | 1-100 messages per use |

**Note:** Discord does not allow bulk deletion of messages older than 14 days.

---

## Server Administration

Server setup and configuration commands. Require Administrator permission or Developer status.

### `/logsetup`
Set the destination channel for server activity and moderation logs.

| Detail | Value |
|--------|-------|
| **Aliases** | `logs` |
| **Permission** | Manage Server |
| **Usage** | `/logsetup channel:#mod-logs` |

After setting the log channel, use `/logtoggle` to enable specific log categories.

---

### `/logtoggle`
Enable or disable specific logging categories.

| Detail | Value |
|--------|-------|
| **Aliases** | `lt` |
| **Permission** | Manage Server |
| **Usage** | `/logtoggle type:deletes` |

**Log Categories:**

| Type | Description |
|------|-------------|
| `deletes` | Deleted message logging |
| `edits` | Edited message logging |
| `mod` | Moderation action logging |
| `dms` | DM moderation notifications to offenders |
| `joins` | Member join logging |
| `leaves` | Member leave logging |

Each category toggles independently. Status is displayed with visual ON/OFF indicators.

---

### `/levelup`
Configure where level-up notifications are sent.

| Detail | Value |
|--------|-------|
| **Aliases** | `lu` |
| **Permission** | Administrator |
| **Usage** | `/levelup state:on channel:#level-ups` or `/levelup state:off` |

Options:
- Specify a channel to send level-up messages there
- `on` — Enable level-up notifications
- `off` — Disable level-up notifications

---

### `/bomb`
Enable or disable random bomb drop events in a channel.

| Detail | Value |
|--------|-------|
| **Aliases** | `bombs` |
| **Permission** | Administrator |
| **Usage** | `/bomb action:enable channel:#general` or `/bomb action:disable` |

When enabled, a bomb randomly appears after 100-300 messages in the channel. Players must defuse it before it detonates.

---

### `/welcomer`
Configure welcome messages for new members.

| Detail | Value |
|--------|-------|
| **Aliases** | `welcome` |
| **Permission** | Administrator |
| **Usage** | `/welcomer action:enable channel:#welcome` |

**Sub-actions:**
- `enable #channel` — Enable and set the welcome channel
- `disable` — Turn off welcome messages
- `message <text>` — Set a custom welcome message

**Placeholders:** Use `{user}` for the member's mention and `{server}` for the server name. Use `message reset` to restore the default message.

---

### `/verifysetup`
Create a button-based verification gate for new members.

| Detail | Value |
|--------|-------|
| **Aliases** | `verify` |
| **Permission** | Manage Server |
| **Usage** | `/verifysetup channel:#verify role:@Verified` |

Creates an embed with a "Start Verification" button in the specified channel. New members click the button to receive the assigned role.

---

### `/achievements`
Toggle achievement unlock notification messages server-wide.

| Detail | Value |
|--------|-------|
| **Aliases** | `ach` |
| **Permission** | Administrator |

Toggles whether achievement unlock announcements are posted in the server.

---

### `/commleveltoggle`
Toggle community level-up announcements for the server.

| Detail | Value |
|--------|-------|
| **Aliases** | `clt` |
| **Permission** | Manage Server |

Toggles whether server-wide community level milestones are announced.

---

### `/reactionrole`
Create and manage reaction role panels. **Prefix only.**

| Detail | Value |
|--------|-------|
| **Aliases** | `rr` |
| **Permission** | Administrator |

**Sub-commands:**

| Command | Description |
|---------|-------------|
| `b!rr create #channel Title \| emoji @Role \| emoji @Role` | Create a new reaction role panel |
| `b!rr add <message_id> <emoji> @Role` | Add a role to an existing panel |
| `b!rr remove <message_id> <emoji>` | Remove a role from a panel |
| `b!rr list <message_id>` | List all roles on a panel |

---

### `/heist`
Configure hourly heist events for your server. Admin only.

| Detail | Value |
|--------|-------|
| **Permission** | Administrator |
| **Usage** | `/heist setup #channel` or `/heist disable` |

When enabled, a heist opportunity spawns every hour in the designated channel. Players have 5 minutes to join by clicking the button. Minimum 3 players needed.

**Mechanics:**
- Base success: 30% + 5% per player (max 85%)
- Premium "hacker bonus": +3% per premium player
- Vault: 2,000 + 500 per player coins, split among crew
- On failure: no penalty, better luck next hour

---

### `/automod`
Configure basic auto-moderation for your server. Admin only.

| Detail | Value |
|--------|-------|
| **Permission** | Administrator |
| **Usage** | `/automod` (view status) |

**Sub-commands:**

| Command | Description |
|---------|-------------|
| `b!automod links` | Toggle link filter (deletes links from non-admins) |
| `b!automod spam` | Toggle spam filter (5 msgs in 5s = 1 min timeout) |
| `b!automod words add <word>` | Add a word to the banned list |
| `b!automod words remove <word>` | Remove a word from the banned list |
| `b!automod words list` | View all banned words |

---

### `/bosssetup`
Set the channel for boss defeat announcements. Admin only.

| Detail | Value |
|--------|-------|
| **Permission** | Administrator |
| **Usage** | `/bosssetup #channel` |

---

## Voice

Commands for voice channel interaction.

### `/join`
Summon Blossom to your current voice channel.

You must be in a voice channel to use this command.

---

### `/leave`
Disconnect Blossom from the voice channel.

---

### `/play`
Play an audio file from the bot's music library.

| Detail | Value |
|--------|-------|
| **Usage** | `/play filename` (without .mp3 extension) |

You must be in a voice channel. Blossom will auto-join if not already connected.

---

### `/stop`
Stop the currently playing audio.

---

## Utility

General-purpose and informational commands.

### `/ping`
Check Blossom's response latency.

| Detail | Value |
|--------|-------|
| **Aliases** | `pong` |

Displays round-trip latency in milliseconds.

---

### `/help`
View the command navigation hub with all categories.

| Detail | Value |
|--------|-------|
| **Aliases** | `cmds`, `commands` |
| **Usage** | `/help` or `b!help economy` |

Use the prefix version with a category name to jump directly to that category's commands.

---

### `/about`
View information about Blossom, her features, and developer credits.

| Detail | Value |
|--------|-------|
| **Aliases** | `info` |

---

### `/support`
Get the invite link to the official support server (Tsukiyo Server).

| Detail | Value |
|--------|-------|
| **Aliases** | `sup` |

---

### `/suggest`
Send a suggestion directly to the bot developer.

| Detail | Value |
|--------|-------|
| **Aliases** | `idea` |
| **Usage** | `/suggest suggestion:Add a fishing leaderboard` |

Your suggestion is delivered via DM to the developer along with your server context.

---

### `/stats`
View your comprehensive lifetime statistics dashboard.

| Detail | Value |
|--------|-------|
| **Aliases** | `statistics`, `mystats` |

**Sections:** Economy stats, gacha stats (pull count, rarity breakdown), arcade win/loss rate, social stats (trades, gifts, interactions), and active toggles.

---

### `/notifications`
Configure how achievement unlock notifications are delivered to you.

| Detail | Value |
|--------|-------|
| **Aliases** | `notify`, `achnotify` |
| **Usage** | `/notifications mode:dm` |

**Modes:**
- `channel` — Notifications appear in the channel where the achievement was earned
- `dm` — Notifications are sent privately via DM
- `silent` — No notifications

Run the command without arguments to view your current setting.

---

### `/profile`
Customize your profile card with colors, bio, favorites, and cosmetics. **Premium only.**

| Detail | Value |
|--------|-------|
| **Usage (Slash)** | `/profile view`, `/profile color hex:#FF69B4`, `/profile bio text:Hello!` |
| **Usage (Prefix)** | `b!profile color #FF69B4`, `b!profile bio Hello world` |

**Customization Options:**

| Option | Description | Notes |
|--------|-------------|-------|
| `view` | Preview your profile | — |
| `color <hex>` | Set accent color | Hex format (e.g., `#FF69B4`) |
| `bio <text>` | Set profile bio | Max 100 characters |
| `fav <slot> <name>` | Set a favorite card (slots 1-3) | Slot 1 always available; slots 2-3 flex only |
| `unfav <slot>` | Clear a favorite slot | — |
| `pet <id\|none>` | Equip or unequip a cosmetic pet | Costs Prisma |
| `title <id\|none>` | Equip or unequip a title | Costs Prisma |
| `theme <id>` | Apply a collection theme | Costs Prisma |
| `badge <id\|none>` | Equip or unequip a badge | Some are achievement-locked |
| `reset` | Clear all customizations | — |

You must own the character to set it as a favorite. Re-equipping the same cosmetic does not cost additional Prisma.

---

### `b!derase`
Developer-only emergency command that removes `Kyvrixon` from all user collections and refunds Prisma.

| Detail | Value |
|--------|-------|
| **Permission** | Developer ID only |
| **Refund** | 100 Prisma per removed copy (base + ascended) |
| **Scope** | Global (all users) |

### `/challenges`
View and claim your weekly challenge progress.

| Detail | Value |
|--------|-------|
| **Aliases** | `weekly`, `challenge` |
| **Reset** | Every Monday |
| **Challenges** | 3 per week (4 for Premium) |

**Challenge Types:** Daily claims, arcade wins, cards pulled, coins earned, coins given, trivia correct answers, boss attacks, trades completed, social interactions sent, cards salvaged, cards gifted, collabs completed.

**Rewards:**
- Each challenge has an individual coin reward (150-500 coins)
- Completing ALL challenges gives a **bonus** of 500 coins + 5 Prisma
- A "Claim Bonus" button appears when all challenges are done

**How Progress is Tracked:**
Challenges track automatically as you play. Every command you use that matches a challenge type increments your progress.

---

## Premium Perks

Premium subscribers unlock the following benefits across all systems:

| Perk | Details |
|------|---------|
| **Cooldown Reduction** | 50% shorter cooldowns on work, stream, post, and fish |
| **Coin Bonus** | +10% coins on all earning commands |
| **Happy Hour Boost** | 3x coins during happy hours (vs 2x for free users) |
| **Prisma Currency** | Earn 1-3 Prisma per daily claim (scales with streak) |
| **Calendar Milestones** | Enhanced milestone rewards (2,000 at 14 days, 10,000 + 10 Prisma at 28 days) |
| **Auto-Claim Daily** | Automatic daily claiming with DM notifications — never break streaks |
| **Passive Income** | Invest coins for 0.5%/hr compounding returns (up to 2x principal) |
| **Pity System** | Guaranteed Legendary/Goddess after 30 pulls |
| **Shiny Hunting Mode** | Toggle 2&times; summon cost for 2&times; shiny chance |
| **Auto-Sell** | Automatically sell common duplicates during summon |
| **Custom Banner** | Create a custom 1-hour summon banner (20 Prisma) |
| **Sell Undo** | 5-minute undo window after mass-selling cards |
| **Extended Windows** | Longer trade (180s vs 60s) and collab (300s vs 180s) windows |
| **Spin Reroll** | One free reroll on the daily wheel |
| **Reputation** | 3 reps per day instead of 1 |
| **Profile Customization** | Color, bio, favorites, pets, titles, themes, badges |
| **Gold Fishing Rod** | Access to 3 premium-only fish catches |
| **Favorite Cards** | Display up to 3 favorite VTubers on your profile |
| **Weekly Challenge** | 4th weekly challenge slot (vs 3 for free users) |

**Note:** The +5% crew bonus stacks with Premium bonuses. A Premium crew member gets +10% (Premium) + 5% (Crew) = +15% total bonus.

---

## Achievements

Achievements are unlocked automatically as you use the bot. Each achievement grants a one-time coin reward. Use `/notifications` to configure how you receive unlock alerts, and server admins can toggle server-wide announcements with `/achievements`.

### Economy & Streaks

| Achievement | Requirement | Reward |
|-------------|-------------|--------|
| Streak 7 | 7-day daily streak | 1,000 coins |
| Streak 30 | 30-day daily streak | 5,000 coins |
| Streak 69 | 69-day daily streak | 6,969 coins |
| Streak 100 | 100-day daily streak | 10,000 coins |
| Streak 365 | 365-day daily streak | 50,000 coins |

### Wealth Milestones

| Achievement | Requirement | Reward |
|-------------|-------------|--------|
| Broke | Reach 0 coins | 100 coins |
| 10K Club | Accumulate 10,000 coins | 1,000 coins |
| 100K Club | Accumulate 100,000 coins | 5,000 coins |
| Millionaire | Accumulate 1,000,000 coins | 25,000 coins |
| 10M Mogul | Accumulate 10,000,000 coins | 100,000 coins |

### First Activities

| Achievement | Requirement | Reward |
|-------------|-------------|--------|
| First Stream | Complete your first stream | 500 coins |
| First Collab | Complete your first collab | 1,000 coins |
| First Work | Complete your first work shift | 250 coins |
| First Post | Upload your first post | 250 coins |
| First Gift | Give coins for the first time | 500 coins |

### Coin Gifting

| Achievement | Requirement | Reward |
|-------------|-------------|--------|
| Generous (10K) | Give 10,000 total coins | 2,500 coins |
| Philanthropist (100K) | Give 100,000 total coins | 10,000 coins |
| First Sell | Sell cards for the first time | 500 coins |

### Leveling

| Achievement | Requirement | Reward |
|-------------|-------------|--------|
| Level 5 | Reach level 5 | 500 coins |
| Level 10 | Reach level 10 | 1,000 coins |
| Level 25 | Reach level 25 | 5,000 coins |
| Level 50 | Reach level 50 | 15,000 coins |
| Level 100 | Reach level 100 | 50,000 coins |

### Gacha & Pulls

| Achievement | Requirement | Reward |
|-------------|-------------|--------|
| First Pull | Complete your first summon | 500 coins |
| Goddess Luck | Pull a Goddess-tier character | 5,000 coins |
| 100 Pulls | Complete 100 summons | 5,000 coins |
| 500 Pulls | Complete 500 summons | 15,000 coins |
| 1,000 Pulls | Complete 1,000 summons | 50,000 coins |
| Legendary Pull | Pull a Legendary character | 2,500 coins |
| Back to Back | Pull two rare+ in a row | 3,000 coins |
| First Goddess Buy | Buy a Goddess from the shop | 5,000 coins |

### Collection Size

| Achievement | Requirement | Reward |
|-------------|-------------|--------|
| 10 Unique | Own 10 unique characters | 1,000 coins |
| 50 Unique | Own 50 unique characters | 5,000 coins |
| 100 Unique | Own 100 unique characters | 15,000 coins |
| 200 Unique | Own 200 unique characters | 50,000 coins |

### Rarity Collectors

| Achievement | Requirement | Reward |
|-------------|-------------|--------|
| 25 Rares | Own 25 rare characters | 5,000 coins |
| 10 Legendaries | Own 10 legendary characters | 5,000 coins |
| 25 Legendaries | Own 25 legendary characters | 15,000 coins |
| 5 Goddesses | Own 5 goddess characters | 25,000 coins |

### Ascension

| Achievement | Requirement | Reward |
|-------------|-------------|--------|
| First Ascension | Ascend your first character | 2,500 coins |
| 5 Ascensions | Ascend 5 characters | 10,000 coins |
| 10 Ascensions | Ascend 10 characters | 25,000 coins |
| 25 Ascensions | Ascend 25 characters | 100,000 coins |
| 100 Dupes | Accumulate 100 duplicate cards | 5,000 coins |

### Trading & Gifting Cards

| Achievement | Requirement | Reward |
|-------------|-------------|--------|
| First Trade | Complete your first trade | 1,000 coins |
| 10 Trades | Complete 10 trades | 5,000 coins |
| First Card Gift | Gift a card for the first time | 500 coins |
| 10 Card Gifts | Gift 10 cards | 5,000 coins |

### Items & Black Market

| Achievement | Requirement | Reward |
|-------------|-------------|--------|
| First Upgrade | Purchase a tech upgrade | 1,000 coins |
| Max Upgrades | Own all tech upgrades | 10,000 coins |
| First Consumable | Purchase a consumable | 500 coins |
| Fuel Up | Use a Gamer Fuel | 1,000 coins |
| Stamina Boost | Use a Stamina Pill | 1,000 coins |
| Hoarder | Hold 10+ consumables at once | 2,500 coins |
| RNG Master | Use an RNG Manipulator | 1,000 coins |

### Social Interactions

| Achievement | Requirement | Reward |
|-------------|-------------|--------|
| First Hug | Send your first hug | 100 coins |
| 10/50/100 Hugs Sent | Send 10, 50, or 100 hugs | 1K / 5K / 10K coins |
| 10/50/100 Hugs Received | Receive 10, 50, or 100 hugs | 1K / 5K / 10K coins |
| First Slap | Send your first slap | 100 coins |
| 10/50/100 Slaps Sent | Send 10, 50, or 100 slaps | 1K / 5K / 10K coins |
| 10/50/100 Slaps Received | Receive 10, 50, or 100 slaps | 1K / 5K / 10K coins |
| First Pat | Send your first pat | 100 coins |
| 10/50/100 Pats Sent | Send 10, 50, or 100 pats | 1K / 5K / 10K coins |
| 10/50/100 Pats Received | Receive 10, 50, or 100 pats | 1K / 5K / 10K coins |
| Giveaway Win | Win a giveaway | 5,000 coins |

### Arcade & Gambling

| Achievement | Requirement | Reward |
|-------------|-------------|--------|
| First Win | Win any arcade game | 500 coins |
| Slots Spin | Play the slot machine | 500 coins |
| Slots Jackpot | Hit 3 matching symbols | 5,000 coins |
| Roulette Player | Play roulette | 500 coins |
| Roulette Number | Hit an exact number bet | 10,000 coins |
| Scratch Player | Use a scratch ticket | 500 coins |
| Scratch Jackpot | Hit the star jackpot | 10,000 coins |
| Dice Player | Play dice | 500 coins |
| Lucky 7 | Hit exactly 7 in dice | 5,000 coins |
| Cups Player | Play the cups game | 500 coins |
| High Roller | Place a bet of 10,000+ | 5,000 coins |
| Gambler's Ruin | Lose 5,000+ in one bet | 1,000 coins |
| Lottery Entry | Enter the lottery | 500 coins |
| Lottery Winner | Win the lottery | 25,000 coins |

### Activity Streaks

| Achievement | Requirement | Reward |
|-------------|-------------|--------|
| 7-Day Active | Active for 7 days | 500 coins |
| 14-Day Active | Active for 14 days | 1,500 coins |
| 30-Day Active | Active for 30 days | 5,000 coins |
| 60-Day Active | Active for 60 days | 10,000 coins |
| 100-Day Active | Active for 100 days | 25,000 coins |

### Meta Achievements

| Achievement | Requirement | Reward |
|-------------|-------------|--------|
| 10 Achievements | Unlock 10 achievements | 2,500 coins |
| 25 Achievements | Unlock 25 achievements | 10,000 coins |
| 50 Achievements | Unlock 50 achievements | 50,000 coins |

---

## Seasonal Events

Blossom hosts limited-time seasonal events with exclusive content and rewards.

### Spring Carnival (April)

A carnival-themed event with exclusive characters, minigames, and treats.

**Event Currency:** Carnival Tickets

**Exclusive Characters:**

| Character | Rarity | Ticket Cost |
|-----------|--------|-------------|
| Rainbow Sparkles | Rare | 800 tickets |
| Toma | Rare | 800 tickets |
| EmieVT | Legendary | 1,500 tickets |
| Necronival | Legendary | 1,500 tickets |
| Umaru Polka | Legendary | 1,500 tickets |

**Carnival Treats:**

| Item | Cost |
|------|------|
| Cotton Candy | 50 tickets |
| Candy Apple | 75 tickets |

**Carnival Achievements:**

| Achievement | Reward |
|-------------|--------|
| Ring Toss | 250 coins |
| Balloon Pop | 250 coins |
| Carnival Snack | 500 coins |
| Carnival Character | 2,000 coins |
| 1K Tickets | 2,500 coins |
| 5K Tickets | 10,000 coins |

Access the event hub using `/event` during the event month.

---

## Items & Black Market

Items can be purchased using `/buy`. Tech upgrades are permanent one-time purchases. Consumables are single-use.

### Tech Upgrades (Permanent)

| Item | Price | Effect |
|------|-------|--------|
| Headset | 500 coins | +25% to `/post` payouts |
| RGB Keyboard | 2,000 coins | +25% to `/work` payouts |
| Studio Mic | 10,000 coins | +10% to `/stream` payouts |
| Holographic Neon Sign | 25,000 coins | &times;2 `/daily` reward |
| Gacha Pass | 15,000 coins | Cuts `/summon` cooldown in half |

### Consumables (Single-Use)

| Item | Price | Effect |
|------|-------|--------|
| Stamina Pill | 1,500 coins | Bypasses `/summon` cooldown once |
| Gamer Fuel | 2,500 coins | Bypasses `/work`, `/stream`, `/post`, or `/collab` cooldown once |
| RNG Manipulator | 5,000 coins | Guarantees Rare+ on next `/summon` |

Consumables can be purchased in bulk. View your inventory from the `/balance` dropdown menu.

---

*Blossom Bot is developed by baonuki. For support, use `/support` to join the official server or `/suggest` to send feedback directly to the developer.*
