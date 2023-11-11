import 'dart:async';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

//Tên tài xế đăng nhập
String driverNameGB = '';

//URL của firebase
String flutterURL =
    "https://gogobooking-5ade1-default-rtdb.asia-southeast1.firebasedatabase.app";

//Google Maps API KEY
//Sử dụng cho việc hiện thị bản đồ
String googleMapKey = "AIzaSyBBe_0Hm2yhj1kjBr1swX8l51hQgI4r6PQ";

//Goong Maps API KEY
//Sử dụng cho việc lấy vị trí, vẽ đường, tính khoảng cách, tìm kiếm địa điểm,...
String goongMapKey = "H6kU854UuaIgC8OnW0Dh8K2cVGjl9PbQEUPpjWQr";

//Dùng cho cập nhật vị trí tài xế theo thời gian thực
StreamSubscription<Position>? positionStreamHomePage;

//Dùng cho cập nhật vị trí tài xế theo thời gian thực tại trang newtrip
StreamSubscription<Position>? positionStreamNewTripPage;

//Lưu vị trí hiện tại của tài xế
Position? driverCurrentPositionGB;
LatLng? driverCurrentLatLngGB;

//Lấy toạ độ của tài xế khi vừa mở app
LatLng? initialCurrentDriverLatLng =
    const LatLng(10.032433897900804, 105.7576156559728);

//Âm thanh
final notificationSound = AssetsAudioPlayer();
