//import 'package:flutter/material.dart';
// ignore_for_file: use_build_context_synchronously

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:user_app/methods/common_methods.dart';
import 'package:user_app/pages/home_page.dart';

import '../authentication/login_screen.dart';
import '../global/global_var.dart';

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
        //Chay ung dung
        _launchScreen(context); //_getCurrentLocation(context);
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
        //Chay ung dung
        _launchScreen(context); //_getCurrentLocation(context);
      } else {
        CommonMethods().displaySnackbar(
            'Hãy cho phép tất cả các yều được yêu cầu!', context);
      }
    }
  }

  Position? currentPositionOfUser;

  void _launchScreen(BuildContext context) async {
    Position positionOfUser = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionOfUser = positionOfUser;

    initialCurrentUserLatLng = LatLng(
        currentPositionOfUser!.latitude, currentPositionOfUser!.longitude);
    Navigator.push(
      context,
      MaterialPageRoute(
          // ignore: unnecessary_null_comparison
          builder: (context) => FirebaseAuth.instance.currentUser != null
              ? const HomePage()
              : const LoginScreen()),
    );
  }
}
