import 'package:api_scout/app/services/in_app_review/in_app_review.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 9, 6);

  group('InAppReview.shouldPromptForReview', () {

    test('needs at least three wins', () {
      expect(
        InAppReview.shouldPromptForReview(
          wins: 2,
          firstWinAt: now.subtract(const Duration(days: 10)),
          lastPromptedAt: null,
          now: now,
        ),
        isFalse,
      );
    });

    test('needs a few days since the first win', () {
      expect(
        InAppReview.shouldPromptForReview(
          wins: 5,
          firstWinAt: now.subtract(const Duration(days: 1)),
          lastPromptedAt: null,
          now: now,
        ),
        isFalse,
      );
    });

    test('prompts once seasoned with enough wins', () {
      expect(
        InAppReview.shouldPromptForReview(
          wins: 3,
          firstWinAt: now.subtract(const Duration(days: 3)),
          lastPromptedAt: null,
          now: now,
        ),
        isTrue,
      );
    });

    test('respects the cooldown after a prompt', () {
      expect(
        InAppReview.shouldPromptForReview(
          wins: 30,
          firstWinAt: now.subtract(const Duration(days: 200)),
          lastPromptedAt: now.subtract(const Duration(days: 10)),
          now: now,
        ),
        isFalse,
      );
      expect(
        InAppReview.shouldPromptForReview(
          wins: 30,
          firstWinAt: now.subtract(const Duration(days: 200)),
          lastPromptedAt: now.subtract(const Duration(days: 90)),
          now: now,
        ),
        isTrue,
      );
    });

    test('never prompts without a first win timestamp', () {
      expect(
        InAppReview.shouldPromptForReview(
          wins: 99,
          firstWinAt: null,
          lastPromptedAt: null,
          now: now,
        ),
        isFalse,
      );
    });
  });

  group('InAppReview.shouldPromptForDetailVisits', () {
    test('needs at least three detail visits', () {
      expect(
        InAppReview.shouldPromptForDetailVisits(
          visits: 2,
          lastPromptedAt: null,
          now: now,
        ),
        isFalse,
      );
      expect(
        InAppReview.shouldPromptForDetailVisits(
          visits: 3,
          lastPromptedAt: null,
          now: now,
        ),
        isTrue,
      );
    });

    test('respects the shared cooldown after a prompt', () {
      expect(
        InAppReview.shouldPromptForDetailVisits(
          visits: 30,
          lastPromptedAt: now.subtract(const Duration(days: 10)),
          now: now,
        ),
        isFalse,
      );
      expect(
        InAppReview.shouldPromptForDetailVisits(
          visits: 30,
          lastPromptedAt: now.subtract(const Duration(days: 90)),
          now: now,
        ),
        isTrue,
      );
    });
  });
}
