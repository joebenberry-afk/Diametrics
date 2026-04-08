/// Caribbean / Trinidad & Tobago Regional Food Heuristics
///
/// Adjusts the glucose prediction engine's absorption parameters for
/// common Caribbean staple foods whose glycemic response differs
/// significantly from the USDA-standard Western equivalents.
///
/// This module is entirely backend — no UI interaction required. The
/// heuristics are applied automatically when a food name matches a
/// known regional pattern.
///
/// Reference: Caribbean Food and Nutrition Institute (CFNI) glycemic
/// index tables; UWI St. Augustine Nutrition Research Unit estimates.
class CaribbeanFoodHeuristics {
  CaribbeanFoodHeuristics._();

  /// Returns a tMax multiplier for known Caribbean staple foods.
  ///
  /// - `1.0`  = no adjustment (unknown food)
  /// - `>1.0` = slower absorption (e.g. ground provisions with resistant starch)
  /// - `<1.0` = faster absorption (e.g. fried processed dough, sugary drinks)
  ///
  /// The multiplier is applied to the base `tMax` before the gamma kernel
  /// is computed, shifting the peak absorption time earlier or later.
  static double getRegionalAbsorptionMultiplier(String? foodName) {
    if (foodName == null || foodName.isEmpty) return 1.0;
    final name = foodName.toLowerCase().trim();

    for (final entry in _absorptionTable.entries) {
      if (name.contains(entry.key)) return entry.value;
    }
    return 1.0;
  }

  /// Returns a TAG scaling factor for foods with known GI differences
  /// from USDA-standard equivalents.
  ///
  /// - `1.0`  = no adjustment
  /// - `>1.0` = higher effective glycemic load than macros suggest
  /// - `<1.0` = lower effective glycemic load (resistant starch, etc.)
  static double getRegionalTagMultiplier(String? foodName) {
    if (foodName == null || foodName.isEmpty) return 1.0;
    final name = foodName.toLowerCase().trim();

    for (final entry in _tagTable.entries) {
      if (name.contains(entry.key)) return entry.value;
    }
    return 1.0;
  }

  // ── Absorption Delay Table ──────────────────────────────────────────────
  // Keys are lowercase substrings matched against the meal name.
  // Values are multipliers on tMax.

  static const Map<String, double> _absorptionTable = {
    // Ground provisions — high resistant starch, slower absorption
    'dasheen': 1.30,
    'taro': 1.30,
    'yam': 1.25,
    'cassava': 1.25,
    'eddoe': 1.25,
    'green banana': 1.30,
    'green fig': 1.30, // local name for green banana
    'breadfruit': 1.20,
    'plantain': 1.15,

    // Roti family — layered dough with fat, slows gastric emptying
    'roti': 1.25,
    'paratha': 1.25,
    'bust-up-shut': 1.25,
    'bust up shut': 1.25,
    'dhalpuri': 1.20,
    'dhal puri': 1.20,
    'sada': 1.10,

    // Fried / processed items — faster absorption
    'doubles': 0.90,
    'bara': 0.90,
    'pholourie': 0.85,
    'aloo pie': 0.90,
    'saheena': 0.90,
    'accra': 0.85,

    // Bake varieties
    'coconut bake': 1.15,
    'fry bake': 0.90,
    'roast bake': 1.05,
    'bake and shark': 1.10,
    'bake and buljol': 1.10,

    // Rice dishes — mixed meals with legumes
    'pelau': 1.20,
    'cook-up rice': 1.15,
    'cook up rice': 1.15,
    'dhal rice': 1.15,
    'curry rice': 1.10,

    // Pasta / baked starch
    'macaroni pie': 1.15,
    'mac pie': 1.15,
    'pastelle': 1.10,

    // Beverages — liquid = fast
    'sorrel': 0.75,
    'mauby': 0.80,
    'punch de creme': 0.70,
    'seamoss': 0.75,
    'peanut punch': 0.80,

    // Snacks / processed
    'crix': 0.85,
    'kurma': 0.85,
    'toolum': 0.80,
    'tamarind ball': 0.80,
    'sugar cake': 0.75,
    'red mango': 0.85,

    // Callaloo-based (high fiber context)
    'callaloo': 1.25,
    'provision': 1.25,
  };

  // ── TAG Multiplier Table ────────────────────────────────────────────────
  // Adjusts the effective glycemic load relative to what USDA macros predict.

  static const Map<String, double> _tagTable = {
    // Lower effective GI than USDA equivalents
    'dasheen': 0.85,
    'taro': 0.85,
    'yam': 0.90,
    'cassava': 0.90,
    'green banana': 0.80,
    'green fig': 0.80,
    'breadfruit': 0.85,
    'plantain': 0.95,

    // Higher effective GI (processed / fried)
    'doubles': 1.10,
    'pholourie': 1.10,
    'crix': 1.10,
    'sorrel': 1.15,
    'sugar cake': 1.20,
    'kurma': 1.10,
    'fry bake': 1.05,

    // Neutral
    'roti': 1.0,
    'pelau': 1.0,
    'macaroni pie': 1.05,
    'bake and shark': 1.0,
    'callaloo': 0.90,
  };
}
