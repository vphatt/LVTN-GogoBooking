import 'dart:async';

import 'package:driver_app/models/trip_detail_model.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  Position? currentPositionOfDriver;

  getCurrentLocationDriver() async {
    Position positionOfDriver = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionOfDriver = positionOfDriver;

    LatLng latLngPositionOfDriver = LatLng(
        currentPositionOfDriver!.latitude, currentPositionOfDriver!.longitude);
  }

  //Trạng thái của yêu cầu
  String tripRequestStatus = "initial";

  //Huỷ thông báo sau 30s không phản hồi
  int requestTimeOut = 30;
  autoCancelNotificationDialogAfter30s() {
    var countDown = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (tripRequestStatus == "accepted") {
        timer.cancel();
        requestTimeOut = 30;
      }
      if (requestTimeOut == 0) {
        Navigator.pop(context);
        timer.cancel();
        requestTimeOut = 30;
      } else {
        setState(() {
          requestTimeOut--;
        });
      }
    });
  }

  @override
  void initState() {
    autoCancelNotificationDialogAfter30s();
    super.initState();
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
                  "30.000 đ",
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
                //Vị trí hiện tại của tài xế
                TimelineTile(
                  nodePosition: 0.2,
                  oppositeContents: Text(
                    'Hiện tại ',
                    style: TextStyle(
                      color: MyColor.green,
                      fontSize: screenSize.height / 70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  contents: Container(
                    padding: EdgeInsets.all(screenSize.height / 90),
                    child: Text(
                      'contentssss',
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
                        Icons.car_repair,
                        color: MyColor.blue,
                      ),
                    ),
                    endConnector: DashedLineConnector(
                      color: MyColor.blue,
                    ),
                  ),
                ),

                //Khoảng cách từ tài xế đến điểm đón
                TimelineTile(
                  nodePosition: 0.2,
                  node: const TimelineNode(
                    indicator: Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('200 m'),
                      ),
                    ),
                  ),
                ),

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
                    startConnector: DashedLineConnector(
                      color: MyColor.blue,
                    ),
                    endConnector: SolidLineConnector(
                      color: MyColor.green,
                    ),
                  ),
                ),

                //Khoảng cách từ điểm đón khách đến điểm trả khách
                TimelineTile(
                  nodePosition: 0.2,
                  node: const TimelineNode(
                    indicator: Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('6 km'),
                      ),
                    ),
                    startConnector: DashedLineConnector(),
                    endConnector: SolidLineConnector(),
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
                    },
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          width: 2,
                          color: MyColor.green,
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        "TỪ CHỐI",
                        style: TextStyle(
                            fontSize: screenSize.height / 60,
                            fontWeight: FontWeight.bold,
                            color: MyColor.green),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        tripRequestStatus = "accepted";
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: MyColor.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        "CHẤP NHẬN ($requestTimeOut)",
                        style: TextStyle(
                            fontSize: screenSize.height / 60,
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
