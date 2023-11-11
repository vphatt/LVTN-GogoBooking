import 'dart:async';

import 'package:driver_app/methods/common_methods.dart';
import 'package:driver_app/models/trip_detail_model.dart';
import 'package:driver_app/utils/my_color.dart';
import 'package:driver_app/widgets/loading_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  BitmapDescriptor? carMark;
  BitmapDescriptor? startMark;

  bool directionRequest = false;
  String statusOfTrip = "accepted";

  @override
  void initState() {
    super.initState();
    //Gán icon car
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(), 'assets/images/car_icon2.png')
        .then((value) {
      carMark = value;
    });

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
  }

  //lấy vị trí tài xế và vẽ đường đi
  getDirectionAndDrawRoute(driverLocationLatLng, startLocationLatLng) async {
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            LoadingDialog(messageText: "Vui lòng đợi..."));

    //Lấy thông tin chuyến đi
    var tripDetailInfo = await CommonMethods.getDirectionDetailFromAPI(
        driverLocationLatLng, startLocationLatLng);

    // ignore: use_build_context_synchronously
    Navigator.pop(context);

    PolylinePoints pointsPolyline = PolylinePoints();
    List<PointLatLng> pointLatLngList =
        pointsPolyline.decodePolyline(tripDetailInfo!.encodedPoint!);

    //Xoá danh sách trong trường hợp chuyến cũ vẫn còn lưu lại
    polylineLatLngList.clear();

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

    if (driverLocationLatLng.latitude > startLocationLatLng.latitude &&
        driverLocationLatLng.longitude > startLocationLatLng.longitude) {
      latLngBounds = LatLngBounds(
        southwest: startLocationLatLng,
        northeast: driverLocationLatLng,
      );
    } else if (driverLocationLatLng.longitude > startLocationLatLng.longitude) {
      latLngBounds = LatLngBounds(
        southwest: LatLng(
          driverLocationLatLng.latitude,
          startLocationLatLng.longitude,
        ),
        northeast: LatLng(
          startLocationLatLng.latitude,
          driverLocationLatLng.longitude,
        ),
      );
    } else if (driverLocationLatLng.latitude > startLocationLatLng.latitude) {
      latLngBounds = LatLngBounds(
        southwest: LatLng(
          startLocationLatLng.latitude,
          driverLocationLatLng.longitude,
        ),
        northeast: LatLng(
          driverLocationLatLng.latitude,
          startLocationLatLng.longitude,
        ),
      );
    } else {
      latLngBounds = LatLngBounds(
        southwest: driverLocationLatLng,
        northeast: startLocationLatLng,
      );
    }

    googleMapController!.animateCamera(
      CameraUpdate.newLatLngBounds(latLngBounds, 80),
    );

    //gán icon cho vị trí của driver và điểm đón
    // Marker driverMarker = Marker(
    //   markerId: const MarkerId("driverMarkerId"),
    //   position: LatLng(pointLatLngList.first.latitude,
    //       pointLatLngList.first.longitude), //driverLatLng,
    //   icon: driverMark!,
    //   infoWindow: const InfoWindow(title: "Vị trí của bạn"),
    // );

    Marker startMarker = Marker(
      markerId: const MarkerId("startMarkerId"),
      position: LatLng(pointLatLngList.last.latitude,
          pointLatLngList.last.longitude), //startLatLng,
      icon: startMark!,
      infoWindow: const InfoWindow(title: "Điểm đón khách"),
    );

    setState(() {
      //markerSet.add(driverMarker);
      markerSet.add(startMarker);
    });
  }

  //Vị trí tài xế theo thời gian thục
  getRealTimeDriverLocation() {
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
      updateTripInfomation();

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
  updateTripInfomation() async {
    if (!directionRequest) {
      directionRequest = true;

      if (driverCurrentLatLngGB == null) {
        return;
      }

      var driverLocationLatLng = LatLng(
          driverCurrentLatLngGB!.latitude, driverCurrentLatLngGB!.longitude);

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
    }
  }

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.symmetric(vertical: 100),
            mapType: MapType.normal,
            //myLocationEnabled: true,
            polylines: polylineSet,
            markers: markerSet,
            initialCameraPosition:
                CameraPosition(target: initialCurrentDriverLatLng!, zoom: 15),
            // target: LatLng(10.032433897900804, 105.7576156559728), zoom: 15),
            onMapCreated: (GoogleMapController mapController) async {
              googleMapController = mapController;
              completerGoogleMapController.complete(googleMapController);

              var driverCurrentLocationLatLng = LatLng(
                driverCurrentPositionGB!.latitude,
                driverCurrentPositionGB!.longitude,
              );

              var startLocationLatLng = widget.newTripDetailInfo!.startLatLng;
              print(
                  "ĐIỂM ĐÓN TOẠ ĐỘ: ${widget.newTripDetailInfo!.startLatLng!.latitude},${widget.newTripDetailInfo!.startLatLng!.longitude}");

              //lấy vị trí tài xế và vẽ đường đi
              await getDirectionAndDrawRoute(
                driverCurrentLocationLatLng,
                startLocationLatLng,
              );

              //Cập nhật vị trí theo thời gian thực
              getRealTimeDriverLocation();
            },
          ),
        ],
      ),
    );
  }
}
