import 'dart:async';

import 'package:driver_app/methods/common_methods.dart';
import 'package:driver_app/models/trip_detail_model.dart';
import 'package:driver_app/utils/my_color.dart';
import 'package:driver_app/widgets/loading_dialog.dart';
import 'package:driver_app/widgets/payment_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:timelines/timelines.dart';
import 'package:url_launcher/url_launcher.dart';

import '../global/global_var.dart';

class NewTripPage extends StatefulWidget {
  final TripDetailModel? newTripDetailInfo;
  const NewTripPage({super.key, this.newTripDetailInfo});

  @override
  State<NewTripPage> createState() => _NewTripPageState();
}

class _NewTripPageState extends State<NewTripPage> {
  GoogleMapController? googleMapController;
  final Completer<GoogleMapController> completerGoogleMapController =
      Completer<GoogleMapController>();
  List<LatLng> polylineLatLngList = [];
  PolylinePoints polylinePoints = PolylinePoints();
  Set<Marker> markerSet = <Marker>{};
  Set<Polyline> polylineSet = <Polyline>{};

  BitmapDescriptor? driverMark;
  //BitmapDescriptor? carMark;
  BitmapDescriptor? startMark;
  BitmapDescriptor? endMark;

  bool directionRequest = false;
  String statusOfTrip = "accepted";

  String durationText = "";
  String distanceText = "";
  double actualFareAmountValue = 0.0;
  String buttonTripTitle = "ĐÃ ĐÓN";
  Color startTripColor = MyColor.green;

  CommonMethods cMethod = CommonMethods();

  @override
  void initState() {
    super.initState();

    polylineLatLngList.clear();

    //Gán icon điểm cuối
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(), 'assets/images/starthererz.png')
        .then((value) {
      startMark = value;
    });

