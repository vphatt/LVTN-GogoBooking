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

  // Future<Position> _getCurrentLocationDriver(BuildContext context) async {
  //   Position position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high);
  //   if (position.latitude != 0 && position.longitude != 0) {
  //     print('Vi do: ${position.latitude}, Kinh do: ${position.longitude}');
  //     latitute.value = position.latitude.toString();
  //     logitude.value = position.longitude.toString();
  //     _launchScreen(context);
  //   }
  //   return await Geolocator.getCurrentPosition();
  // }
  Position? currentPositionOfDriver;

  // getCurrentLocationDriver() async {
  //   Position positionOfDriver = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.bestForNavigation);
  //   currentPositionOfDriver = positionOfDriver;

  //   currentDriverLatLng = LatLng(
  //       currentPositionOfDriver!.latitude, currentPositionOfDriver!.longitude);
  // }

  void _launchScreen(BuildContext context) async {
    // Position positionOfDriver = await Geolocator.getCurrentPosition(
    //     desiredAccuracy: LocationAccuracy.bestForNavigation);
    // currentPositionOfDriver = positionOfDriver;

    // initialCurrentDriverLatLng = LatLng(
    //     currentPositionOfDriver!.latitude, currentPositionOfDriver!.longitude);
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => FirebaseAuth.instance.currentUser == null
              ? const LoginScreen()
              : const Dashboard()),
    );
  }
}
