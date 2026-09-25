import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

abstract class FirebaseNotifyService {
  Future<void> initFirebase();
  Future<String?> getDeviceToken();
}

class FirebaseNotifyServiceImpl implements FirebaseNotifyService {
  @override
  Future<void> initFirebase() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // يمكنك ربطها بـ LocalNotifyService لإظهار الإشعار
    });
  }

  @override
  Future<String?> getDeviceToken() async {
    return await FirebaseMessaging.instance.getToken();
  }
}