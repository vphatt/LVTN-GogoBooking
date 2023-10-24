import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:driver_app/utils/my_color.dart';

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
}
