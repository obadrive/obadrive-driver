import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
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
//api key
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAlr1yhXQkzC49cLhB7xC8SValIINAI28E',
    appId: '1:476856846993:android:82552b9ed552f644fb0d30',
    messagingSenderId: '476856846993',
    projectId: 'obadrive-102a6',
    storageBucket: 'obadrive-102a6.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBbHWxCqp13mR43bfUeyvhqF-kTvuRBp0I',
    appId: '1:476856846993:ios:2279796e4b105b13fb0d30',
    messagingSenderId: '476856846993',
    projectId: 'obadrive-102a6',
    storageBucket: 'obadrive-102a6.firebasestorage.app',
    iosBundleId: 'com.ovosolution.ovoridedriver',
  );

}