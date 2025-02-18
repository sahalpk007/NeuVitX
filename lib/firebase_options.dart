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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAOtSkSbVHqpQ6MrvxBkNdkPJh9Z0AmeMY',
    appId: '1:348473160163:web:d8b81018b9794e39b870d6',
    messagingSenderId: '348473160163',
    projectId: 'neuvitx',
    authDomain: 'neuvitx.firebaseapp.com',
    databaseURL: 'https://neuvitx-default-rtdb.firebaseio.com',
    storageBucket: 'neuvitx.appspot.com',
    measurementId: 'G-M1EKW1E3LN',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBN84n6sOmCkvBteHkiMaHuEPvlkllgK2U',
    appId: '1:348473160163:android:12c6acb64bc26f7cb870d6',
    messagingSenderId: '348473160163',
    projectId: 'neuvitx',
    databaseURL: 'https://neuvitx-default-rtdb.firebaseio.com',
    storageBucket: 'neuvitx.appspot.com',
  );
}
