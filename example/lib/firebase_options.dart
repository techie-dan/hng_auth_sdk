import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

import 'firebase_secrets.dart';

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
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'DUMMY_ANDROID_API_KEY',
    appId: 'DUMMY_ANDROID_APP_ID',
    messagingSenderId: 'DUMMY_ANDROID_MESSAGING_SENDER_ID',
    projectId: 'DUMMY_ANDROID_PROJECT_ID',
    storageBucket: 'DUMMY_ANDROID_STORAGE_BUCKET',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: FirebaseSecrets.iosApiKey,
    appId: FirebaseSecrets.iosAppId,
    messagingSenderId: FirebaseSecrets.iosMessagingSenderId,
    projectId: FirebaseSecrets.iosProjectId,
    storageBucket: FirebaseSecrets.iosStorageBucket,
    iosBundleId: FirebaseSecrets.iosBundleId,
  );
}
