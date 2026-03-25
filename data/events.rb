# ==========================================
# DATA: Seasonal Events
# DESCRIPTION: Configuration for the Spring Carnival.
# ==========================================

SPRING_CARNIVAL = {
  name: "🎪 Spring Carnival",
  month: 4,
  currency: "Carnival Tickets",
  emoji: "🎟️",
  characters: {
    rare: [
      { name: "Rainbow Sparkles", gif: "https://url_here", price: 800 },
      { name: "Toma", gif: "https://url_here", price: 800 }
    ],
    legendary: [
      { name: "EmieVT", gif: "https://url_here", price: 1500 },
      { name: "Necronival", gif: "https://url_here", price: 1500 },
      { name: "Umaru Polka", gif: "https://url_here", price: 1500 }
    ]
  },
  items: {
    'Cotton Candy' => { price: 50, desc: 'A sweet carnival treat!' },
    'Candy Apple' => { price: 75, desc: 'Crunchy and sweet!' }
  }
}.freeze