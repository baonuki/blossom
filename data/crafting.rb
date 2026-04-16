# ==========================================
# DATA: Crafting System
# DESCRIPTION: Materials, salvage rates, and crafting recipes.
# ==========================================

# --- MATERIALS ---
# Scrap: from salvaging common cards
# Essence: from salvaging rare+ cards
CRAFTING_MATERIALS = {
  'scrap'   => { name: 'Scrap', emoji: "\u{2699}\u{FE0F}", desc: 'Salvaged from common cards.' },
  'essence' => { name: 'Essence', emoji: "\u{1F48E}", desc: 'Extracted from rare and above cards.' }
}.freeze

# --- SALVAGE RATES ---
# How many materials you get per card rarity when salvaging
SALVAGE_RATES = {
  'common'    => { 'scrap' => 1 },
  'rare'      => { 'essence' => 2 },
  'legendary' => { 'essence' => 5 },
  'goddess'   => { 'essence' => 10 }
}.freeze

# --- CRAFTING RECIPES ---
# Each recipe: type (badge/title/theme/pet), materials needed, coin cost, result ID
CRAFTING_RECIPES = {
  # Badges (craftable-exclusive)
  'craftsman' => {
    name: 'Craftsman Badge', type: 'badge', desc: 'Awarded to those who forge their own path.',
    materials: { 'scrap' => 10 }, cost: 500,
    result_id: 'craftsman'
  },
  'forgemaster' => {
    name: 'Forgemaster Badge', type: 'badge', desc: 'Master of the forge.',
    materials: { 'essence' => 5 }, cost: 2000,
    result_id: 'forgemaster'
  },
  'scrap_king' => {
    name: 'Scrap King Badge', type: 'badge', desc: 'Built an empire from scraps.',
    materials: { 'scrap' => 50 }, cost: 1000,
    result_id: 'scrap_king'
  },

  # Titles (craftable-exclusive)
  'tinkerer' => {
    name: 'Tinkerer Title', type: 'title', desc: 'A tinkerer by trade.',
    materials: { 'scrap' => 15 }, cost: 500,
    result_id: 'tinkerer'
  },
  'engineer' => {
    name: 'Engineer Title', type: 'title', desc: 'Engineering excellence.',
    materials: { 'essence' => 10 }, cost: 3000,
    result_id: 'engineer'
  },
  'scrapyard_boss' => {
    name: 'Scrapyard Boss Title', type: 'title', desc: 'Ruler of the junkyard.',
    materials: { 'scrap' => 30, 'essence' => 3 }, cost: 1500,
    result_id: 'scrapyard_boss'
  },

  # Themes (craftable-exclusive)
  'forge' => {
    name: 'Forge Theme', type: 'theme', desc: 'Molten metal and sparks.',
    materials: { 'scrap' => 20, 'essence' => 5 }, cost: 2000,
    result_id: 'forge'
  },
  'circuit' => {
    name: 'Circuit Theme', type: 'theme', desc: 'Digital circuitry aesthetic.',
    materials: { 'scrap' => 30 }, cost: 3000,
    result_id: 'circuit'
  },

  # Pets (craftable-exclusive)
  'scrap_golem' => {
    name: 'Scrap Golem Pet', type: 'pet', desc: 'A clunky but lovable construct.',
    materials: { 'scrap' => 25, 'essence' => 10 }, cost: 5000,
    result_id: 'scrap_golem'
  },
  'spark_wisp' => {
    name: 'Spark Wisp Pet', type: 'pet', desc: 'A tiny dancing flame of pure energy.',
    materials: { 'essence' => 15 }, cost: 3000,
    result_id: 'spark_wisp'
  }
}.freeze
