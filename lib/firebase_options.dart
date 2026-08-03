import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDVR1WWT6U_FawbTsrNUl_klzIG_ZM9hcg',
    appId: '1:74408620937:android:ed4d1e4735b18111ece758',
    messagingSenderId: '74408620937',
    projectId: 'public-apis-gwhyy',
    storageBucket: 'public-apis-gwhyy.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBpE3x9GQmZlKJh4oE2cN8vR5wY6xT7uZ8',
    appId: '1:74408620937:ios:YOUR_IOS_APP_ID',
    messagingSenderId: '74408620937',
    projectId: 'public-apis-gwhyy',
    storageBucket: 'public-apis-gwhyy.firebasestorage.app',
    iosBundleId: 'com.gwhyyy.publicApisDesktopClient',
  );
}
