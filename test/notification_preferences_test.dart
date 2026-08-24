import 'package:api_scout/app/services/notification/fcm_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('notification preferences parse every server control', () {
    final preferences = NotificationPreferences.fromJson({
      'savedApiHealth': false,
      'newMatchingApis': true,
      'weeklyDigest': false,
      'lifecycleUpdates': true,
      'pricingChanges': false,
      'trustAlerts': true,
    });

    expect(preferences.savedApiHealth, isFalse);
    expect(preferences.newMatchingApis, isTrue);
    expect(preferences.weeklyDigest, isFalse);
    expect(preferences.lifecycleUpdates, isTrue);
    expect(preferences.pricingChanges, isFalse);
    expect(preferences.trustAlerts, isTrue);
  });
}
