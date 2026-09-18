import 'package:flutter_test/flutter_test.dart';
import 'package:api_scout/app/data/models/submission.dart';

void main() {
  group('SubmissionItem', () {
    test('parses approved row with routable API slug', () {
      final item = SubmissionItem.fromJson({
        'submissionId': 'abc123',
        'name': 'Resend',
        'link': 'https://resend.com',
        'status': 'approved',
        'rejectionReason': null,
        'reviewedAt': '2026-01-02T03:04:05.000Z',
        'submittedAt': '2026-01-01T00:00:00.000Z',
        'api': {'id': 'uuid-1', 'slug': 'resend', 'name': 'Resend'},
      });
      expect(item.routableSlug, 'resend');
      expect(item.displayTitle(), 'Resend');
      expect(item.submittedAt, isNotNull);
    });

    test('pending row has no slug and falls back to link title', () {
      final item = SubmissionItem.fromJson({
        'submissionId': 'def456',
        'name': '',
        'link': 'https://example.com',
        'status': 'pending',
        'api': null,
      });
      expect(item.routableSlug, isNull);
      expect(item.displayTitle(), 'https://example.com');
    });

    test('survives missing fields without throwing', () {
      final item = SubmissionItem.fromJson({});
      expect(item.submissionId, isEmpty);
      expect(item.status, 'pending');
      expect(item.routableSlug, isNull);
      expect(item.displayTitle(), 'Unknown');
    });
  });
}
