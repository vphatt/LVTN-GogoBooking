import 'dart:async';

import 'package:driver_app/controller/splash_controller.dart';
import 'package:driver_app/utils/my_color.dart';
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

  //Lấy vị trí hiện tại của tài xế
  Position? currentPositionOfDriver;

  //trạng thái của tài xế
  bool isDriverAvailable = true;
  Color statusButtonColor = MyColor.green;
  String statusButtonTitle = "ĐANG HOẠT ĐỘNG";

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

        //Nút online và offline
        Positioned(
          bottom: 0,
          left: 0,
          child: Padding(
              padding: const EdgeInsets.all(15),
              child: ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                      backgroundColor: MyColor.transparent,
                      context: context,
                      isDismissible: false,
                      builder: (BuildContext context) {
                        return Container(
                          margin: const EdgeInsets.all(30),
                          height: 250,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: MyColor.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Column(children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: isDriverAvailable
                                  ? const Text(
                                      "ĐANG HOẠT ĐỘNG?",
                                      style: TextStyle(
                                          color: MyColor.green,
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold),
                                    )
                                  : const Text(
                                      "KHÔNG HOẠT ĐỘNG?",
                                      style: TextStyle(
                                          color: MyColor.red,
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold),
                                    ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30),
                              child: Text(
                                isDriverAvailable
                                    ? "Đặt trạng thái của bạn là \"ĐANG HOẠT ĐỘNG\".\nBạn sẽ nhận được các yêu cầu đặt xe từ những khách hàng gần nhất"
                                    : "Đặt trạng thái của bạn là \"KHÔNG HOẠT ĐỘNG\".\nBạn sẽ không nhận được bất kỳ yêu cầu đặt xe nào trong thời gian này",
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 17),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 30),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: MyColor.grey,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5))),
                                      child: const Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Text(
                                          "HUỶ",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: MyColor.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (!isDriverAvailable) {
                                          //Bật trạng thái hoạt động

                                          //Lấy vị trí tài xế thời gian thực
                                          Navigator.pop(context);
                                          setState(() {
                                            statusButtonColor = MyColor.red;
                                            statusButtonTitle =
                                                "KHÔNG HOẠT ĐỘNG";
                                            isDriverAvailable = true;
                                          });
                                        } else {
                                          //Tắt trạng thái hoạt động

                                          Navigator.pop(context);
                                          setState(() {
                                            statusButtonColor = MyColor.green;
                                            statusButtonTitle =
                                                "ĐANG HOẠT ĐỘNG";
                                            isDriverAvailable = false;
                                          });
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: isDriverAvailable
                                              ? MyColor.green
                                              : MyColor.red,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5))),
                                      child: const Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Text(
                                          "XÁC NHẬN",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: MyColor.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ]),
                        );
                      });
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: statusButtonColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5))),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    statusButtonTitle,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: MyColor.white),
                  ),
                ),
              )),
        )
      ],
    ));
  }
}
