import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:driver_app/global/global_var.dart';
import 'package:driver_app/models/direction_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:driver_app/utils/my_color.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:http/http.dart' as http;

class CommonMethods {
  //Kiểm tra internet của thiết bị, để xem thiết bị có kết nối
  //với wifi hoặc mạng di động (3G/4G/5G) hay không
  checkConnectivity(BuildContext context) async {
    var connectionResult = await Connectivity().checkConnectivity();

    if (connectionResult != ConnectivityResult.wifi &&
        connectionResult != ConnectivityResult.mobile) {
      if (!context.mounted) return;
      // ignore: use_build_context_synchronously
      displaySnackbar("Không có kết nối Internet. Vui lòng thử lại!", context);
    }
  }

  //hiện thị snackBar thông báo
  displaySnackbar(String message, BuildContext context) {
    var snackBar = SnackBar(
      backgroundColor: MyColor.white,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(30),
      padding: const EdgeInsets.all(20),
      elevation: 10,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(5),
        ),
      ),
      content: Text(
        message,
        style: const TextStyle(color: MyColor.black),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  //Tắt cập nhật vị trí của tài xế tại trang chủ
  //Mục đích để khi tài xế chấp nhận 1 yêu cầu, những khách hàng khác sẽ không tìm đc tài xế này
  //Có nghĩa là tài xế này đang bận và không thể nhận thêm bất kỳ yêu cầu nào nữa đến khi kết thúc chuyến hiện tại
  disableUpdateLocationDriver() {
    positionStreamHomePage!.pause();
    Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid);
  }

  //Bật cập nhật vị trí tài xế tại trang chủ
  enableUpdateLocationDriver() {
    positionStreamHomePage!.resume();
    Geofire.setLocation(
      FirebaseAuth.instance.currentUser!.uid,
      driverCurrentPositionGB!.latitude,
      driverCurrentPositionGB!.longitude,
    );
  }

  //Gửi yêu cầu đến GeoGraphic API
  static sendRequestToAPI(String apiUrl) async {
    http.Response responseFromAPI = await http.get(Uri.parse(apiUrl));

    try {
      if (responseFromAPI.statusCode == 200) {
        String dataFromAPI = responseFromAPI.body;
        var dataFromAPIDecode = jsonDecode(dataFromAPI);
        return dataFromAPIDecode;
      } else {
        return "error";
      }
    } catch (errMsg) {
      return "error";
    }
  }

  //Direction API
  static Future<DirectionModel?> getDirectionDetailFromAPI(
      LatLng start, LatLng end) async {
    String directionAPIUrl =
        "https://rsapi.goong.io/Direction?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&vehicle=car&api_key=$goongMapKey";

    var responseFromDirectionAPI = await sendRequestToAPI(directionAPIUrl);

    if (responseFromDirectionAPI == "error") {
      return null;
    } else {
      DirectionModel directionModel = DirectionModel();
      directionModel.distanceText =
          responseFromDirectionAPI["routes"][0]["legs"][0]["distance"]["text"];
      directionModel.distanceValue =
          responseFromDirectionAPI["routes"][0]["legs"][0]["distance"]["value"];
      directionModel.durationText =
          responseFromDirectionAPI["routes"][0]["legs"][0]["duration"]["text"];
      directionModel.durationValue =
          responseFromDirectionAPI["routes"][0]["legs"][0]["duration"]["value"];
      directionModel.encodedPoint =
          responseFromDirectionAPI["routes"][0]["overview_polyline"]["points"];

      return directionModel;
    }
  }

// DatabaseReference fareTripRef =
//         FirebaseDatabase.instance.ref().child("fareTrip");
  //Tính tiền xe
  calculateFareAmount(DirectionModel directionModel) {
    // fareTripRef.once().then((snap) {
    //   openDoorAmount =
    //       double.parse((snap.snapshot.value! as Map)["openDoor"].toString());
    //   distancePerKmUnder30Amount =
    //       double.parse((snap.snapshot.value! as Map)["under30km"].toString());
    //   distancePerKmOver30Amount =
    //       double.parse((snap.snapshot.value! as Map)["over30km"].toString());
    // });

    double fareAmount = 0;
    if ((directionModel.distanceValue! / 1000) <= 1) {
      fareAmount = openDoorAmount;
    } else if ((directionModel.distanceValue! / 1000) > 1 &&
        (directionModel.distanceValue! / 1000) <= 30) {
      fareAmount =
          (directionModel.distanceValue! / 1000) * distancePerKmUnder30Amount;
    } else {
      fareAmount = (30 * distancePerKmUnder30Amount) +
          ((directionModel.distanceValue! / 1000) * distancePerKmOver30Amount);
    }

    return fareAmount;
  }
}
