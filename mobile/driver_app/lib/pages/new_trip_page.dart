import 'dart:async';

import 'package:driver_app/methods/common_methods.dart';
import 'package:driver_app/models/trip_detail_model.dart';
import 'package:driver_app/utils/my_color.dart';
import 'package:driver_app/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
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
  BitmapDescriptor? startMark;

  void initState() {
    super.initState();
    //Gán icon điểm đầu
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(), 'assets/images/car_icon2.png')
        .then((value) {
      driverMark = value;
    });

    //Gán icon điểm cuối
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(), 'assets/images/starthererz.png')
        .then((value) {
      startMark = value;
    });
  }

//lấy vị trí tài xế và vẽ đường đi
  getDirectionAndDrawRoute(
      driverCurrentLocationLatLng, startLocationLatLng) async {
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            LoadingDialog(messageText: "Vui lòng đợi..."));

    //Lấy thông tin chuyến đi
    var tripDetailInfo = await CommonMethods.getDirectionDetailFromAPI(
        driverCurrentLocationLatLng, startLocationLatLng);

    // ignore: use_build_context_synchronously
    Navigator.pop(context);

    PolylinePoints pointPolyline = PolylinePoints();
    List<PointLatLng> pointLatLngList =
        pointPolyline.decodePolyline(tripDetailInfo!.encodedPoint!);

    //Xoá danh sách trong trường hợp chuyến cũ vẫn còn lưu lại
    polylineLatLngList.clear();

    if (pointLatLngList.isNotEmpty) {
      pointLatLngList.forEach((PointLatLng pointLatLng) {
        polylineLatLngList
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
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

    if (driverCurrentLocationLatLng.latitude > startLocationLatLng.latitude &&
        driverCurrentLocationLatLng.longitude > startLocationLatLng.longitude) {
      latLngBounds = LatLngBounds(
        southwest: startLocationLatLng,
        northeast: driverCurrentLocationLatLng,
      );
    } else if (driverCurrentLocationLatLng.longitude >
        startLocationLatLng.longitude) {
      latLngBounds = LatLngBounds(
        southwest: LatLng(
          driverCurrentLocationLatLng.latitude,
          startLocationLatLng.longitude,
        ),
        northeast: LatLng(
          startLocationLatLng.latitude,
          driverCurrentLocationLatLng.longitude,
        ),
      );
    } else if (driverCurrentLocationLatLng.latitude >
        startLocationLatLng.longitude) {
      latLngBounds = LatLngBounds(
        southwest: LatLng(
          startLocationLatLng.latitude,
          driverCurrentLocationLatLng.longitude,
        ),
        northeast: LatLng(
          driverCurrentLocationLatLng.latitude,
          startLocationLatLng.longitude,
        ),
      );
    } else {
      latLngBounds = LatLngBounds(
        southwest: driverCurrentLocationLatLng,
        northeast: startLocationLatLng,
      );
    }

    googleMapController!.animateCamera(
      CameraUpdate.newLatLngBounds(latLngBounds, 80),
    );

    //gán icon start và end
    Marker driverMarker = Marker(
      markerId: const MarkerId("driverMarkerId"),
      position: LatLng(pointLatLngList.first.latitude,
          pointLatLngList.first.longitude), //startLatLng,
      icon: driverMark!,
    );

    Marker startMarker = Marker(
      markerId: const MarkerId("startMarkerId"),
      position: LatLng(pointLatLngList.first.latitude,
          pointLatLngList.first.longitude), //startLatLng,
      icon: startMark!,
    );

    setState(() {
      markerSet.add(driverMarker);
      markerSet.add(startMarker);
    });
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
            myLocationEnabled: true,
            initialCameraPosition:
                CameraPosition(target: initialCurrentDriverLatLng!, zoom: 15),
            // target: LatLng(10.032433897900804, 105.7576156559728), zoom: 15),
            onMapCreated: (GoogleMapController mapController) async {
              googleMapController = mapController;
              completerGoogleMapController.complete(googleMapController);

              var driverCurrentLocationLatLng = LatLng(
                  driverCurrentPosition!.latitude,
                  driverCurrentPosition!.longitude);

              var startLocationLatLng = widget.newTripDetailInfo!.startLatLng;

              //lấy vị trí tài xế và vẽ đường đi
              await getDirectionAndDrawRoute(
                driverCurrentLocationLatLng,
                startLocationLatLng,
              );
            },
          ),
        ],
      ),
    );
  }
}
