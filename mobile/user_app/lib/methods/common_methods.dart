import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:user_app/models/address_model.dart';
import 'package:user_app/models/direction_model.dart';
import 'package:user_app/utils/app_info.dart';
import 'package:user_app/utils/my_color.dart';
import 'package:user_app/widgets/loading_dialog.dart';
import '../global/global_var.dart';
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

  //Chuyển đổi địa điểm toạ độ sang dạng phổ thông (đường, phường, phố,...)
  static Future<String> convertCoordinateToAddress(
      BuildContext context, Position position) async {
    String addressCoverted = "";
    String apiUrl =
        "https://rsapi.goong.io/Geocode?latlng=${position.latitude},${position.longitude}&api_key=$goongMapKey";

    var responseFromAPI = await sendRequestToAPI(apiUrl);

    if (responseFromAPI != "error") {
      addressCoverted = responseFromAPI["results"][0]["formatted_address"];

      AddressModel addressModel = AddressModel();
      addressModel.addressCoverted = addressCoverted;
      addressModel.latitude = position.latitude;
      addressModel.longitude = position.longitude;

      // ignore: use_build_context_synchronously
      Provider.of<AppInfo>(context, listen: false)
          .updateStartLocation(addressModel);

      //print("ĐỊAAAAAAAAAA CHỈIIIIIIIII: $addressCoverted");
    }
    return addressCoverted;
  }

  //Lấy placeID
  static Future<String> getCurrentPlaceID(
      BuildContext context, Position position) async {
    String placeId = "";
    String apiUrl =
        "https://rsapi.goong.io/Geocode?latlng=${position.latitude},${position.longitude}&api_key=$goongMapKey";

    var responseFromAPI = await sendRequestToAPI(apiUrl);

    if (responseFromAPI != "error") {
      placeId = responseFromAPI["results"][0]["place_id"];
    }
    return placeId;
  }

  //Lấy thông tin địa điểm hiện tại
  static placeCurrentDetail(BuildContext context, String placeId) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: "Đang lấy vị trí của bạn..."),
    );

    String urlPlaceDetail =
        "https://rsapi.goong.io/Place/Detail?place_id=$placeId&api_key=$goongMapKey";

    var responseFromPlaceAPI =
        await CommonMethods.sendRequestToAPI(urlPlaceDetail);

    // ignore: use_build_context_synchronously
    Navigator.pop(context);

    if (responseFromPlaceAPI == "error") {
      return;
    }
    if (responseFromPlaceAPI["status"] == "OK") {
      AddressModel address = AddressModel();

      address.addressId = placeId;
      address.addressName = responseFromPlaceAPI["result"]["name"];
      address.addressCoverted =
          responseFromPlaceAPI["result"]["formatted_address"];
      address.latitude =
          responseFromPlaceAPI["result"]["geometry"]["location"]["lat"];
      address.longitude =
          responseFromPlaceAPI["result"]["geometry"]["location"]["lng"];

      //Provider.of<AppInfo>(context, listen: false).updateStartLocation(address);
      // ignore: use_build_context_synchronously
      Provider.of<AppInfo>(context, listen: false).updateStartLocation(address);
      //Navigator.pop(context, "placeSelected");
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
      directionModel.startAddress =
          responseFromDirectionAPI["routes"][0]["legs"][0]["start_address"];
      directionModel.endAddress =
          responseFromDirectionAPI["routes"][0]["legs"][0]["end_address"];

      return directionModel;
    }
  }

  //Tính tiền xe
  calculateFareAmount(DirectionModel directionModel) {
    double distancePerKmUnder30Amount =
        11000; //Giá xe khi quãng đường dưới 30km
    double openDoorAmount = 9000; //Giá mở cửa
    double distancePerKmOver30Amount = 9500; //Giá xe khi quãng đường trên 30km

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
    final format = NumberFormat("#########");
    return format.format(fareAmount);
  }
}
