# ==========================================
# DATA: Trivia Question Generator
# DESCRIPTION: Auto-generates VTuber-themed trivia from character pools.
# ==========================================

# Fake VTuber names for "odd one out" questions
FAKE_VTUBERS = [
  "Starlight Miku", "NeonByte", "PixelPrincess", "CyberFoxie", "GlitchQueen",
  "HoloNova", "VirtuaLuna", "NightShade", "BitStorm", "ArcadeSprite",
  "CosmicKitty", "NeonDrift", "DigitalRose", "StaticSoul", "ByteBloom",
  "ChromaWitch", "PixelPhantom", "LaserLily", "CodexDawn", "VoidViolet"
].freeze

# Hardcoded general VTuber knowledge questions
GENERAL_TRIVIA = [
  { q: "What does 'VTuber' stand for?", correct: "Virtual YouTuber", wrong: ["Video Tuber", "Visual Tuber", "Viral Tuber"] },
  { q: "Which VTuber agency is Ironmouse a member of?", correct: "VShojo", wrong: ["Hololive", "Nijisanji", "Phase Connect"] },
  { q: "What is Blossom's role in the Neon Arcade?", correct: "Self-proclaimed Manager", wrong: ["Janitor", "Security Guard", "DJ"] },
  { q: "What currency do premium users earn from daily claims?", correct: "Prisma", wrong: ["Gems", "Tokens", "Stars"] },
  { q: "How many copies of a card are needed to Ascend it?", correct: "5", wrong: ["3", "7", "10"] },
  { q: "What is the rarest card tier in Blossom's gacha?", correct: "Goddess", wrong: ["Legendary", "Mythic", "Ultimate"] },
  { q: "What is Blossom's hair color?", correct: "Hot pink with neon blue streaks", wrong: ["Blonde", "Purple", "Silver with red tips"] },
  { q: "What happens after 30 gacha pulls without a rare or better?", correct: "Pity system guarantees one", wrong: ["You get a refund", "Nothing", "Cooldown resets"] },
  { q: "Which item doubles your daily reward?", correct: "Holographic Neon Sign", wrong: ["RGB Keyboard", "Studio Mic", "Gacha Pass"] },
  { q: "What is the base cost of a gacha summon?", correct: "150 coins", wrong: ["100 coins", "200 coins", "250 coins"] },
  { q: "How long is the daily reward cooldown?", correct: "24 hours", wrong: ["12 hours", "18 hours", "48 hours"] },
  { q: "What bonus do married users get on their daily?", correct: "+50 coins", wrong: ["+25 coins", "+100 coins", "+75 coins"] },
  { q: "What is the maximum daily streak achievement?", correct: "365 days", wrong: ["100 days", "200 days", "500 days"] },
  { q: "Which VTuber is known as 'The Genius'?", correct: "Henya the Genius", wrong: ["Ironmouse", "Nyanners", "Filian"] },
  { q: "What does the Stamina Pill consumable do?", correct: "Bypasses summon cooldown", wrong: ["Doubles XP gain", "Gives free coins", "Guarantees rare pull"] },
  { q: "What does the RNG Manipulator guarantee?", correct: "Rare or higher on next summon", wrong: ["Goddess pull", "Legendary pull", "Double coins"] },
].freeze

# Build a flat list of all characters with their rarity for auto-generated questions
def build_character_index
  index = []
  CHARACTER_POOLS.each do |_pool_key, pool|
    pool[:characters].each do |rarity, chars|
      chars.each { |c| index << { name: c[:name], rarity: rarity.to_s } }
    end
  end
  # Add event characters
  SPRING_CARNIVAL[:characters].each do |rarity, chars|
    chars.each { |c| index << { name: c[:name], rarity: rarity.to_s, event: true } }
  end
  index
end

def generate_trivia_question
  char_index = build_character_index
  type = rand(5)

  case type
  when 0
    # Rarity quiz: "What rarity is [Character]?"
    char = char_index.sample
    correct = char[:rarity].capitalize
    wrong = %w[Common Rare Legendary Goddess].reject { |r| r == correct }.sample(3)
    { question: "What rarity tier is **#{char[:name]}** in?", correct: correct, options: ([correct] + wrong).shuffle }

  when 1
    # Which is rarer: pick 4 chars of different rarities
    rarities = %w[common rare legendary goddess]
    picks = []
    rarities.each do |r|
      candidates = char_index.select { |c| c[:rarity] == r }
      picks << candidates.sample if candidates.any?
    end
    if picks.size >= 2
      highest = picks.max_by { |c| rarities.index(c[:rarity]) }
      { question: "Which of these VTubers has the **highest** rarity?", correct: highest[:name], options: picks.map { |p| p[:name] }.shuffle }
    else
      generate_general_question
    end

  when 2
    # Odd one out: 3 real + 1 fake
    real_chars = char_index.sample(3).map { |c| c[:name] }
    fake = FAKE_VTUBERS.reject { |f| char_index.any? { |c| c[:name] == f } }.sample
    { question: "Which of these is **NOT** a VTuber in the Neon Arcade collection?", correct: fake, options: (real_chars + [fake]).shuffle }

  when 3
    # Reverse: given rarity, which char is in it?
    target_rarity = %w[common rare legendary goddess].sample
    correct_chars = char_index.select { |c| c[:rarity] == target_rarity }
    wrong_chars = char_index.reject { |c| c[:rarity] == target_rarity }
    if correct_chars.any? && wrong_chars.size >= 3
      correct = correct_chars.sample
      wrong = wrong_chars.sample(3)
      { question: "Which of these VTubers is in the **#{target_rarity.capitalize}** tier?", correct: correct[:name], options: ([correct[:name]] + wrong.map { |w| w[:name] }).shuffle }
    else
      generate_general_question
    end

  else
    generate_general_question
  end
end

def generate_general_question
  q = GENERAL_TRIVIA.sample
  options = ([q[:correct]] + q[:wrong]).shuffle
  { question: q[:q], correct: q[:correct], options: options }
end
