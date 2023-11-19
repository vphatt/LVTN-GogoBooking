//import 'package:flutter/material.dart';
// ignore_for_file: use_build_context_synchronously

import 'package:device_info_plus/device_info_plus.dart';
import 'package:driver_app/pages/dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:driver_app/methods/common_methods.dart';

import '../authentication/login_screen.dart';

class SplashController extends GetxController {
  // var latitute = ''.obs;
  // var logitude = ''.obs;

  Future<void> checkPermission(BuildContext context) async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    // ignore: unused_local_variable
    Map<Permission, PermissionStatus> status;

    if (androidInfo.version.sdkInt <= 32) {
      status = await [
        Permission.notification,
        Permission.camera,
        Permission.storage,
        Permission.location,
        Permission.phone,
      ].request();
      if (await Permission.notification.request().isGranted &&
          await Permission.camera.request().isGranted &&
          await Permission.storage.request().isGranted &&
          await Permission.location.request().isGranted &&
          await Permission.phone.request().isGranted) {
        //Thong bao
        // MyNotification.getFcmToken();
        // MyNotification.getMessageInBackground();
        // MyNotification.getMessageInForeground(context);
        //Chạy man hinh
        _launchScreen(context);
      } else {
        CommonMethods().displaySnackbar(
            'Hãy cho phép tất cả các yều được yêu cầu!', context);
      }
    } else {
      status = await [
        Permission.notification,
        Permission.camera, //
        Permission.photos, //
        Permission.location, //
        Permission.phone //
      ].request();
      if (await Permission.notification.request().isGranted &&
          await Permission.camera.request().isGranted &&
          await Permission.photos.request().isGranted &&
          await Permission.location.request().isGranted &&
          await Permission.phone.request().isGranted) {
        //Thong bao
        // MyNotification.getFcmToken();
        // MyNotification.getMessageInBackground();
        // MyNotification.getMessageInForeground(context);
        //Chạy man hinh
        _launchScreen(context);
      } else {
        CommonMethods().displaySnackbar(
            'Hãy cho phép tất cả các yều được yêu cầu!', context);
      }
    }
  }

  Position? currentPositionOfDriver;

  void _launchScreen(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => FirebaseAuth.instance.currentUser == null
              ? const LoginScreen()
              : const Dashboard()),
    );
  }
}
