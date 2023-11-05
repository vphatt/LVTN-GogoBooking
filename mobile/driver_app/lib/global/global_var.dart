import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

String userNameGB = '';
String flutterURL =
    "https://gogobooking-5ade1-default-rtdb.asia-southeast1.firebasedatabase.app";
String googleMapKey = "AIzaSyBBe_0Hm2yhj1kjBr1swX8l51hQgI4r6PQ";

String goongMapKey = "H6kU854UuaIgC8OnW0Dh8K2cVGjl9PbQEUPpjWQr";

const CameraPosition googleMapInitialPosition = CameraPosition(
  target: LatLng(9.614758, 105.973307),
  zoom: 15,
);

StreamSubscription<Position>? positionStreamHomePage;

LatLng? initialCurrentDriverLatLng;
