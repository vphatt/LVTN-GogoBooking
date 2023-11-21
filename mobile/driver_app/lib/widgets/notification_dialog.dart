import 'dart:async';

import 'package:driver_app/global/global_var.dart';
import 'package:driver_app/methods/common_methods.dart';
import 'package:driver_app/models/trip_detail_model.dart';
import 'package:driver_app/pages/new_trip_page.dart';
import 'package:driver_app/widgets/loading_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:timelines/timelines.dart';

import '../utils/my_color.dart';

class NotificationDialog extends StatefulWidget {
  final TripDetailModel? tripDetailModel;
  const NotificationDialog({
    super.key,
    this.tripDetailModel,
  });

  @override
  State<NotificationDialog> createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<NotificationDialog> {
  //Lấy vị trí hiện tại của tài xế
  // Position? currentPositionOfDriver;

  // getCurrentLocationDriver() async {
  //   Position positionOfDriver = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.bestForNavigation);
  //   currentPositionOfDriver = positionOfDriver;

  //   LatLng latLngPositionOfDriver = LatLng(
  //       currentPositionOfDriver!.latitude, currentPositionOfDriver!.longitude);
  // }

  //Trạng thái của yêu cầu
  String tripRequestStatus = "initial";
  CommonMethods cMethods = CommonMethods();

  //Huỷ thông báo sau 30s không phản hồi
  int requestTimeOut = 30;
  autoCancelNotificationDialogAfter30s() {
    // ignore: unused_local_variable
    var countDown = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (tripRequestStatus == "accepted") {
        timer.cancel();
        requestTimeOut = 30;
      }
      if (requestTimeOut == 0) {
        Navigator.pop(context);
        timer.cancel();
        requestTimeOut = 30;
        notificationSound.stop();
      } else {
        setState(() {
          requestTimeOut--;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    autoCancelNotificationDialogAfter30s();
  }

  //KIểm tra tính khả dụng của chuyến đi
  checkAvailabilityOfTripRequest(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: "Vui lòng đợi..."),
    );
    DatabaseReference driverTripStatusRef = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("newTripStatus");

    await driverTripStatusRef.once().then((snap) {
      //Đóng liên tiếp 2 dialog
      Navigator.pop(context);
      Navigator.pop(context);

      String newTripStatusValue = "";
      if (snap.snapshot.value != null) {
        newTripStatusValue = snap.snapshot.value.toString();
      } else {
        cMethods.displaySnackbar("Không tìm thấy yêu cầu!", context);
      }

      if (newTripStatusValue == widget.tripDetailModel!.tripId) {
        driverTripStatusRef.set("accepted");

        ///Không cập nhật vị trí của tài xế tại trang chủ
        //cMethods.disableUpdateLocationDriver();

        ///Sau khi chấp nhận yêu cầu, tài xế sẽ chuyển đến trang Chuyến đi
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (c) =>
                    NewTripPage(newTripDetailInfo: widget.tripDetailModel)));

        ///Trang Chuyến đi sẽ hiện thị vị trí của tài xế và vẽ đường đi từ tài xế đến điểm đón
        ///Và vẽ đường từ điểm đón đến điểm trả, cập nhật lộ trình theo thời gian thực
      } else if (newTripStatusValue == "cancelled") {
        cMethods.displaySnackbar("Yêu cầu đã bị huỷ bởi Khách hàng!", context);
      } else if (newTripStatusValue == "timeout") {
        cMethods.displaySnackbar("Yêu cầu hết hạn!", context);
      } else {
        cMethods.displaySnackbar("Không có yêu cầu!", context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.all(20),
      //height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        color: MyColor.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: screenSize.height / 50),
            child: Text(
              "BẠN CÓ YÊU CẦU MỚI",
              style: TextStyle(
                color: MyColor.green,
                fontSize: screenSize.height / 50,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenSize.width / 20),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.tripDetailModel!.userName.toString(),
                      style: TextStyle(
                        color: MyColor.black,
                        fontSize: screenSize.height / 60,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  "${formatVND.format(double.parse(widget.tripDetailModel!.tripPrice.toString()))} đ (dự tính)",
                  style: TextStyle(
                    color: MyColor.black,
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
            padding: EdgeInsets.symmetric(horizontal: screenSize.width / 20),
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
                      widget.tripDetailModel!.startAddress.toString(),
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
                  nodePosition: 0.2,
                  node: TimelineNode(
                    indicator: Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(widget
                            .tripDetailModel!.distanceFromStartToEnd
                            .toString()),
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
                      widget.tripDetailModel!.endAddress.toString(),
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
          Padding(
            padding: EdgeInsets.only(
                left: screenSize.width / 20,
                right: screenSize.width / 20,
                bottom: screenSize.width / 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      notificationSound.stop();
                    },
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          width: 2,
                          color: MyColor.green,
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                    child: Padding(
                      padding: const EdgeInsets.all(1),
                      child: Text(
                        "TỪ CHỐI",
                        style: TextStyle(
                            fontSize: screenSize.height / 65,
                            fontWeight: FontWeight.bold,
                            color: MyColor.green),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      notificationSound.stop();

                      setState(() {
                        tripRequestStatus = "accepted";

                        //Kiểm tra tính khả dụng của yêu cầu, chắc chắn rằng người dùng chưa huỷ yêu cầu đó
                        checkAvailabilityOfTripRequest(context);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: MyColor.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                    child: Padding(
                      padding: const EdgeInsets.all(1),
                      child: Text(
                        "CHẤP NHẬN ($requestTimeOut)",
                        style: TextStyle(
                            fontSize: screenSize.height / 65,
                            fontWeight: FontWeight.bold,
                            color: MyColor.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
