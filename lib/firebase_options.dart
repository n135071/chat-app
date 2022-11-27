// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD9WiaiFVcF8n8AZIiKU78tMEjswkbc2YU',
    appId: '1:239309144419:web:541deb76c88193b0285356',
    messagingSenderId: '239309144419',
    projectId: 'firstfire-52bb5',
    authDomain: 'firstfire-52bb5.firebaseapp.com',
    storageBucket: 'firstfire-52bb5.appspot.com',
    measurementId: 'G-00BKQNEHSN',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDZTIXzs0zj365zds2ZhlQkBjSIl0uVlCo',
    appId: '1:239309144419:android:ca4fde5eb38f80e5285356',
    messagingSenderId: '239309144419',
    projectId: 'firstfire-52bb5',
    storageBucket: 'firstfire-52bb5.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBsm9Ua6eu6qvnkn7So3bS80sbIT0bF99Q',
    appId: '1:239309144419:ios:b7b0935c94ebf314285356',
    messagingSenderId: '239309144419',
    projectId: 'firstfire-52bb5',
    storageBucket: 'firstfire-52bb5.appspot.com',
    iosClientId: '239309144419-0tqjq1s4idn1433lnqh4qqanhnjjpg44.apps.googleusercontent.com',
    iosBundleId: 'com.example.fire',
  );
}