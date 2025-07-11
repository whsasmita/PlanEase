// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyAsrsUmlcamO9owftfuF2q2qKyNBMFVz2o',
    appId: '1:66083164308:web:504839262a29afdb74a481',
    messagingSenderId: '66083164308',
    projectId: 'notifplanease',
    authDomain: 'notifplanease.firebaseapp.com',
    storageBucket: 'notifplanease.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDzs619Ti4d0e6qI06N4XPkuX2rM6wpoT8',
    appId: '1:66083164308:android:21237ad9c754e89f74a481',
    messagingSenderId: '66083164308',
    projectId: 'notifplanease',
    storageBucket: 'notifplanease.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAqJ2fJppe6qRyXU7oA_ZdLLWmosu3H6N4',
    appId: '1:66083164308:ios:3139d0890b3ec2d074a481',
    messagingSenderId: '66083164308',
    projectId: 'notifplanease',
    storageBucket: 'notifplanease.firebasestorage.app',
    iosBundleId: 'com.example.planEase',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAqJ2fJppe6qRyXU7oA_ZdLLWmosu3H6N4',
    appId: '1:66083164308:ios:3139d0890b3ec2d074a481',
    messagingSenderId: '66083164308',
    projectId: 'notifplanease',
    storageBucket: 'notifplanease.firebasestorage.app',
    iosBundleId: 'com.example.planEase',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAsrsUmlcamO9owftfuF2q2qKyNBMFVz2o',
    appId: '1:66083164308:web:ff6dbb5ac8e5aa0a74a481',
    messagingSenderId: '66083164308',
    projectId: 'notifplanease',
    authDomain: 'notifplanease.firebaseapp.com',
    storageBucket: 'notifplanease.firebasestorage.app',
  );
}