    //Gán icon driver marker
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(), 'assets/images/carhererz.png')
        .then((value) {
      driverMark = value;
    });

    //Gán icon điểm cuối
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(), 'assets/images/endhererz.png')
        .then((value) {
      endMark = value;
    });

    updateDriverInfoToTripRequests();
  }

  //Cập nhật thông tin tài xế vào yêu cầu chuyến đi
  updateDriverInfoToTripRequests() async {
    Map<String, dynamic> driverInfoMap = {
      "driverId": FirebaseAuth.instance.currentUser!.uid,
      "status": "accepted",
      "driverName": driverName,
      "driverPhone": driverPhone,
      "driverAvt": driverAvt,
      "carDetail": carNumber,
      "driverPoint": driverRate,
    };

    Map<String, dynamic> driverCurrentLocation = {
      "latitude": driverCurrentPositionGB!.latitude.toString(),
      "longitude": driverCurrentPositionGB!.longitude.toString(),
    };

    await FirebaseDatabase.instance
        .ref()
        .child("tripRequests")
        .child(widget.newTripDetailInfo!.tripId!)
        .update(driverInfoMap);

    await FirebaseDatabase.instance
        .ref()
        .child("tripRequests")
        .child(widget.newTripDetailInfo!.tripId!)
        .child("driverLocation")
        .update(driverCurrentLocation);
  }

  //lấy vị trí tài xế và vẽ đường đi
  getDirectionAndDrawRoute(startLocationLatLng, endLocationLatLng) async {
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            LoadingDialog(messageText: "Vui lòng đợi..."));

    //Lấy thông tin chuyến đi
    var tripDetailInfo = await CommonMethods.getDirectionDetailFromAPI(
        startLocationLatLng, endLocationLatLng);

    // ignore: use_build_context_synchronously
    Navigator.pop(context);

    PolylinePoints pointsPolyline = PolylinePoints();
    List<PointLatLng> pointLatLngList =
        pointsPolyline.decodePolyline(tripDetailInfo!.encodedPoint!);

    // //Xoá danh sách trong trường hợp chuyến cũ vẫn còn lưu lại
    // polylineLatLngList.clear();

    if (pointLatLngList.isNotEmpty) {
      for (var pointLatLng in pointLatLngList) {
        polylineLatLngList
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      }
    }

    //Vẽ đường đi
    polylineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
        polylineId: const PolylineId("routeId"),
        color: MyColor.polyline,
        jointType: JointType.round,
        width: 8,
        points: polylineLatLngList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );
      polylineSet.add(polyline);
    });

    //Đặt đường vẽ khớp với bản đồ
    LatLngBounds latLngBounds;

    if (startLocationLatLng.latitude > endLocationLatLng.latitude &&
        startLocationLatLng.longitude > endLocationLatLng.longitude) {
      latLngBounds = LatLngBounds(
        southwest: endLocationLatLng,
        northeast: startLocationLatLng,
      );
    } else if (startLocationLatLng.longitude > endLocationLatLng.longitude) {
      latLngBounds = LatLngBounds(
        southwest: LatLng(
          startLocationLatLng.latitude,
          endLocationLatLng.longitude,
        ),
        northeast: LatLng(
          endLocationLatLng.latitude,
          startLocationLatLng.longitude,
        ),
      );
    } else if (startLocationLatLng.latitude > endLocationLatLng.latitude) {
      latLngBounds = LatLngBounds(
        southwest: LatLng(
          endLocationLatLng.latitude,
          startLocationLatLng.longitude,
        ),
        northeast: LatLng(
          startLocationLatLng.latitude,
          endLocationLatLng.longitude,
        ),
      );
    } else {
      latLngBounds = LatLngBounds(
        southwest: startLocationLatLng,
        northeast: endLocationLatLng,
      );
    }

    googleMapController!.animateCamera(
      CameraUpdate.newLatLngBounds(latLngBounds, 80),
    );

    if (endLocationLatLng != widget.newTripDetailInfo!.endLatLng!) {
      Marker startMarker = Marker(
        markerId: const MarkerId("startMarkerId"),
        position: LatLng(pointLatLngList.last.latitude,
            pointLatLngList.last.longitude), //startLatLng,
        icon: startMark!,
        infoWindow: const InfoWindow(title: "Điểm đón khách"),
      );

      setState(() {
        markerSet.add(startMarker);
      });
    } else {
      Marker endMarker = Marker(
        markerId: const MarkerId("endMarkerId"),
        position: LatLng(pointLatLngList.last.latitude,
            pointLatLngList.last.longitude), //startLatLng,
        icon: endMark!,
        infoWindow: const InfoWindow(title: "Điểm trả khách"),
      );

      setState(() {
        //markerSet.add(driverMarker);
        markerSet.add(endMarker);
      });
    }
  }

  //Vị trí tài xế theo thời gian thục
  getRealTimeDriverLocation() {
    // ignore: unused_local_variable
    LatLng lastPositionLatLng = const LatLng(0, 0);
    positionStreamNewTripPage =
        Geolocator.getPositionStream().listen((Position driverPosition) {
      driverCurrentPositionGB = driverPosition;
      LatLng driverCurrentPositionLatLng = LatLng(
          driverCurrentPositionGB!.latitude,
          driverCurrentPositionGB!.longitude);

      Marker carMarker = Marker(
        markerId: const MarkerId("carMarkerId"),
        position: driverCurrentPositionLatLng,
        icon: driverMark!,
        infoWindow: const InfoWindow(title: "Hiện tại"),
      );
      setState(() {
        CameraPosition cameraPosition = CameraPosition(
          target: driverCurrentPositionLatLng,
          zoom: 16,
        );
        googleMapController!
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        //Khi di chuyển, marker sẽ liên tục bị xoá và thêm vào vị trí tiếp theo
        markerSet
            .removeWhere((element) => element.markerId.value == "carMarkerId");
        markerSet.add(carMarker);
      });

      lastPositionLatLng = driverCurrentPositionLatLng;

      //Cập nhật thông tin chuyến đi
      updateTripInformation();

      //Cập nhật vị trí tài xế vào yêu cầu chuyến đi
      Map updateDriverLocation = {
        "latitude": driverCurrentPositionGB!.latitude,
        "longitude": driverCurrentPositionGB!.longitude,
      };

      FirebaseDatabase.instance
          .ref("tripRequests")
          .child(widget.newTripDetailInfo!.tripId!)
          .child("driverLocation")
          .set(updateDriverLocation);
    });
  }

  //Cập nhật thông tin chuyến đi
  updateTripInformation() async {
    directionRequest = false;

    if (!directionRequest) {
      directionRequest = true;

      if (driverCurrentPositionGB == null) {
        return;
      }

      var driverLocationLatLng = LatLng(driverCurrentPositionGB!.latitude,
          driverCurrentPositionGB!.longitude);

      LatLng endLocationLatLng;

      ///Trong trường hợp chuyến đi chưa bắt đầu (tài xế đang đến điểm đón, statusOfTrip == "accepted"),
      ///thì điểm cuối sẽ là điểm đón
      ///Ngược lại nếu chuyến đi đã bắt đầu, thì điểm cuối sẽ là điểm trả
      if (statusOfTrip == "accepted") {
        endLocationLatLng = widget.newTripDetailInfo!.startLatLng!;
      } else {
        endLocationLatLng = widget.newTripDetailInfo!.endLatLng!;
      }

      var directionInfomation = await CommonMethods.getDirectionDetailFromAPI(
          driverLocationLatLng, endLocationLatLng);

      if (directionInfomation != null) {
        directionRequest = false;

        setState(() {
          durationText = directionInfomation.durationText!;
          distanceText = directionInfomation.distanceText!;
        });
      }

      //Cập nhật tiền xe theo thời gian thực
      //Tính số tiền thật sự mà khách hàng phải trả dựa trên quãng đường đã đi
      //Vì khách hàng có thể yêu cầu dừng xe trước khi đến điểm trả
      //Nên số tiền thật sự có thể ít hơn số tiền dự tính ban đầu
      if (statusOfTrip == "onTrip") {
        var directionDetailEndTripInfo =
            await CommonMethods.getDirectionDetailFromAPI(
          widget.newTripDetailInfo!.startLatLng!,
          driverLocationLatLng,
        );

        double actualFareAmount =
            cMethod.calculateFareAmount(directionDetailEndTripInfo!);

        setState(() {
          actualFareAmountValue = actualFareAmount;
        });
      }
    }
  }

  endTrip() async {
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            LoadingDialog(messageText: "Đang kết thúc..."));

    //Tính toán phí phụ, trừ khuyến mãi

    //Cập nhật phí cuối cùng lên csdl
    FirebaseDatabase.instance
        .ref()
        .child("tripRequests")
        .child(widget.newTripDetailInfo!.tripId!)
        .child("actualFareAmount")
        .set(actualFareAmountValue);

    //Cập nhật quảng đường thực tế đã di chuyển
    FirebaseDatabase.instance
        .ref()
        .child("tripRequests")
        .child(widget.newTripDetailInfo!.tripId!)
        .child("actualDistanceMoved")
        .set(distanceText);

    //Cập nhập lại trang thái chuyến
    FirebaseDatabase.instance
        .ref()
        .child("tripRequests")
        .child(widget.newTripDetailInfo!.tripId!)
        .child("status")
        .set("ended");

    Navigator.pop(context);

    //Dừng chia sẻ vị trí của tài xế khi kết thúc
    positionStreamNewTripPage!.cancel();

    //hiện bảng thanh toán
    showPaymentDialog();
  }

  showPaymentDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => PaymentDialog(
              actualFareAmount: actualFareAmountValue,
              userName: widget.newTripDetailInfo!.userName!,
              actualDistanceText: distanceText,
            ));
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        elevation: 0.0,
        iconTheme: const IconThemeData(color: MyColor.white),
        centerTitle: true,
        title: const Text(
          'Chuyến đi',
          style: TextStyle(color: MyColor.white),
        ),
        backgroundColor: MyColor.green,
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(
                bottom: screenSize.height / 2.5, top: screenSize.height / 6),
            mapType: MapType.normal,
            myLocationEnabled: true,
            polylines: polylineSet,
            markers: markerSet,
            initialCameraPosition:
                CameraPosition(target: initialCurrentDriverLatLng!, zoom: 15),
            // target: LatLng(10.032433897900804, 105.7576156559728), zoom: 15),
            onMapCreated: (GoogleMapController mapController) async {
              polylineSet.clear();
              googleMapController = mapController;
              completerGoogleMapController.complete(googleMapController);

              var driverCurrentLocationLatLng = LatLng(
                driverCurrentPositionGB!.latitude,
                driverCurrentPositionGB!.longitude,
              );

              var startLocationLatLng = widget.newTripDetailInfo!.startLatLng;

              //lấy vị trí tài xế và vẽ đường đi
              await getDirectionAndDrawRoute(
                driverCurrentLocationLatLng,
                startLocationLatLng,
              );

              //Cập nhật vị trí theo thời gian thực
              await getRealTimeDriverLocation();
            },
          ),

          //Thông tin chuyến đi
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                  color: MyColor.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: MyColor.black,
                      blurRadius: 5,
                      spreadRadius: 0.5,
                      offset: Offset(0.5, 0.5),
                    ),
                  ]),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: screenSize.width / 40,
                    vertical: screenSize.height / 40),
                child: Wrap(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(
                        durationText,
                        style: TextStyle(
                            color: MyColor.black,
                            fontSize: screenSize.height / 50,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        " - ",
                        style: TextStyle(
                            color: MyColor.black,
                            fontSize: screenSize.height / 50,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        distanceText,
                        style: TextStyle(
                            color: MyColor.black,
                            fontSize: screenSize.height / 50,
                            fontWeight: FontWeight.bold),
                      ),
                    ]),
                    Divider(
                      height: screenSize.height / 50,
                      indent: 30,
                      endIndent: 30,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenSize.width / 20),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.newTripDetailInfo!.userName!,
                                style: TextStyle(
                                  color: MyColor.green,
                                  fontSize: screenSize.height / 60,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                widget.newTripDetailInfo!.userPhone!,
                                style: TextStyle(
                                    color: MyColor.black,
                                    fontSize: screenSize.height / 60,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            actualFareAmountValue != 0.0
                                ? "${formatVND.format(actualFareAmountValue)} đ"
                                : "Chưa tính",
                            style: TextStyle(
                              color: MyColor.red,
                              fontSize: screenSize.height / 60,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),
                    Divider(
                      height: screenSize.height / 50,
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
                              padding: EdgeInsets.all(screenSize.height / 90),
                              child: Text(
                                widget.newTripDetailInfo!.startAddress
                                    .toString(),
                                maxLines: 2,
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
                            nodePosition: 0.18,
                            node: TimelineNode(
                              indicator: Card(
                                margin: EdgeInsets.zero,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                      "${widget.newTripDetailInfo!.distanceFromStartToEnd}"),
                                ),
                              ),
                              startConnector: const DashedLineConnector(),
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
                              padding: EdgeInsets.all(screenSize.height / 90),
                              child: Text(
                                widget.newTripDetailInfo!.endAddress!
                                    .toString(),
                                maxLines: 2,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            launchUrl(Uri.parse(
                                "tel://${widget.newTripDetailInfo!.userPhone.toString()}"));
                          },
                          style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                width: 2,
                                color: MyColor.green,
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5))),
                          child: SizedBox(
                            width: screenSize.width / 4,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.phone,
                                    size: screenSize.height / 65,
                                  ),
                                  Text(
                                    "GỌI",
                                    style: TextStyle(
                                        fontSize: screenSize.height / 70,
                                        fontWeight: FontWeight.bold,
                                        color: MyColor.green),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            //Nếu tài xế chấp nhận => tài xế đang đến
                            if (statusOfTrip == "accepted") {
                              setState(() {
                                buttonTripTitle = "BẮT ĐẦU";
                                startTripColor = MyColor.red;
                              });

                              //Thay đổi trạng thái rằng tài xế đã đến
                              statusOfTrip = "arrived";

                              FirebaseDatabase.instance
                                  .ref()
                                  .child("tripRequests")
                                  .child(widget.newTripDetailInfo!.tripId!)
                                  .child("status")
                                  .set("arrived");

                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      LoadingDialog(
                                          messageText: "Bắt đầu chuyến đi..."));

                              polylineLatLngList.clear();
                              await getDirectionAndDrawRoute(
                                  widget.newTripDetailInfo!.startLatLng,
                                  widget.newTripDetailInfo!.endLatLng);

                              // ignore: use_build_context_synchronously
                              Navigator.pop(context);
                            }

                            //Nếu tài xế đang chở khách hàng
                            else if (statusOfTrip == "arrived") {
                              setState(() {
                                buttonTripTitle = "KẾT THÚC";
                                startTripColor = MyColor.blue;
                              });

                              //Thay đổi trạng thái rằng tài xế đang trong chuyến đi
                              statusOfTrip = "onTrip";
                              FirebaseDatabase.instance
                                  .ref()
                                  .child("tripRequests")
                                  .child(widget.newTripDetailInfo!.tripId!)
                                  .child("status")
                                  .set("onTrip");
                            }
                            //Nếu tài xế kết thúc chuyến đi
                            else if (statusOfTrip == "onTrip") {
                              //Kết thúc chuyến đi
                              endTrip();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: startTripColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5))),
                          child: SizedBox(
                            width: screenSize.width / 5,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Center(
                                child: Text(
                                  buttonTripTitle,
                                  style: TextStyle(
                                      fontSize: screenSize.height / 70,
                                      fontWeight: FontWeight.bold,
                                      color: MyColor.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
