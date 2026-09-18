import 'package:api_scout/app/services/ads/ad_insertion.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdInsertion', () {
    test('no ads for short lists', () {
      expect(AdInsertion.adPositions(0), isEmpty);
      expect(AdInsertion.adPositions(7), isEmpty);
      expect(AdInsertion.slotCount(0), 0);
      expect(AdInsertion.slotCount(7), 7);
    });

    test('one ad after the 8th organic item', () {
      expect(AdInsertion.adPositions(8), [8]);
      expect(AdInsertion.slotCount(8), 9);
      expect(AdInsertion.isAdSlot(8, 8), isTrue);
      expect(AdInsertion.isAdSlot(7, 8), isFalse);
    });

    test('two ads max: after organic 8 and 20', () {
      expect(AdInsertion.adPositions(20), [8, 21]);
      expect(AdInsertion.slotCount(20), 22);
      // Second ad needs 20 organic items; 19 keeps one ad.
      expect(AdInsertion.adPositions(19), [8]);
    });

    test('large lists keep exactly two ads at stable positions', () {
      expect(AdInsertion.adPositions(200), [8, 21]);
      expect(AdInsertion.slotCount(200), 202);
    });

    test('slot maps back to organic indexes around ads', () {
      expect(AdInsertion.organicIndexForSlot(7, 20), 7);
      expect(AdInsertion.organicIndexForSlot(8, 20), -1);
      expect(AdInsertion.organicIndexForSlot(9, 20), 8);
      expect(AdInsertion.organicIndexForSlot(20, 20), 19);
      expect(AdInsertion.organicIndexForSlot(21, 20), -1);
    });
  });
}
