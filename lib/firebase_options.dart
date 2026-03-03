// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: 'YOUR_WEB_API_KEY',
        authDomain: 'werun-ff746.firebaseapp.com',
        projectId: 'werun-ff746',
        storageBucket: 'werun-ff746.appspot.com',
        messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
        appId: 'YOUR_WEB_APP_ID',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return const FirebaseOptions(
          apiKey: 'YOUR_ANDROID_API_KEY',
          appId: 'YOUR_ANDROID_APP_ID',
          messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
          projectId: 'werun-ff746',
          storageBucket: 'werun-ff746.appspot.com',
        );
      case TargetPlatform.iOS:
        return const FirebaseOptions(
          apiKey: 'YOUR_IOS_API_KEY',
          appId: 'YOUR_IOS_APP_ID',
          messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
          projectId: 'werun-ff746',
          storageBucket: 'werun-ff746.appspot.com',
          iosBundleId: 'com.example.werun',
        );
      default:
        throw UnsupportedError('DefaultFirebaseOptions not implemented for this platform.');
    }
  }
}