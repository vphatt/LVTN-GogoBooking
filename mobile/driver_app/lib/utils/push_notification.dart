import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotification {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  //Tao ma xac dinh thiet bi va luu ma vao csdl
  Future<String?> generateDeviceToken() async {
    String? deviceToken = await firebaseMessaging.getToken();

    DatabaseReference referenceActiveDriver = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("deviceToken");

    referenceActiveDriver.set(deviceToken);

    firebaseMessaging.subscribeToTopic("drivers");
    firebaseMessaging.subscribeToTopic("users");
  }

  //Lang nghe thong bao moi
  startListeningForNewNotification() async {
    ///3 truong hop thong bao
    ///--1. Terminated: Khi ung dung dong
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        String tripId = remoteMessage.data["tripId"];
      }
    });

    ///--2. Foreground: Khi ung dung dang chay va nhan duoc thong bao
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        String tripId = remoteMessage.data["tripId"];
      }
    });

    ///--3. Background: Khi ung dung dang chay ngam
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        String tripId = remoteMessage.data["tripId"];
      }
    });
  }
}
