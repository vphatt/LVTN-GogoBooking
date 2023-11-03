import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:user_app/authentication/login_screen.dart';
import 'package:user_app/global/global_var.dart';
import 'package:user_app/methods/driver_manager_method.dart';
import 'package:user_app/models/active_nearby_driver_model.dart';
import 'package:user_app/models/direction_model.dart';
import 'package:user_app/pages/search_page.dart';
import 'package:user_app/utils/app_info.dart';
import 'package:user_app/utils/my_color.dart';

import '../controller/splash_controller.dart';
import '../global/trip_var.dart';
import '../methods/common_methods.dart';
import '../widgets/loading_dialog.dart';

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

  //Biến lấy địa điểm hiện tại của người dùng
  Position? currentPositionOfUser;

  //Padding map
  double bottomMapPadding = 100;

  //Chiều cao của phần chi tiết chuyến đi
  double tripDetailHeight = 0;

  //Chiều cao của phần cửa sổ yêu cầu xe
  double requestBoxHeight = 0;
  double tripBoxHeight = 0;

  //Xác định trạng thái khi người dùng của yêu cầu xe, tài xế chấp nhận,...
  String stateOfTrip = "normal"; // requesting, accepted,...

  //Biến lưu thông tin từ directionAPI
  DirectionModel? tripDirectionDetail;

  //Danh sách toạ độ polyline
  List<LatLng> polylineLatLng = [];
  Set<Polyline> polylineSet = {};
  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};

  //Custom 2 icon điểm đầu và cuối
  BitmapDescriptor? startLocationMark;
  BitmapDescriptor? endLocationMark;
  BitmapDescriptor? carDriverIcon;

  //Kiểm tra các tài xế lân cận đã được tải chưa
  bool activeNearbyDriverKeyLoad = false;

  //Biến truy xuất thông tin của YÊU CẦU ĐẶT XE
  DatabaseReference? tripRequestRef;

  makeCarDriverIcon() {
    if (carDriverIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: const Size(0.5, 0.5));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, "assets/images/car_icon.png")
          .then((iconCar) {
        carDriverIcon = iconCar;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    //Gán icon điểm đầu
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(), 'assets/images/starthererz.png')
        .then((value) {
      startLocationMark = value;
    });
    //Gán icon điểm cuối
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(), 'assets/images/endhererz.png')
        .then((value) {
      endLocationMark = value;
    });

    //makeCarDriverIcon();
  }

  //Key tạo drawer
  GlobalKey<ScaffoldState> gbKey = GlobalKey<ScaffoldState>();

  //Lay vi tri hien tai cua nguoi dung
  getCurrentLocationUser() async {
    Position positionOfUser = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionOfUser = positionOfUser;

    LatLng latLngPositionOfUser = LatLng(
        currentPositionOfUser!.latitude, currentPositionOfUser!.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: latLngPositionOfUser, zoom: 16);
    googleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    // ignore: use_build_context_synchronously
    await CommonMethods.convertCoordinateToAddress(
        context, currentPositionOfUser!);

    await getUserInfoAndCheckBlockStatus();

    await initializeGeofireListener();
  }

  //Kiem tra nguoi dung da dang nhap co bi block dot xuat boi admin khong
  getUserInfoAndCheckBlockStatus() async {
    // ignore: deprecated_member_use
    DatabaseReference usersRef = FirebaseDatabase(databaseURL: flutterURL)
        .ref()
        .child('users')
        .child(FirebaseAuth.instance.currentUser!.uid);

    await usersRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        //Kiem tra tai khoan co bi khoa khong
        if ((snap.snapshot.value as Map)["blockStatus"] == 'no') {
          //lấy tên của người dùng đã đăng nhập
          setState(() {
            userNameGB = (snap.snapshot.value as Map)['name'];
            userPhoneGB = (snap.snapshot.value as Map)['phone'];
          });
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

  //Hiện thị chi tiết quãng đường
  displayTripDetail() async {
    await getDirectionDetail();

    setState(() {
      bottomMapPadding = 300;
      tripDetailHeight = 300;
    });
  }

  //Lấy thông tin chi tiết quãng đường
  getDirectionDetail() async {
    var startLocation =
        Provider.of<AppInfo>(context, listen: false).startLocation;
    var endLocation = Provider.of<AppInfo>(context, listen: false).endLocation;
    var startLatLng =
        LatLng(startLocation!.latitude!, startLocation.longitude!);
    var endLatLng = LatLng(endLocation!.latitude!, endLocation.longitude!);

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: "Đang xử lý..."),
    );

    //Gọi Direction API
    var directionDetail =
        await CommonMethods.getDirectionDetailFromAPI(startLatLng, endLatLng);

    setState(() {
      tripDirectionDetail = directionDetail;
    });

    // ignore: use_build_context_synchronously
    Navigator.pop(context);

    //Vẽ đường đi
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> pointLatLngList =
        polylinePoints.decodePolyline(tripDirectionDetail!.encodedPoint!);

    polylineLatLng.clear();
    if (pointLatLngList.isNotEmpty) {
      for (var pointLatLng in pointLatLngList) {
        polylineLatLng.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      }
    }

    polylineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
        polylineId: const PolylineId("polylineID"),
        color: MyColor.polyline,
        points: polylineLatLng,
        jointType: JointType.round,
        width: 8,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );
      polylineSet.add(polyline);
    });

    LatLngBounds latLngBounds;

    if (startLatLng.latitude > endLatLng.latitude &&
        startLatLng.longitude > endLatLng.longitude) {
      latLngBounds = LatLngBounds(southwest: endLatLng, northeast: startLatLng);
    } else if (startLatLng.longitude > endLatLng.longitude) {
      latLngBounds = LatLngBounds(
        southwest: LatLng(startLatLng.latitude, endLatLng.longitude),
        northeast: LatLng(endLatLng.latitude, startLatLng.longitude),
      );
    } else if (startLatLng.latitude > endLatLng.latitude) {
      latLngBounds = LatLngBounds(
        southwest: LatLng(endLatLng.latitude, startLatLng.longitude),
        northeast: LatLng(startLatLng.latitude, endLatLng.longitude),
      );
    } else {
      latLngBounds = LatLngBounds(southwest: startLatLng, northeast: endLatLng);
    }

    googleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 80));

    //Điểm đánh dấu vị trí bắt đầu
    Marker startPointMarker = Marker(
      markerId: const MarkerId("startPointMarkerID"),
      position: startLatLng,
      icon: startLocationMark!,
      infoWindow:
          InfoWindow(title: startLocation.addressName, snippet: "Điểm đón"),
    );

    //Điểm đánh dấu vị trí kết thúc
    Marker endPointMarker = Marker(
      markerId: const MarkerId("endPointMarkerID"),
      position: endLatLng,
      icon: endLocationMark!,
      infoWindow:
          InfoWindow(title: endLocation.addressName, snippet: "Điểm đến"),
    );

    setState(() {
      markerSet.add(startPointMarker);
      markerSet.add(endPointMarker);
    });
  }

  //Huỷ thông tin đã chọn
  cancelDetail() {
    setState(() {
      polylineLatLng.clear();
      polylineSet.clear();
      markerSet.clear();
      tripDetailHeight = 0;
      bottomMapPadding = 100;
      requestBoxHeight = 0;
      tripBoxHeight = 0;

      driverStatus = "";
      driverName = "";
      driverAvt = "";
      driverPhone = "";
      driverCarDetail = "";
      driverArriving = "Tài xế đang đến";
    });
  }

  //Hộp thoại yêu cầu xe
  showRequestBox() {
    setState(() {
      tripDetailHeight = 0; //ẩn chi tiết chuyến đi
      requestBoxHeight = 300; //hiện hộp thoại yêu cầu
      bottomMapPadding = 100;
    });

    //Gửi yêu cầu đặt chuyến
    sendTripRequest();
  }

  sendTripRequest() {
    //Tạo một truy xuất csdl mới đặt tên là tripRequest
    tripRequestRef =
        FirebaseDatabase.instance.ref().child("tripRequests").push();

    //Các thông tin cho tripRequest
    var startLocation =
        Provider.of<AppInfo>(context, listen: false).startLocation;
    var endLocation = Provider.of<AppInfo>(context, listen: false).endLocation;

    //Toạ độ điểm đầu
    Map startLatLngMap = {
      "latitude": startLocation!.latitude.toString(),
      "longitude": startLocation.longitude.toString(),
    };

    //Toạ độ điểm cuối
    Map endLatLngMap = {
      "latitude": endLocation!.latitude.toString(),
      "longitude": endLocation.longitude.toString(),
    };

    //Toạ độ của tài xế
    Map driverLatLngMap = {
      "latitude": "",
      "longitude": "",
    };

    Map dataMap = {
      "tripId": tripRequestRef!.key,
      "userId": userIdGB,
      "requestDateTime": DateTime.now().toString(),
      "userName": userNameGB,
      "userPhone": userPhoneGB,
      "startLatLng": startLatLngMap,
      "endLatLng": endLatLngMap,
      "startAddress": startLocation.addressName,
      "endAddress": endLocation.addressName,
      "tripAmount": "",

      //tình trạng: khởi tạo, đang thực hiện và đã hoàn thành,...
      "status": "initial",

      //Thông tin tài xế sẽ được cập nhật sau khi tài xế chấp nhận
      "driverId": "waiting",
      "driverName": "",
      "driverPhone": "",
      "driverAvt": "",
      "carDetail": "",
      "driverLocation": driverLatLngMap,
    };

    tripRequestRef!.set(dataMap);
  }

  //Huỷ yêu cầu
  cancelRequest() {
    //Xoá thông tin yêu cầu khỏi csdl
    tripRequestRef!.remove();
    setState(() {
      stateOfTrip = "normal";
      requestBoxHeight = 0;
    });
  }

  //hàm cập nhật tài xế trên bản đồ
  updateActiveNearbyDriverOnMap() {
    setState(() {
      markerSet.clear();
    });
    Set<Marker> markers = <Marker>{};
    for (ActiveNearbyDriverModel activeNearbyDriver
        in DriverManagerMethod.activeNearbyDriverList) {
      LatLng driverCurrentPosition =
          LatLng(activeNearbyDriver.latDriver!, activeNearbyDriver.lngDriver!);

      Marker driverMarker = Marker(
        markerId: MarkerId("driver ID = ${activeNearbyDriver.uidDriver}"),
        position: driverCurrentPosition,
        icon: carDriverIcon!,
      );

      markers.add(driverMarker);
    }

    setState(() {
      markerSet = markers;
    });
  }

  //Khởi tạo Geofire để cho việc hiện thị các tài xế lân cận
  initializeGeofireListener() {
    Geofire.initialize("driverActive");

    //Đặt phạm vi bán kính tìm kiếm tài xế online là 20 km
    Geofire.queryAtLocation(currentPositionOfUser!.latitude,
            currentPositionOfUser!.longitude, 22)!
        .listen((driverEvent) {
      if (driverEvent != null) {
        var driverActiveChild = driverEvent["callBack"];

        switch (driverActiveChild) {
          //Khi tài xế từ bên ngoài bán kinh di chuyển vào
          case Geofire.onKeyEntered:
            ActiveNearbyDriverModel activeNearbyDriverModel =
                ActiveNearbyDriverModel();
            activeNearbyDriverModel.uidDriver = driverEvent["key"];
            activeNearbyDriverModel.latDriver = driverEvent["latitude"];
            activeNearbyDriverModel.lngDriver = driverEvent["longitude"];
            DriverManagerMethod.activeNearbyDriverList
                .add(activeNearbyDriverModel);

            //Kiểm tra tài xế được tải chưa
            if (activeNearbyDriverKeyLoad == true) {
              //Cập nhật tài xế trên bản đồ
              updateActiveNearbyDriverOnMap();
            }
            break;

          //Khi tài xế ngừng hoạt động
          case Geofire.onKeyExited:
            DriverManagerMethod.removeDriverFromList(driverEvent["key"]);

            //Cập nhật tài xế trên bản đồ
            updateActiveNearbyDriverOnMap();
            break;

          //Khi tài xế di chuyển trong phạm vi bán kính
          case Geofire.onKeyMoved:
            ActiveNearbyDriverModel activeNearbyDriverModel =
                ActiveNearbyDriverModel();
            activeNearbyDriverModel.uidDriver = driverEvent["key"];
            activeNearbyDriverModel.latDriver = driverEvent["latitude"];
            activeNearbyDriverModel.lngDriver = driverEvent["longitude"];
            DriverManagerMethod.updateActiveNearbyDriverLocation(
                activeNearbyDriverModel);

            //Cập nhật tài xế trên bản đồ
            updateActiveNearbyDriverOnMap();
            break;

          //Khi người dùng vừa mở app, các tài xế trong bán kính sẽ hiện thị
          case Geofire.onGeoQueryReady:
            activeNearbyDriverKeyLoad = true;

            //Cập nhật tài xế trên bản đồ
            updateActiveNearbyDriverOnMap();

            //Hiện thị các tài xế hoạt động gần nhất
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //final screenSize = MediaQuery.of(context).size;
    makeCarDriverIcon();
    return SafeArea(
      child: Scaffold(
          key: gbKey,
          drawer: Drawer(
            backgroundColor: MyColor.white,
            child: ListView(
              children: [
                //header drawer
                const SizedBox(
                  height: 50,
                ),
                Column(
                  children: [
                    const CircleAvatar(
                      radius: 60,
                      backgroundImage:
                          AssetImage("assets/images/logo_yellow.png"),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      userNameGB,
                      style: const TextStyle(
                          color: MyColor.green,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Hồ sơ',
                      style: TextStyle(
                          color: MyColor.green,
                          fontSize: 20,
                          fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 50,
                ),
                const Divider(
                  height: 1,
                  color: MyColor.green,
                  thickness: 1,
                ),

                //body drawer

                Padding(
                  padding: const EdgeInsets.all(15),
                  child: InkWell(
                    onTap: () {},
                    child: const ListTile(
                      leading: Icon(
                        Icons.info,
                        color: MyColor.green,
                      ),
                      title: Text(
                        'About',
                        style: TextStyle(
                            color: MyColor.green, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Divider(
                    height: 1,
                    color: MyColor.green,
                    thickness: 1,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(15),
                  child: InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) =>
                            LoadingDialog(messageText: 'Đang đăng xuất...'),
                      );
                      FirebaseAuth.instance.signOut();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ));
                    },
                    child: const ListTile(
                      leading: Icon(
                        Icons.logout,
                        color: MyColor.red,
                      ),
                      title: Text(
                        'Đăng xuất',
                        style: TextStyle(
                            color: MyColor.red, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: Stack(
            children: [
              //Hiện thị bản đồ
              GoogleMap(
                padding: EdgeInsets.only(top: 100, bottom: bottomMapPadding),
                mapType: MapType.normal,
                myLocationEnabled: true,
                polylines: polylineSet,
                markers: markerSet,
                circles: circleSet,
                initialCameraPosition: googleMapInitialPosition,
                onMapCreated: (GoogleMapController mapController) {
                  googleMapController = mapController;
                  completerGoogleMapController.complete(googleMapController);
                  getCurrentLocationUser();
                },
              ),

              //drawer và thanh search
              Container(
                height: 70,
                width: double.infinity,
                margin: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: MyColor.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0, 3), //(x,y)
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: IconButton(
                        onPressed: () {
                          gbKey.currentState!.openDrawer();
                        },
                        icon: const Icon(
                          Icons.menu,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(15),
                      child: VerticalDivider(
                        width: 1,
                        color: MyColor.grey,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: InkWell(
                          onTap: () async {
                            var responseFromSearchPage = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SearchPage(),
                              ),
                            );

                            if (responseFromSearchPage == "placeSelected") {
                              // ignore: use_build_context_synchronously
                              Provider.of<AppInfo>(context, listen: false)
                                      .startLocation!
                                      .addressName ??
                                  "";

                              // ignore: use_build_context_synchronously
                              Provider.of<AppInfo>(context, listen: false)
                                      .endLocation!
                                      .addressName ??
                                  "";
                              displayTripDetail();
                              // print('ĐIỂM ĐÓNNNNNN: $startAddress');
                              // print('ĐIỂM ĐÍCHHHHH: $endAddress');
                            }
                          },
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SearchPage(),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.search,
                                ),
                              ),
                              const Text(
                                'Tìm kiếm địa điểm...',
                                style: TextStyle(
                                    fontSize: 20, color: MyColor.grey),
                              )
                            ],
                          ),
                        )),
                  ],
                ),
              ),

              //Chi tiết chuyến đi
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: tripDetailHeight,
                  decoration: const BoxDecoration(
                    color: MyColor.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(3, 0), //(x,y)
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                (tripDirectionDetail != null)
                                    ? tripDirectionDetail!.distanceText!
                                    : "0 km",
                                style: const TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.bold),
                              ),
                              const Text(
                                " - ",
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                (tripDirectionDetail != null)
                                    ? tripDirectionDetail!.durationText!
                                    : "0 phút",
                                style: const TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.bold),
                              ),
                              const Text(
                                " - ",
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.bold),
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: (tripDirectionDetail != null)
                                          ? cMethods
                                              .calculateFareAmount(
                                                  tripDirectionDetail!)
                                              .toString()
                                          : "0",
                                      style: const TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          color: MyColor.red),
                                    ),
                                    const TextSpan(
                                      text: " ₫",
                                      style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          color: MyColor.black),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),

                              //Nút ẩn chi tiết, huỷ thông tin đã chọn
                              IconButton(
                                  onPressed: () {
                                    cancelDetail();
                                  },
                                  icon: const Icon(Icons.close))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const CircleAvatar(
                                radius: 50,
                                backgroundImage:
                                    AssetImage("assets/images/driver.png"),
                              ),
                              const Column(
                                children: [
                                  Text(
                                    "Nguyễn Văn Xế",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "83H-45678",
                                    style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text("BMW, Xanh",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold))
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                    color: MyColor.green,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: const Column(
                                  children: [
                                    Text("2",
                                        style: TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                            color: MyColor.white)),
                                    Text("Phút đợi",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: MyColor.white))
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: FilledButton(
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ))),
                            onPressed: () {
                              setState(() {
                                stateOfTrip =
                                    "requesting"; // Đổi trạng thái sang đang yêu cầu
                              });

                              //Hiện thị hộp thoại khi người dùng click yêu cầu
                              showRequestBox();

                              //Tìm tài xế gần nhất

                              //Tìm xài xế nếu tài xế đầu tiên từ chối
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                "YÊU CẦU",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),

              //Hộp thoại yêu cầu đặt xe
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: requestBoxHeight,
                  decoration: const BoxDecoration(
                    color: MyColor.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(3, 0), //(x,y)
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LoadingAnimationWidget.twistingDots(
                            leftDotColor: MyColor.red,
                            rightDotColor: MyColor.green,
                            size: 70),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            "Đang tìm tài xế cho bạn...",
                            style: TextStyle(
                                fontSize: 20, fontStyle: FontStyle.italic),
                          ),
                        ),
                        RawMaterialButton(
                          onPressed: () {
                            //Huỷ yêu cầu
                            cancelDetail();
                            cancelRequest();
                          },
                          elevation: 2.0,
                          fillColor: MyColor.black,
                          padding: const EdgeInsets.all(15.0),
                          shape: const CircleBorder(),
                          child: const Icon(
                            Icons.close,
                            size: 35.0,
                            color: MyColor.white,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          )),
    );
  }
}
