import 'package:api_scout/config/routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseNotificationAction', () {
    test('api types with slug route to detail', () {
      for (final type in [
        'api_health',
        'new_api',
        'price_change',
        'trust_alert'
      ]) {
        final action = parseNotificationAction({
          'type': type,
          'apiSlug': 'resend',
        });
        expect(action.kind, NotificationKind.apiDetail);
        expect(action.slug, 'resend');
      }
    });

    test('price and trust arm alerts, trust is urgent', () {
      final price = parseNotificationAction(
          {'type': 'price_change', 'apiSlug': 'resend'});
      expect(price.alert, isTrue);
      expect(price.urgent, isFalse);

      final trust =
          parseNotificationAction({'type': 'trust_alert', 'apiSlug': 'resend'});
      expect(trust.alert, isTrue);
      expect(trust.urgent, isTrue);

      final health =
          parseNotificationAction({'type': 'api_health', 'apiSlug': 'resend'});
      expect(health.alert, isFalse);
    });

    test('api type without slug falls back to feed', () {
      final action = parseNotificationAction({'type': 'new_api'});
      expect(action.kind, NotificationKind.feed);
      expect(action.alert, isFalse);
    });

    test('digest with 2+ ids routes to compare', () {
      final action = parseNotificationAction({
        'type': 'weekly_digest',
        'apiIds': '["a", "b", "c"]',
      });
      expect(action.kind, NotificationKind.compare);
      expect(action.apiIds, ['a', 'b', 'c']);
      expect(action.alert, isTrue);
    });

    test('digest with fewer than 2 ids routes to recommended', () {
      final action = parseNotificationAction({
        'type': 'weekly_digest',
        'apiIds': '["only-one"]',
      });
      expect(action.kind, NotificationKind.recommended);
    });

    test('digest without ids routes to recommended', () {
      final action = parseNotificationAction({'type': 'weekly_digest'});
      expect(action.kind, NotificationKind.recommended);
    });

    test('community reminders map actions', () {
      expect(
        parseNotificationAction(
            {'type': 'community_reminder', 'action': 'submit_api'}).kind,
        NotificationKind.submitApi,
      );
      expect(
        parseNotificationAction(
            {'type': 'community_reminder', 'action': 'browse_apis'}).kind,
        NotificationKind.exploreTab,
      );
      expect(
        parseNotificationAction(
            {'type': 'community_reminder', 'action': 'report_api'}).kind,
        NotificationKind.homeTab,
      );
    });

    test('lifecycle updates route to feed with alert', () {
      for (final type in ['report_update', 'submission_update']) {
        final action = parseNotificationAction({'type': type});
        expect(action.kind, NotificationKind.feed);
        expect(action.alert, isTrue);
      }
    });

    test('lifecycle updates with apiSlug deep-link to detail', () {
      for (final type in ['report_update', 'submission_update']) {
        final action = parseNotificationAction({
          'type': type,
          'apiSlug': 'resend',
        });
        expect(action.kind, NotificationKind.apiDetail);
        expect(action.slug, 'resend');
        expect(action.alert, isTrue);
      }
    });

    test('unknown and empty payloads route to feed silently', () {
      expect(parseNotificationAction({}).kind, NotificationKind.feed);
      expect(parseNotificationAction({}).alert, isFalse);
      expect(parseNotificationAction({'type': 'nope'}).kind,
          NotificationKind.feed);
    });
  });

  group('parseNotificationIds', () {
    test('parses JSON arrays, lists, and csv strings', () {
      expect(parseNotificationIds('["a","b"]'), ['a', 'b']);
      expect(parseNotificationIds(['a', 'b']), ['a', 'b']);
      expect(parseNotificationIds('a,b'), ['a', 'b']);
    });

    test('drops blanks and handles garbage', () {
      expect(parseNotificationIds('["a", "", 1]'), ['a', '1']);
      expect(parseNotificationIds('not json ['), ['not json [']);
      expect(parseNotificationIds(null), isEmpty);
      expect(parseNotificationIds(42), isEmpty);
    });
  });

  group('notificationRoutingProperties', () {
    test('records a routed API target without notification content', () {
      final data = {
        'type': 'new_api',
        'apiSlug': 'resend',
        'title': 'private title',
      };
      final properties = notificationRoutingProperties(
        data,
        parseNotificationAction(data),
        'routed',
      );

      expect(properties, {
        'notification_type': 'new_api',
        'destination_kind': 'apiDetail',
        'target_present': true,
        'fallback_reason': 'none',
        'routing_result': 'routed',
      });
      expect(properties, isNot(contains('title')));
    });

    test('explains privacy-safe fallback reasons', () {
      final missingSlug = {'type': 'trust_alert'};
      expect(
        notificationRoutingProperties(
          missingSlug,
          parseNotificationAction(missingSlug),
          'routed',
        )['fallback_reason'],
        'missing_api_slug',
      );

      final unknown = {'type': 'custom_private_type'};
      final properties = notificationRoutingProperties(
        unknown,
        parseNotificationAction(unknown),
        'routed',
      );
      expect(properties['notification_type'], 'unknown');
      expect(properties['fallback_reason'], 'unknown_type');
    });
  });
}
