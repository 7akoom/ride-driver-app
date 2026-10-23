import 'package:firebase_core/firebase_core.dart';

/// Starts Firebase for push notifications when the app opens.
///
/// Firebase reads its settings from android/app/google-services.json (each investor
/// build ships its own, matching that build's applicationId) and, on iOS, from
/// GoogleService-Info.plist. A build without them still opens: the error is caught in
/// bootstrap and the phone simply gets no push token.
///
/// Registering the phone with the backend is the push feature's job
/// (features/push, PushRegistrar), once the captain is signed in.
class PushNotifications {
  static Future<void> initialize() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  }
}
