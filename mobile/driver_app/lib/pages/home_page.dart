import 'dart:async';

import 'package:driver_app/controller/splash_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../authentication/login_screen.dart';
import '../global/global_var.dart';
import '../methods/common_methods.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final splashController = Get.put(SplashController());
  final Completer<GoogleMapController> completerGoogleMapController =
      Completer<GoogleMapController>();

  GoogleMapController? googleMapController;
  CommonMethods cMethods = CommonMethods();

  Position? currentPositionOfDriver;

  GlobalKey<ScaffoldState> gbKey = GlobalKey<ScaffoldState>();

  //Lay vi tri hien tai cua tai xe
  getCurrentLocationDriver() async {
    Position positionOfDriver = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionOfDriver = positionOfDriver;

    LatLng latLngPositionOfDriver = LatLng(
        currentPositionOfDriver!.latitude, currentPositionOfDriver!.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: latLngPositionOfDriver, zoom: 15);
    googleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    await getDriverInfoAndCheckBlockStatus();
    //return cameraPosition;
  }

  //CameraPosition camera = CameraPosition(target: )

  //Kiem tra tai xe da dang nhap co bi block dot xuat boi admin khong
  getDriverInfoAndCheckBlockStatus() async {
    // ignore: deprecated_member_use
    DatabaseReference usersRef = FirebaseDatabase(databaseURL: flutterURL)
        .ref()
        .child('drivers')
        .child(FirebaseAuth.instance.currentUser!.uid);

    await usersRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        //Kiem tra tai khoan co bi khoa khong
        if ((snap.snapshot.value as Map)["blockStatus"] == 'no') {
          //lấy tên của tai xe đã đăng nhập
          userNameGB = (snap.snapshot.value as Map)['name'];
        } else {
          FirebaseAuth.instance.signOut();
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ));
          cMethods.displaySnackbar(
              "Tài khoản bị khoá! Liên hệ phatduongvgt@gmail.com để được hỗ trợ.",
              context);
        }
      } else {
        FirebaseAuth.instance.signOut();
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        //Hiện thị bản đồ
        GoogleMap(
          padding: const EdgeInsets.symmetric(vertical: 100),
          mapType: MapType.normal,
          myLocationEnabled: true,
          initialCameraPosition: googleMapInitialPosition,
          onMapCreated: (GoogleMapController mapController) {
            googleMapController = mapController;

            completerGoogleMapController.complete(googleMapController);
            getCurrentLocationDriver();
          },
        ),
      ],
    ));
  }
}
