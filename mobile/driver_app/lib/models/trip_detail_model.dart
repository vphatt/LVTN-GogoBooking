import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripDetailModel {
  String? tripId;
  String? userName;
  String? userPhone;
  String? distanceFromDriverToStart;
  String? startAddress;
  String? endAddress;
  LatLng? startLatLng;
  LatLng? endLatLng;
  String? distanceFromStartToEnd;
  String? tripPrice;

  TripDetailModel({
    this.tripId,
    this.userName,
    this.userPhone,
    this.startAddress,
    this.endAddress,
    this.startLatLng,
    this.endLatLng,
    this.distanceFromStartToEnd,
    this.tripPrice,
  });
}
