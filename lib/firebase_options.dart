// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static FirebaseOptions get web {
    final env = dotenv.env;
    return FirebaseOptions(
      apiKey: env['web_api_key'] ?? '',
      appId: env['web_app_id'] ?? '',
      messagingSenderId: env['web_messaging_sender_id'] ?? '',
      projectId: env['web_project_id'] ?? '',
      authDomain: env['web_auth_domain'] ?? '',
      storageBucket: env['web_storage_bucket'] ?? '',
      measurementId: env['web_measurement_id'] ?? '',
    );
  }

  static FirebaseOptions get android {
    final env = dotenv.env;
    return FirebaseOptions(
      apiKey: env['android_api_key'] ?? '',
      appId: env['android_app_id'] ?? '',
      messagingSenderId: env['android_messaging_sender_id'] ?? '',
      projectId: env['android_project_id'] ?? '',
      storageBucket: env['android_storage_bucket'] ?? '',
    );
  }

  static FirebaseOptions get ios {
    final env = dotenv.env;
    return FirebaseOptions(
      apiKey: env['ios_api_key'] ?? '',
      appId: env['ios_app_id'] ?? '',
      messagingSenderId: env['ios_messaging_sender_id'] ?? '',
      projectId: env['ios_project_id'] ?? '',
      storageBucket: env['ios_storage_bucket'] ?? '',
      iosBundleId: env['ios_bundle_id'] ?? '',
    );
  }

  static FirebaseOptions get macos {
    final env = dotenv.env;
    return FirebaseOptions(
      apiKey: env['macos_api_key'] ?? '',
      appId: env['macos_app_id'] ?? '',
      messagingSenderId: env['macos_messaging_sender_id'] ?? '',
      projectId: env['macos_project_id'] ?? '',
      storageBucket: env['macos_storage_bucket'] ?? '',
      iosBundleId: env['macos_bundle_id'] ?? '',
    );
  }

  static FirebaseOptions get windows {
    final env = dotenv.env;
    return FirebaseOptions(
      apiKey: env['windows_api_key'] ?? '',
      appId: env['windows_app_id'] ?? '',
      messagingSenderId: env['windows_messaging_sender_id'] ?? '',
      projectId: env['windows_project_id'] ?? '',
      storageBucket: env['windows_storage_bucket'] ?? '',
    );
  }
}