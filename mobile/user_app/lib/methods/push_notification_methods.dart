import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_app/global/global_var.dart';
import 'package:user_app/utils/app_info.dart';
import 'package:http/http.dart' as http;

class PushNotificationMethods {
  static sendNotificationToNearestSelectedDriver(
      BuildContext context, String deviceToken, String tripId) async {
    String endAddress = Provider.of<AppInfo>(context, listen: false)
        .endLocation!
        .addressName
        .toString();
    String startAddress = Provider.of<AppInfo>(context, listen: false)
        .startLocation!
        .addressName
        .toString();

    //Xác định thông báo
    Map<String, String> headerNotificationMap = {
      "Content-Type": "application/json",
      "Authorization": serverKeyFCM,
    };

    //Nội dung thông báo
    Map notificationContentMap = {
      "title": "BẠN CÓ YÊU CẦU MỚI",
      "body": 'Từ: "$startAddress"\nĐến: "$endAddress"',
    };

    Map dataMapNotification = {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done",
      "tripId": tripId,
    };

    Map bodyNotificationMap = {
      "notification": notificationContentMap,
      "data": dataMapNotification,
      "priority": "high",
      "to": deviceToken,
    };

    await http.post(
      Uri.parse("https://fcm.googleapis.com/fcm/send"),
      headers: headerNotificationMap,
      body: jsonEncode(bodyNotificationMap),
    );
  }
}
