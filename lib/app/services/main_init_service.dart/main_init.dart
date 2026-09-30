import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:api_scout/firebase_options.dart';
import '../local_db/hive/initializer.dart';
import '../auth/auth_token_service.dart';
import '../auth/dio_client.dart';
import '../analytics/posthog_service.dart';
import '../notification/fcm_service.dart';

class MainInit {
  static const bool resetLocalDataOnStartup = false;

  Future<void> init({bool testMode = false}) async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize local databases
    await LocalDatabase.instance.initDatabases();

    // Initialize auth token service
    await AuthTokenService().init();

    if (resetLocalDataOnStartup) {
      await LocalDatabase.instance.clearAllLocalData();
    }

    // Initialize Dio client
    DioClient();

    // Initialize PostHog mobile telemetry (no-op without token)
    await PostHogService.instance.init();

    // Initialize FCM service
    await FcmService().init();
  }
}
