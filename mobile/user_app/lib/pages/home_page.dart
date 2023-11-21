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
import 'package:restart_app/restart_app.dart';
import 'package:timelines/timelines.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:user_app/authentication/login_screen.dart';
import 'package:user_app/global/global_var.dart';
import 'package:user_app/methods/driver_manager_method.dart';
import 'package:user_app/methods/push_notification_methods.dart';
import 'package:user_app/models/active_nearby_driver_model.dart';
import 'package:user_app/models/direction_model.dart';
import 'package:user_app/pages/history_trip_page.dart';
import 'package:user_app/pages/search_page.dart';
import 'package:user_app/utils/app_info.dart';
import 'package:user_app/utils/my_color.dart';
import 'package:user_app/widgets/info_dialog.dart';
import 'package:user_app/widgets/payment_dialog.dart';

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

  //Biến lưu danh sách các tài xế lân cận
  List<ActiveNearbyDriverModel>? activeNearbyDriverList;

  //Key tạo drawer
  GlobalKey<ScaffoldState> gbKey = GlobalKey<ScaffoldState>();

  //Lắng nghe sự kiện trên tripRequest
  StreamSubscription<DatabaseEvent>? tripStreamSubscription;

  bool requestingDirectionDetail = false;

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

    //Gán icon xe
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(), "assets/images/car_icon.png")
        .then((iconCar) {
      carDriverIcon = iconCar;
    });
  }

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
            userEmailGB = (snap.snapshot.value as Map)['email'];
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
  displayTripRequestDetail() async {
    await getDirectionRequestDetail();

    setState(() {
      bottomMapPadding = 300;
      tripDetailHeight = 300;
    });
  }

  //Lấy thông tin chi tiết quãng đường
  getDirectionRequestDetail() async {
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
      position: LatLng(pointLatLngList.first.latitude,
          pointLatLngList.first.longitude), //startLatLng,
      icon: startLocationMark!,
      infoWindow:
          InfoWindow(title: startLocation.addressName, snippet: "Điểm đón"),
    );

    //Điểm đánh dấu vị trí kết thúc
    Marker endPointMarker = Marker(
      markerId: const MarkerId("endPointMarkerID"),
      position:
          LatLng(pointLatLngList.last.latitude, pointLatLngList.last.longitude),
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
  cancelTripRequestDetail() {
    setState(() {
      polylineLatLng.clear();
      polylineSet.clear();
      markerSet.clear();
      tripDirectionDetail = null;
      tripDetailHeight = 0;
      bottomMapPadding = 100;
      requestBoxHeight = 0;
      tripBoxHeight = 0;

      driverStatus = "";
      driverName = "";
      driverAvt = "";
      driverPhone = "";
      driverCarDetail = "";
      tripStatusText = "Tài xế đang đến";
    });
  }

  //Hộp thoại yêu cầu xe
  showRequestBox() {
    setState(() {
      tripDetailHeight = 0; //ẩn chi tiết chuyến đi
      requestBoxHeight = 380; //hiện hộp thoại yêu cầu
      bottomMapPadding = 100;
    });

    //Gửi yêu cầu đặt xe
    sendTripRequest();
  }

  //Hàm Gửi yêu cầu đặt xe
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
      "startAddress": startLocation.addressCoverted,
      "endAddress": endLocation.addressCoverted,
      "distance": tripDirectionDetail!.distanceText!,
      "tripAmount":
          cMethods.calculateFareAmount(tripDirectionDetail!).toString(),
      "actualFareAmount": "",
      "actualDistanceMoved": "",

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

    //Lắng nghe sự kiện, xem đã có tài xế chấp nhận yêu cầu hay chưa
    tripStreamSubscription =
        tripRequestRef!.onValue.listen((eventSnapshot) async {
      if (eventSnapshot.snapshot.value == null) {
        return;
      }

      if ((eventSnapshot.snapshot.value as Map)["driverName"] != null) {
        driverName = (eventSnapshot.snapshot.value as Map)["driverName"];
      }
      if ((eventSnapshot.snapshot.value as Map)["driverPhone"] != null) {
        driverPhone = (eventSnapshot.snapshot.value as Map)["driverPhone"];
      }
      if ((eventSnapshot.snapshot.value as Map)["driverAvt"] != null) {
        driverAvt = (eventSnapshot.snapshot.value as Map)["driverAvt"];
      }
      if ((eventSnapshot.snapshot.value as Map)["carDetail"] != null) {
        driverCarDetail = (eventSnapshot.snapshot.value as Map)["carDetail"];
      }
      if ((eventSnapshot.snapshot.value as Map)["status"] != null) {
        driverStatus = (eventSnapshot.snapshot.value as Map)["status"];
      }
      if ((eventSnapshot.snapshot.value as Map)["driverLocation"] != null) {
        double driverLatitude = double.parse(
            (eventSnapshot.snapshot.value as Map)["driverLocation"]["latitude"]
                .toString());

        double driverLongitude = double.parse(
            (eventSnapshot.snapshot.value as Map)["driverLocation"]["longitude"]
                .toString());

        LatLng driverCurrentLocationLatLng =
            LatLng(driverLatitude, driverLongitude);

        //Lắng nghe trạng thái yêu cầu
        if (driverStatus == "accepted") {
          //Cập nhật thông tin từ tài xế đến điểm đón
          updateFromDriverCurrentLocationToStart(driverCurrentLocationLatLng);
        } else if (driverStatus == "arrived") {
          //Cập nhật rằng ti xế đã đến
          setState(() {
            tripStatusText = "Tài xế đã đến rồi!";
          });
        } else if (driverStatus == "onTrip") {
          //Cập nhật thông tin từ tài xế đến điểm trả
          updateFromDriverCurrentLocationToEnd(driverCurrentLocationLatLng);
        }
      }

      if (driverStatus == "accepted") {
        showTripDetailContainer();

        Geofire.stopListener();

        //Loại bỏ các tài xế lân cân trên bản đồ
        setState(() {
          markerSet.removeWhere(
              (element) => element.markerId.value.contains("driver"));
        });
      }

      if (driverStatus == "ended") {
        if ((eventSnapshot.snapshot.value as Map)["actualFareAmount"] != null) {
          double actualFareAmount = double.parse(
              (eventSnapshot.snapshot.value as Map)["actualFareAmount"]
                  .toString());

          String actualDistance =
              (eventSnapshot.snapshot.value as Map)["actualDistanceMoved"];

          //Hiện PaymentDialog và nhận phản hồi
          var responeFromPaymentDialog = await showDialog(
              context: context,
              builder: (BuildContext context) => PaymentDialog(
                    actualFareAmount: actualFareAmount.toString(),
                    userName: userNameGB,
                    actualDistanceText: actualDistance,
                  ));

          if (responeFromPaymentDialog == "paid") {
            tripRequestRef!.onDisconnect();
            tripRequestRef = null;

            tripStreamSubscription!.cancel();
            tripStreamSubscription = null;

            cancelTripRequestDetail();

            Restart.restartApp();
          }
        }
      }
    });
  }

  showTripDetailContainer() {
    setState(() {
      requestBoxHeight = 0;
      tripDetailHeight = 350;
    });
  }

  //Cập nhật từ tài xế đến điểm đón
  updateFromDriverCurrentLocationToStart(driverCurrentLocationLatLng) async {
    if (!requestingDirectionDetail) {
      requestingDirectionDetail = true;

      var startLocation =
          Provider.of<AppInfo>(context, listen: false).startLocation;

      var startLocationLatLng =
          LatLng(startLocation!.latitude!, startLocation.longitude!);

      var directionDetailStart = await CommonMethods.getDirectionDetailFromAPI(
          driverCurrentLocationLatLng, startLocationLatLng);

      if (directionDetailStart == null) {
        return;
      }

      setState(() {
        tripStatusText =
            "Tài xế sẽ đến sau ${directionDetailStart.durationText}";
      });

      requestingDirectionDetail = false;
    }
  }

  //Cập nhật từ tài xế đến điểm trả
  updateFromDriverCurrentLocationToEnd(driverCurrentLocationLatLng) async {
    if (!requestingDirectionDetail) {
      requestingDirectionDetail = true;

      var endLocation =
          Provider.of<AppInfo>(context, listen: false).endLocation;

      var endLocationLatLng =
          LatLng(endLocation!.latitude!, endLocation.longitude!);

      var directionDetailEnd = await CommonMethods.getDirectionDetailFromAPI(
          driverCurrentLocationLatLng, endLocationLatLng);

      if (directionDetailEnd == null) {
        return;
      }

      setState(() {
        tripStatusText = "Tới nơi trong ${directionDetailEnd.durationText}";
      });

      requestingDirectionDetail = false;
    }
  }

  //Huỷ yêu cầu
  cancelRequest() {
    //Xoá thông tin yêu cầu
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
            currentPositionOfUser!.longitude, 20)!
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
            break;
        }
      }
    });
  }

  //Tìm tài xế cho chuyến đi
  searchDriverForTrip() {
    if (activeNearbyDriverList!.isEmpty) {
      cancelRequest();
      cancelTripRequestDetail();
      noDriverForTrip();
      return;
    }

    //Tài xế gần nhất được chọn
    var nearestSelectedDriver = activeNearbyDriverList![0];

    //gửi thông báo đến tài xế gần nhất được chọn
    sendNotificationToDriverDevice(nearestSelectedDriver);

    //Xoá tài xế đó khỏi danh sách sau khi gửi thông báo
    activeNearbyDriverList!.removeAt(0);
  }

  //Hàm gửi thông báo đến thiết bị của tài xế được chọn gần nhất
  sendNotificationToDriverDevice(
      ActiveNearbyDriverModel nearestSelectedDriver) {
    //Cập nhật trang thái của tài xế khi có yêu cầu
    DatabaseReference nearestSelectedDriverRef = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(nearestSelectedDriver.uidDriver.toString())
        .child("newTripStatus");
    nearestSelectedDriverRef.set(tripRequestRef!.key);

    //Lấy token của thiết bị mà tài xế đang đăng nhập
    DatabaseReference tokenNearestSelectedDriverRef = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(nearestSelectedDriver.uidDriver.toString())
        .child("deviceToken");

    tokenNearestSelectedDriverRef.once().then(
      (dataSnapshot) {
        if (dataSnapshot.snapshot.value != null) {
          String deviceToken = dataSnapshot.snapshot.value.toString();

          //Gửi thống báo đến tài xế
          PushNotificationMethods.sendNotificationToNearestSelectedDriver(
              context, deviceToken, tripRequestRef!.key.toString());
        } else {
          return;
        }

        var countDown = Timer.periodic(
          const Duration(seconds: 1),
          (timer) {
            driverRequestTimeOut--;

            //Nếu yêu cầu bị huỷ
            if (stateOfTrip != "requesting") {
              timer.cancel();
              nearestSelectedDriverRef.set("cancelled");
              nearestSelectedDriverRef.onDisconnect();
              driverRequestTimeOut = 30;
            }

            //Khi tài xế gần nhất chấp nhận yêu cầu
            nearestSelectedDriverRef.onValue.listen(
              (dataSnapshot) {
                if (dataSnapshot.snapshot.value.toString() == "accepted") {
                  timer.cancel();
                  nearestSelectedDriverRef.onDisconnect();
                  driverRequestTimeOut = 30;
                }
              },
            );

            //Khi qua 30 giây mà tài xế không phản hồi, gửi đến tài xế khác
            if (driverRequestTimeOut == 0) {
              nearestSelectedDriverRef.set("timeout");
              timer.cancel();
              nearestSelectedDriverRef.onDisconnect();
              driverRequestTimeOut = 30;

              //Gửi yêu cầu đến tài xế khác gần tiếp theo
              searchDriverForTrip();
            }
          },
        );
      },
    );
  }

  //Thông báo không tìm thấy tài xế
  noDriverForTrip() {
    showDialog(
      context: context,
      builder: (BuildContext context) => const InfoDialog(
        title: "Không tìm thấy tài xế",
        description:
            "Xin lỗi! Không có tài xế cho chuyến của bạn\nHãy thử lại sau ít phút nhé!",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
          key: gbKey,
          drawer: Drawer(
            backgroundColor: MyColor.white,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(15),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(
                        "https://firebasestorage.googleapis.com/v0/b/gogobooking-5ade1.appspot.com/o/user_profile.png?alt=media&token=afd72318-033b-4468-90e8-30ced957e3d6"),
                  ),
                ),
                Text(
                  userNameGB,
                  style: const TextStyle(
                      color: MyColor.green,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  userEmailGB,
                  style: const TextStyle(
                      color: MyColor.green,
                      fontSize: 20,
                      fontStyle: FontStyle.italic),
                ),
                const Divider(
                  height: 1,
                  color: MyColor.green,
                  thickness: 1,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15, right: 15, bottom: 15, top: 15),
                  child: InkWell(
                    onTap: () {},
                    child: const ListTile(
                      leading: Icon(
                        Icons.person,
                        color: MyColor.green,
                      ),
                      title: Text(
                        'Thông tin cá nhân',
                        style: TextStyle(
                            color: MyColor.green, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 15, right: 15, bottom: 15),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HistoryTripPage()));
                    },
                    child: const ListTile(
                      leading: Icon(
                        Icons.history,
                        color: MyColor.green,
                      ),
                      title: Text(
                        'Lịch sử đặt xe',
                        style: TextStyle(
                            color: MyColor.green, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: () {
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
                              builder: (context) => const LoginScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: MyColor.red,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "ĐĂNG XUẤT",
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
          ),
          body: Stack(
            children: [
              //Hiện thị bản đồ
              GoogleMap(
                padding: EdgeInsets.only(top: 100, bottom: bottomMapPadding),
                mapType: MapType.normal,
                myLocationEnabled: true,
                zoomControlsEnabled: false,
                polylines: polylineSet,
                markers: markerSet,
                circles: circleSet,
                initialCameraPosition:
                    CameraPosition(target: initialCurrentUserLatLng!, zoom: 15),
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
                              displayTripRequestDetail();
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

              //Chi tiết yêu cầu chuyến đi
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: (tripDirectionDetail != null && driverName == "")
                    ? Container(
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
                          child: Wrap(
                            //mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      (tripDirectionDetail != null)
                                          ? tripDirectionDetail!.durationText!
                                          : "0 phút",
                                      style: const TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const Text(
                                      " - ",
                                      style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: (tripDirectionDetail != null)
                                                ? formatVND.format(double.parse(
                                                    cMethods.calculateFareAmount(
                                                        tripDirectionDetail!)))
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
                                          cancelTripRequestDetail();
                                        },
                                        icon: const Icon(Icons.close))
                                  ],
                                ),
                              ),

                              //Thông tin chuyến đi
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: screenSize.width / 20),
                                child: Column(
                                  children: [
                                    //Điểm đón khách
                                    TimelineTile(
                                      nodePosition: 0.2,
                                      oppositeContents: Text(
                                        'Điểm đón ',
                                        style: TextStyle(
                                          color: MyColor.green,
                                          fontSize: screenSize.height / 70,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      contents: Container(
                                        padding: EdgeInsets.all(
                                            screenSize.height / 90),
                                        child: Text(
                                          tripDirectionDetail != null
                                              ? Provider.of<AppInfo>(context,
                                                      listen: false)
                                                  .startLocation!
                                                  .addressCoverted
                                                  .toString()
                                              : "",
                                          maxLines: 3,
                                          style: TextStyle(
                                            color: MyColor.black,
                                            fontSize: screenSize.height / 70,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      node: const TimelineNode(
                                        indicator: DotIndicator(
                                          color: MyColor.transparent,
                                          child: Icon(
                                            Icons.my_location,
                                            color: MyColor.green,
                                          ),
                                        ),
                                        endConnector: SolidLineConnector(
                                          color: MyColor.green,
                                        ),
                                      ),
                                    ),

                                    //Khoảng cách từ điểm đón khách đến điểm trả khách
                                    TimelineTile(
                                      nodePosition: 0.2,
                                      node: TimelineNode(
                                        indicator: Card(
                                          margin: EdgeInsets.zero,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                                tripDirectionDetail != null
                                                    ? tripDirectionDetail!
                                                        .distanceText
                                                        .toString()
                                                    : ""),
                                          ),
                                        ),
                                        startConnector:
                                            const DashedLineConnector(),
                                        endConnector:
                                            const SolidLineConnector(),
                                      ),
                                    ),

                                    //Điểm trả khách
                                    TimelineTile(
                                      nodePosition: 0.2,
                                      oppositeContents: Text(
                                        'Điểm trả ',
                                        style: TextStyle(
                                          color: MyColor.red,
                                          fontSize: screenSize.height / 70,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      contents: Container(
                                        padding: EdgeInsets.all(
                                            screenSize.height / 90),
                                        child: Text(
                                          tripDirectionDetail != null
                                              ? Provider.of<AppInfo>(context,
                                                      listen: false)
                                                  .endLocation!
                                                  .addressCoverted
                                                  .toString()
                                              : "",
                                          maxLines: 3,
                                          style: TextStyle(
                                            color: MyColor.black,
                                            fontSize: screenSize.height / 70,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      node: const TimelineNode(
                                        indicator: DotIndicator(
                                          color: MyColor.transparent,
                                          child: Icon(
                                            Icons.location_on,
                                            color: MyColor.red,
                                          ),
                                        ),
                                        startConnector: SolidLineConnector(
                                          color: MyColor.green,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(
                                height: screenSize.height / 50,
                                indent: 30,
                                endIndent: 30,
                              ),

                              //Request Button
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Center(
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

                                      //Lấy danh sach cac tai xe lan can trong ban kinh 20km
                                      activeNearbyDriverList =
                                          DriverManagerMethod
                                              .activeNearbyDriverList;

                                      //Tìm tài xế cho chuyến đi
                                      searchDriverForTrip();
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Text(
                                        "YÊU CẦU",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    : const SizedBox(
                        height: 0,
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
                            cancelTripRequestDetail();
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
              ),

              //Hộp thoại chi tiết chuyến đi
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: driverName != ""
                    ? Container(
                        //height: tripDetailHeight,
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
                        child: Wrap(
                          children: [
                            //cập nhật thời gian tài xế đến
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: Text(
                                  tripStatusText,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: MyColor.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const Divider(
                              color: MyColor.grey,
                              indent: 30,
                              endIndent: 30,
                            ),

                            //Thông tin tài xế
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, left: 20, right: 10, bottom: 10),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.network(
                                      driverAvt == ""
                                          ? "https://firebasestorage.googleapis.com/v0/b/gogobooking-5ade1.appspot.com/o/driver_profile.png?alt=media&token=bc53e4fe-5c07-46c4-9021-6d2bfd06a996"
                                          : driverAvt,
                                      height: 80,
                                      width: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      driverName,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      driverCarDetail,
                                      style: const TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(
                                      "Xep hang sao",
                                      style: const TextStyle(
                                        fontSize: 18,
                                      ),
                                    )
                                  ],
                                ),
                                const Spacer(),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, left: 10, right: 20, bottom: 10),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      launchUrl(
                                          Uri.parse("tel://$driverPhone"));
                                    },
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all(
                                          const CircleBorder()),
                                      padding: MaterialStateProperty.all(
                                          const EdgeInsets.all(25)),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              MyColor.green),
                                    ),
                                    child: const Icon(
                                      Icons.phone,
                                      color: MyColor.white,
                                      size: 25,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(
                              color: MyColor.grey,
                              indent: 30,
                              endIndent: 30,
                            ),

                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: screenSize.width / 20),
                              child: Column(
                                children: [
                                  //Điểm đón khách
                                  TimelineTile(
                                    nodePosition: 0.2,
                                    oppositeContents: Text(
                                      'Điểm đón ',
                                      style: TextStyle(
                                        color: MyColor.green,
                                        fontSize: screenSize.height / 70,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    contents: Container(
                                      padding: EdgeInsets.all(
                                          screenSize.height / 90),
                                      child: Text(
                                        tripDirectionDetail != null
                                            ? Provider.of<AppInfo>(context,
                                                    listen: false)
                                                .startLocation!
                                                .addressCoverted
                                                .toString()
                                            : "",
                                        maxLines: 3,
                                        style: TextStyle(
                                          color: MyColor.black,
                                          fontSize: screenSize.height / 70,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    node: const TimelineNode(
                                      indicator: DotIndicator(
                                        color: MyColor.transparent,
                                        child: Icon(
                                          Icons.my_location,
                                          color: MyColor.green,
                                        ),
                                      ),
                                      endConnector: SolidLineConnector(
                                        color: MyColor.green,
                                      ),
                                    ),
                                  ),

                                  //Khoảng cách từ điểm đón khách đến điểm trả khách
                                  TimelineTile(
                                    nodePosition: 0.2,
                                    node: TimelineNode(
                                      indicator: Card(
                                        margin: EdgeInsets.zero,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                              tripDirectionDetail != null
                                                  ? tripDirectionDetail!
                                                      .distanceText
                                                      .toString()
                                                  : ""),
                                        ),
                                      ),
                                      startConnector:
                                          const DashedLineConnector(),
                                      endConnector: const SolidLineConnector(),
                                    ),
                                  ),

                                  //Điểm trả khách
                                  TimelineTile(
                                    nodePosition: 0.2,
                                    oppositeContents: Text(
                                      'Điểm trả ',
                                      style: TextStyle(
                                        color: MyColor.red,
                                        fontSize: screenSize.height / 70,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    contents: Container(
                                      padding: EdgeInsets.all(
                                          screenSize.height / 90),
                                      child: Text(
                                        tripDirectionDetail != null
                                            ? Provider.of<AppInfo>(context,
                                                    listen: false)
                                                .endLocation!
                                                .addressCoverted
                                                .toString()
                                            : "",
                                        maxLines: 3,
                                        style: TextStyle(
                                          color: MyColor.black,
                                          fontSize: screenSize.height / 70,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    node: const TimelineNode(
                                      indicator: DotIndicator(
                                        color: MyColor.transparent,
                                        child: Icon(
                                          Icons.location_on,
                                          color: MyColor.red,
                                        ),
                                      ),
                                      startConnector: SolidLineConnector(
                                        color: MyColor.green,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(height: 0),
              )
            ],
          )),
    );
  }
}
