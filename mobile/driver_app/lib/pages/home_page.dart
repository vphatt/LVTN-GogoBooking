import 'dart:async';

import 'package:driver_app/controller/splash_controller.dart';
import 'package:driver_app/utils/my_color.dart';
import 'package:driver_app/utils/push_notification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
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
  bool isDriverOnline = false;
  Color statusButtonColor = MyColor.red;
  String statusButtonTitle = "KHÔNG HOẠT ĐỘNG";

  //Xác định tài xế đang rãnh hay đang chở khách
  DatabaseReference? newTripRequestReference;

  GlobalKey<ScaffoldState> gbKey = GlobalKey<ScaffoldState>();

  //Lấy email tài xế, lấy trực tiếp từ account ko lấy từ database
  getEmailDriver() async {
    DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid);

    await userRef.update({
      "email": FirebaseAuth.instance.currentUser!.email,
    });

    setState(() {
      driverEmail = FirebaseAuth.instance.currentUser!.email!;
    });
  }

  //lay thong tin gia cuoc
  getFareTrip() async {
    DatabaseReference fareTripRef =
        FirebaseDatabase.instance.ref().child("fareTrip");

    await fareTripRef.once().then((snap) {
      setState(() {
        openDoorAmount =
            double.parse((snap.snapshot.value! as Map)["openDoor"].toString());
        distancePerKmUnder30Amount =
            double.parse((snap.snapshot.value! as Map)["under30km"].toString());
        distancePerKmOver30Amount =
            double.parse((snap.snapshot.value! as Map)["over30km"].toString());
      });
    });
  }

  getGoongMapAPI() async {
    DatabaseReference apiRef =
        FirebaseDatabase.instance.ref().child("apiKey").child("goongMap");

    await apiRef.once().then((snap) {
      setState(() {
        goongMapKey = (snap.snapshot.value! as Map)["key"].toString();
      });
    });
  }

  //Cập nhật tổng doanh thu của tài xế
  List tripCompleted = [];
  //double fare = 0;
  updateIncomeAndPointToDriver() async {
    double driverIncome = 0;
    double driverPoint = 0;
    double sum = 0;
    //Lấy toan bo chuyen da hoan thanh
    DatabaseReference tripRequestRef =
        FirebaseDatabase.instance.ref().child("tripRequests");
    //Lấy tổng số chuyến được yêu cầu, tại đây lấy cả chuyến của tài xế khác
    await tripRequestRef.once().then(
      (snap) async {
        if (snap.snapshot.value != null) {
          Map allTripMap = snap.snapshot.value as Map;

          // int allTripNumber = allTripMap.length;

          //Lọc ra những chuyến đã hoàn thành của tài xế hiện tại
          List completedTripsOfCurrentDriver = [];

          allTripMap.forEach((key, value) {
            if (value["status"] != "initial" &&
                value["status"] == "ended" &&
                value["driverId"] == FirebaseAuth.instance.currentUser!.uid &&
                value["rating"]["rateStar"] != 0) {
              completedTripsOfCurrentDriver.add({"key": key, ...value});
            }
          });

          setState(() {
            tripCompleted = completedTripsOfCurrentDriver;
          });
        }
      },
    );

    if (tripCompleted.isNotEmpty) {
      for (var element in tripCompleted) {
        driverIncome =
            driverIncome + double.parse(element["actualFareAmount"].toString());

        sum = sum + double.parse(element["rating"]["rateStar"].toString());
      }

      driverPoint = sum / tripCompleted.length;

      setState(() {
        driverRate = driverPoint.toStringAsFixed(1);
      });

      //Cập nhật doanh thu
      FirebaseDatabase.instance
          .ref()
          .child("drivers")
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child("incomes")
          .set(driverIncome);

      FirebaseDatabase.instance
          .ref()
          .child("drivers")
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child("rating")
          .set(driverPoint.toStringAsFixed(1));
    }
  }

  //Lay vi tri hien tai cua tai xe
  getCurrentLocationDriver() async {
    Position positionOfDriver = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionOfDriver = positionOfDriver;
    driverCurrentPositionGB = currentPositionOfDriver;

    LatLng latLngPositionOfDriver = LatLng(
        currentPositionOfDriver!.latitude, currentPositionOfDriver!.longitude);
    initialCurrentDriverLatLng = latLngPositionOfDriver;
    driverCurrentLatLngGB = latLngPositionOfDriver;

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
    DatabaseReference driversRef = FirebaseDatabase(databaseURL: flutterURL)
        .ref()
        .child('drivers')
        .child(FirebaseAuth.instance.currentUser!.uid);

    await driversRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        //Kiem tra tai khoan co bi khoa khong
        if ((snap.snapshot.value as Map)["blockStatus"] == 'no') {
          //lấy tên của tai xe đã đăng nhập
          //driverNameGB = (snap.snapshot.value as Map)['name'];
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

  //Bật trạng thái hoạt động
  enableActiveStatus() {
    //Tài xế sẵn sàng nhận yêu cầu
    Geofire.initialize("driverActive");

    //Lấy vị trí hiện tại của tài xế
    Geofire.setLocation(
      FirebaseAuth.instance.currentUser!.uid,
      currentPositionOfDriver!.latitude,
      currentPositionOfDriver!.longitude,
    );

    //Lấy thông tin trạng thái từ database
    newTripRequestReference = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("newTripStatus");
    newTripRequestReference!.set("waiting");

    newTripRequestReference!.onValue.listen((event) {});
  }

  //Lấy vị trí tài xế và cập nhật theo thời gian thực
  setAndGetLocationUpdate() {
    positionStreamHomePage =
        Geolocator.getPositionStream().listen((Position position) {
      currentPositionOfDriver = position;

      if (isDriverOnline == true) {
        Geofire.setLocation(
          FirebaseAuth.instance.currentUser!.uid,
          currentPositionOfDriver!.latitude,
          currentPositionOfDriver!.longitude,
        );
      }

      LatLng positionLatLng = LatLng(
        position.latitude,
        position.longitude,
      );
      googleMapController!
          .animateCamera(CameraUpdate.newLatLng(positionLatLng));
    });
  }

  //Tắt trạng thái hoạt động
  disableActiveStatus() {
    //Dừng chia sẻ vị trí
    Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid);

    //Dừng theo dõi trạng thái
    newTripRequestReference!.onDisconnect();
    newTripRequestReference!.remove();
    newTripRequestReference = null;
  }

  //Tao thong bao day
  initializePushNotification() {
    PushNotification pushNotification = PushNotification();
    pushNotification.generateDeviceToken();
    pushNotification.startListeningForNewNotification(context);
  }

  //Nhận thông tin của driver đang đăng nhập
  retrieveCurrentDriverInfo() async {
    await FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .once()
        .then(
      (snap) {
        driverName = (snap.snapshot.value as Map)["name"];
        driverPhone = (snap.snapshot.value as Map)["phone"];
        driverAvt = (snap.snapshot.value as Map)["avatar"];
        driverEmail = (snap.snapshot.value as Map)["email"];
        carNumber = (snap.snapshot.value as Map)["car_details"];
      },
    );

    initializePushNotification();
  }

  @override
  void initState() {
    super.initState();
    retrieveCurrentDriverInfo();
    getEmailDriver();
    getFareTrip();
    getGoongMapAPI();
    updateIncomeAndPointToDriver();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
        body: Stack(
      children: [
        //Hiện thị bản đồ
        GoogleMap(
          padding: const EdgeInsets.symmetric(vertical: 100),
          mapType: MapType.normal,
          myLocationEnabled: true,
          initialCameraPosition:
              CameraPosition(target: initialCurrentDriverLatLng!, zoom: 15),
          // target: LatLng(10.032433897900804, 105.7576156559728), zoom: 15),
          onMapCreated: (GoogleMapController mapController) {
            googleMapController = mapController;
            completerGoogleMapController.complete(googleMapController);
            getCurrentLocationDriver();
          },
        ),

        // Center(
        //   child: TextButton(
        //       onPressed: () {
        //         showDialog(
        //             context: context,
        //             barrierDismissible: false,
        //             builder: (BuildContext context) => PaymentDialog());
        //       },
        //       child: Text("TESTTTTTT")),
        // ),

        //Nút online và offline
        Positioned(
          bottom: 0,
          left: 0,
          width: screenSize.width / 2,
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
                          margin: const EdgeInsets.all(20),
                          //height: screenSize.height / 3.7,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: MyColor.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Wrap(
                            children: [
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: screenSize.height / 50),
                                      child: isDriverOnline == false
                                          ? Text(
                                              "ĐANG HOẠT ĐỘNG?",
                                              style: TextStyle(
                                                  color: MyColor.green,
                                                  fontSize:
                                                      screenSize.height / 40,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          : Text(
                                              "KHÔNG HOẠT ĐỘNG?",
                                              style: TextStyle(
                                                  color: MyColor.red,
                                                  fontSize:
                                                      screenSize.height / 40,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: screenSize.width / 50),
                                      child: Text(
                                        isDriverOnline == false
                                            ? "Đặt trạng thái của bạn là \"ĐANG HOẠT ĐỘNG\".\nBạn sẽ nhận được các yêu cầu đặt xe từ những khách hàng gần nhất"
                                            : "Đặt trạng thái của bạn là \"KHÔNG HOẠT ĐỘNG\".\nBạn sẽ không nhận được bất kỳ yêu cầu đặt xe nào trong thời gian này",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: screenSize.height / 60),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: screenSize.height / 50,
                                          horizontal: screenSize.width / 30),
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
                                                          BorderRadius.circular(
                                                              5))),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                child: Text(
                                                  "HUỶ",
                                                  style: TextStyle(
                                                      fontSize:
                                                          screenSize.height /
                                                              50,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: MyColor.white),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: screenSize.width / 80,
                                          ),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () {
                                                if (isDriverOnline == false) {
                                                  //Bật trạng thái hoạt động
                                                  enableActiveStatus();

                                                  //Lấy vị trí tài xế cập nhật theo thời gian thực
                                                  setAndGetLocationUpdate();

                                                  Navigator.pop(context);
                                                  setState(() {
                                                    statusButtonColor =
                                                        MyColor.green;
                                                    statusButtonTitle =
                                                        "ĐANG HOẠT ĐỘNG";
                                                    isDriverOnline = true;
                                                  });
                                                } else {
                                                  //Tắt trạng thái hoạt động
                                                  disableActiveStatus();

                                                  Navigator.pop(context);
                                                  setState(() {
                                                    statusButtonColor =
                                                        MyColor.red;
                                                    statusButtonTitle =
                                                        "KHÔNG HOẠT ĐỘNG";
                                                    isDriverOnline = false;
                                                  });
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      isDriverOnline == false
                                                          ? MyColor.green
                                                          : MyColor.red,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5))),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                child: Text(
                                                  "XÁC NHẬN",
                                                  style: TextStyle(
                                                      fontSize:
                                                          screenSize.height /
                                                              50,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: MyColor.white),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ]),
                            ],
                          ),
                        );
                      });
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: statusButtonColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5))),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width / 100,
                      vertical: screenSize.height / 60),
                  child: Text(
                    statusButtonTitle,
                    maxLines: 1,
                    style: TextStyle(
                        fontSize: screenSize.height / 70,
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
