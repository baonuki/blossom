# ==========================================
# DATA: Seasonal Events
# DESCRIPTION: Configuration for all seasonal events.
# Events use a shared structure so new holidays can be added easily.
# ==========================================

# --- SPRING CARNIVAL (April) ---
SPRING_CARNIVAL = {
  name: "\u{1F3AA} Spring Carnival",
  month: 4,
  currency: "Carnival Tickets",
  emoji: "\u{1F3AB}\u{FE0F}",
  characters: {
    rare: [
      { name: "Rainbow Sparkles", gif: "https://media.discordapp.net/attachments/1485541740872994817/1485541810142056558/G8_fL5ZXcAAzQud.jfif?ex=69c7841f&is=69c6329f&hm=72fd932bd3d72a4bc340d1c0ed82269272de14c912a79b5a77529e42a330fd68&=&format=webp&width=662&height=856", price: 800 },
      { name: "Toma", gif: "https://media.discordapp.net/attachments/1485541740872994817/1485541811345817692/Toma_by_klaeia.webp?ex=69c7841f&is=69c6329f&hm=175511adab1cc611749ad9714fb8943f96b40098cb5b7518a77b04930282dcf5&=&format=webp&width=558&height=855", price: 800 }
    ],
    legendary: [
      { name: "EmieVT", gif: "https://media.discordapp.net/attachments/1485541740872994817/1485541809185620119/Dndntic_Emie.webp?ex=69c7841f&is=69c6329f&hm=252e2d9e14d82a8606841b4771f3e487ea68ad78ad800c03d0b0341ecc908f60&=&format=webp&width=643&height=856", price: 1500 },
      { name: "Necronival", gif: "https://media.discordapp.net/attachments/1485541740872994817/1485541810540646400/HEDB4i9a8AAGhOp.jfif?ex=69c7841f&is=69c6329f&hm=0e74376569b6db306a39b7a976a75d38f267808ff4136ad2141d7d9567296b08&=&format=webp&width=550&height=855", price: 1500 },
      { name: "Umaru Polka", gif: "https://media.discordapp.net/attachments/1485541740872994817/1485541810989305957/Omaru.Polka.600.3540629.jpg?ex=69c7841f&is=69c6329f&hm=3eea60a55660ce7f31082bcd72931800a3b9461524a68d969b5b72f31e09a3a8&=&format=webp&width=553&height=855", price: 1500 }
    ]
  },
  items: {
    'Cotton Candy' => { price: 50, desc: 'A sweet carnival treat!' },
    'Candy Apple' => { price: 75, desc: 'Crunchy and sweet!' }
  }
}.freeze

# --- SUMMER BEACH PARTY (July) --- PLACEHOLDER: No characters yet
SUMMER_BEACH = {
  name: "\u{1F3D6}\u{FE0F} Summer Beach Party",
  month: 7,
  currency: "Seashells",
  emoji: "\u{1F41A}",
  characters: {
    # Characters will be added when art is ready
    # rare: [ { name: "TBD", gif: "...", price: 800 } ],
    # legendary: [ { name: "TBD", gif: "...", price: 1500 } ]
  },
  items: {
    'Snow Cone' => { price: 50, desc: 'Brain freeze incoming!' },
    'Watermelon Slice' => { price: 75, desc: 'Summer vibes only.' }
  }
}.freeze

# --- HALLOWEEN ARCADE (October) --- PLACEHOLDER: No characters yet
HALLOWEEN_ARCADE = {
  name: "\u{1F383} Halloween Arcade",
  month: 10,
  currency: "Candy Corn",
  emoji: "\u{1F36C}",
  characters: {
    # Characters will be added when art is ready
    # rare: [ { name: "TBD", gif: "...", price: 800 } ],
    # legendary: [ { name: "TBD", gif: "...", price: 1500 } ]
  },
  items: {
    'Pumpkin Latte' => { price: 50, desc: 'Spooky and delicious!' },
    'Witch Cookie' => { price: 75, desc: 'Enchanted with flavor.' }
  }
}.freeze

# --- WINTER WONDERLAND (December) --- PLACEHOLDER: No characters yet
WINTER_WONDERLAND = {
  name: "\u2744\u{FE0F} Winter Wonderland",
  month: 12,
  currency: "Snowflakes",
  emoji: "\u2744\u{FE0F}",
  characters: {
    # Characters will be added when art is ready
    # rare: [ { name: "TBD", gif: "...", price: 800 } ],
    # legendary: [ { name: "TBD", gif: "...", price: 1500 } ]
  },
  items: {
    'Hot Cocoa' => { price: 50, desc: 'Warm and cozy!' },
    'Gingerbread Cookie' => { price: 75, desc: 'Freshly baked with love.' }
  }
}.freeze

# --- MASTER EVENT REGISTRY ---
# Maps months to their event config. The bot checks this to determine the active event.
SEASONAL_EVENTS = {
  4  => SPRING_CARNIVAL,
  7  => SUMMER_BEACH,
  10 => HALLOWEEN_ARCADE,
  12 => WINTER_WONDERLAND
}.freeze

# Helper: Get the currently active seasonal event (nil if none)
def get_active_event
  SEASONAL_EVENTS[Time.now.month]
end

# Helper: Check if a seasonal event is active this month
def event_active?
  !get_active_event.nil?
end

# Helper: Get event characters for the current month (empty hash if no event or no chars)
def get_event_characters
  ev = get_active_event
  return {} unless ev
  ev[:characters] || {}
end

# Helper: Check if an event has characters ready (non-empty pools)
def event_has_characters?
  chars = get_event_characters
  chars.any? { |_rarity, list| list.is_a?(Array) && !list.empty? }
end
