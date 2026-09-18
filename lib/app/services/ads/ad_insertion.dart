/// Deterministic native-ad insertion policy for browse result lists.
///
/// First ad after the 8th organic item, subsequent ads every 12 organic
/// items, at most two ads per loaded result set. Positions stay stable as
/// pagination grows (thresholds are absolute organic counts, not windows).
/// Organic indexes, keys, scroll position, and empty/error/loading states
/// are unaffected: the policy only maps combined-list slots.
class AdInsertion {
  AdInsertion._();

  /// Organic items before the first ad.
  static const int firstAfter = 8;

  /// Organic items between ads.
  static const int every = 12;

  /// Maximum ads per loaded result set.
  static const int maxAds = 2;

  /// Organic thresholds (1-based counts) after which an ad is inserted.
  static List<int> _thresholds(int organicCount) {
    final thresholds = <int>[];
    var next = firstAfter;
    while (thresholds.length < maxAds && organicCount >= next) {
      thresholds.add(next);
      next += every;
    }
    return thresholds;
  }

  /// Combined-list slot indexes holding ads for [organicCount] items.
  static List<int> adPositions(int organicCount) {
    final positions = <int>[];
    final thresholds = _thresholds(organicCount);
    for (var i = 0; i < thresholds.length; i++) {
      positions.add(thresholds[i] + i);
    }
    return positions;
  }

  /// Total combined slots (organic items + ads).
  static int slotCount(int organicCount) =>
      organicCount + adPositions(organicCount).length;

  /// True when combined [slot] holds an ad.
  static bool isAdSlot(int slot, int organicCount) =>
      adPositions(organicCount).contains(slot);

  /// Organic index for a combined [slot], or -1 when the slot holds an ad.
  static int organicIndexForSlot(int slot, int organicCount) {
    var adsBefore = 0;
    for (final position in adPositions(organicCount)) {
      if (position < slot) {
        adsBefore++;
      } else if (position == slot) {
        return -1;
      }
    }
    return slot - adsBefore;
  }
}
