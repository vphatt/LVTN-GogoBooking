import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:driver_app/models/trip_detail_model.dart';
import 'package:driver_app/widgets/loading_dialog.dart';
import 'package:driver_app/widgets/notification_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../global/global_var.dart';
import '../methods/common_methods.dart';
import '../models/direction_model.dart';
import 'my_color.dart';

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

  //Đợi thông báo mới
  startListeningForNewNotification(BuildContext context) async {
    ///3 truong hop thong bao
    ///--1. Terminated: Khi ung dung dong
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        String tripId = remoteMessage.data["tripId"];

        //Nhận thông tin của yêu cầu chuyến đi
        retrieveTripRequestInfo(context, tripId);
      }
    });

    ///--2. Foreground: Khi ung dung dang chay va nhan duoc thong bao
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        String tripId = remoteMessage.data["tripId"];

        //Nhận thông tin của yêu cầu chuyến đi
        retrieveTripRequestInfo(context, tripId);
      }
    });

    ///--3. Background: Khi ung dung dang chay ngam
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        String tripId = remoteMessage.data["tripId"];

        //Nhận thông tin của yêu cầu chuyến đi
        retrieveTripRequestInfo(context, tripId);
      }
    });
  }

  //Nhận thông tin từ yêu cầu mới
  retrieveTripRequestInfo(BuildContext context, String tripId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: "Có yêu cầu mới..."),
    );

    DatabaseReference tripRequestRef =
        FirebaseDatabase.instance.ref().child("tripRequests").child(tripId);

    tripRequestRef.once().then((dataSnapshot) async {
      Navigator.pop(context);

      //Âm thanh thông báo
      notificationSound.open(
        Audio("assets/audios/newTripNotificationSound.mp3"),
      );

      notificationSound.play();

      ///Lấy thông tin yêu cầu
      TripDetailModel tripDetailModel = TripDetailModel();
      //Biến lưu thông tin từ directionAPI

      tripDetailModel.tripId = tripId;

      ///Thông tin điểm đón
      double startLat = double.parse(
          (dataSnapshot.snapshot.value! as Map)["startLatLng"]["latitude"]);
      double startLng = double.parse(
          (dataSnapshot.snapshot.value! as Map)["startLatLng"]["longitude"]);
      tripDetailModel.startLatLng = LatLng(startLat, startLng);

      tripDetailModel.startAddress =
          (dataSnapshot.snapshot.value! as Map)["startAddress"];

      ///Thông tin điểm cuối
      double endLat = double.parse(
          (dataSnapshot.snapshot.value! as Map)["endLatLng"]["latitude"]);
      double endLng = double.parse(
          (dataSnapshot.snapshot.value! as Map)["endLatLng"]["longitude"]);
      tripDetailModel.endLatLng = LatLng(endLat, endLng);

      tripDetailModel.endAddress =
          (dataSnapshot.snapshot.value! as Map)["endAddress"];

      ///Thông tin người yêu cầu
      tripDetailModel.userName =
          (dataSnapshot.snapshot.value! as Map)["userName"];
      tripDetailModel.userPhone =
          (dataSnapshot.snapshot.value! as Map)["userPhone"];
      tripDetailModel.distanceFromStartToEnd =
          (dataSnapshot.snapshot.value! as Map)["distance"];
      tripDetailModel.tripPrice =
          (dataSnapshot.snapshot.value! as Map)["tripAmount"];

      //Lấy khoảng cách từ tài xế đến điểm đón
      LatLng? startLatLng = LatLng(startLat, startLng);
      String? distanceFromDriverToStart = "";

      var directionDetail = await CommonMethods.getDirectionDetailFromAPI(
          driverCurrentLatLngGB!, startLatLng);
      distanceFromDriverToStart = directionDetail!.distanceText.toString();

      // getDistanceFromDriverToStart() async {
      //   print("getDistanceFromDriverToStart ĐÃ THỰC THIIIIIIIIII");
      //   var directionDetail = await CommonMethods.getDirectionDetailFromAPI(
      //       driverCurrentLatLng!, startLatLng);
      //   distanceFromDriverToStart = directionDetail!.distanceText.toString();
      // }

      tripDetailModel.distanceFromDriverToStart = distanceFromDriverToStart;

      //Hiện log thông báo bên trong ứng dụng
      showModalBottomSheet(
        backgroundColor: MyColor.transparent,
        context: context,
        isDismissible: false,
        builder: (BuildContext context) => Wrap(
          children: [
            NotificationDialog(
              tripDetailModel: tripDetailModel,
            )
          ],
        ),
      );
    });
  }
}
