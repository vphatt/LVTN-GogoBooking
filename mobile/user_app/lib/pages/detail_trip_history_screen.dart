import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../global/global_var.dart';
import '../utils/my_color.dart';

class DetailTripHistoryScreen extends StatefulWidget {
  const DetailTripHistoryScreen({super.key, required this.tripId});

  final String? tripId;

  @override
  State<DetailTripHistoryScreen> createState() =>
      _DetailTripHistoryScreenState();
}

class _DetailTripHistoryScreenState extends State<DetailTripHistoryScreen> {
  // var tripDetail;
  String actualDistanceMoved = "";
  String distance = "";
  double actualFareAmount = 0.0;
  String carDetail = "";
  String driverName = "";
  String driverPhone = "";
  String endAddress = "";
  String comment = "";
  double rateStar = 0.0;
  String requestDateTime = "";
  String startAddress = "";

  getDetailTrip() async {
    DatabaseReference tripDetailRef = FirebaseDatabase.instance
        .ref()
        .child("tripRequests")
        .child(widget.tripId!);

    await tripDetailRef.once().then((snap) {
      setState(() {
        actualDistanceMoved =
            (snap.snapshot.value as Map)['actualDistanceMoved'].toString();
        distance = (snap.snapshot.value as Map)['distance'].toString();
        actualFareAmount = double.parse(
            (snap.snapshot.value as Map)['actualFareAmount'].toString());
        carDetail = (snap.snapshot.value as Map)['carDetail'].toString();

        driverName = (snap.snapshot.value as Map)['driverName'].toString();
        driverPhone = (snap.snapshot.value as Map)['driverPhone'].toString();
        endAddress = (snap.snapshot.value as Map)['endAddress'].toString();
        comment = (snap.snapshot.value as Map)['rating']['comment'].toString();
        rateStar = double.parse(
            (snap.snapshot.value as Map)['rating']['rateStar'].toString());
        requestDateTime =
            (snap.snapshot.value as Map)['requestDateTime'].toString();
        startAddress = (snap.snapshot.value as Map)['startAddress'].toString();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getDetailTrip();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return SafeArea(
        child: SelectionArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 70,
          elevation: 0.0,
          iconTheme: const IconThemeData(color: MyColor.white),
          centerTitle: true,
          title: const Text(
            'Chi tiết chuyến xe',
            style: TextStyle(color: MyColor.white),
          ),
          backgroundColor: MyColor.green,
        ),
        body: Container(
          padding: const EdgeInsets.all(10),
          child: SelectionArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      "THÔNG TIN TÀI XẾ",
                      style: TextStyle(
                        fontSize: screenSize.width / 23,
                        fontWeight: FontWeight.bold,
                        color: MyColor.green,
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Tên tài xế:",
                      style: TextStyle(fontSize: screenSize.width / 25),
                    ),
                    trailing: Text(
                      driverName,
                      style: TextStyle(
                          fontSize: screenSize.width / 25,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Số điện thoại tài xế:",
                      style: TextStyle(fontSize: screenSize.width / 25),
                    ),
                    trailing: Text(
                      driverPhone,
                      style: TextStyle(
                          fontSize: screenSize.width / 25,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Biển số xe:",
                      style: TextStyle(fontSize: screenSize.width / 25),
                    ),
                    trailing: Text(
                      carDetail,
                      style: TextStyle(
                          fontSize: screenSize.width / 25,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: Text(
                      "THÔNG TIN CHUYẾN XE",
                      style: TextStyle(
                        fontSize: screenSize.width / 23,
                        fontWeight: FontWeight.bold,
                        color: MyColor.green,
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "ID chuyến:",
                      style: TextStyle(fontSize: screenSize.width / 25),
                    ),
                    trailing: Text(
                      widget.tripId!,
                      style: TextStyle(
                          fontSize: screenSize.width / 25,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Ngày yêu cầu:",
                      style: TextStyle(fontSize: screenSize.width / 25),
                    ),
                    trailing: Text(
                      DateFormat("kk:mm - dd/MM/yyyy")
                          .format(DateTime.parse(requestDateTime)),
                      style: TextStyle(
                          fontSize: screenSize.width / 25,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Điểm đón:",
                      style: TextStyle(fontSize: screenSize.width / 25),
                    ),
                    visualDensity: const VisualDensity(vertical: 4),
                    trailing: SizedBox(
                      width: screenSize.width / 2,
                      child: SingleChildScrollView(
                        child: Text(
                          startAddress,
                          softWrap: true,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              fontSize: screenSize.width / 25,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Điểm trả:",
                      style: TextStyle(fontSize: screenSize.width / 25),
                    ),
                    visualDensity: const VisualDensity(vertical: 4),
                    trailing: SizedBox(
                      width: screenSize.width / 2,
                      child: SingleChildScrollView(
                        child: Text(
                          endAddress,
                          softWrap: true,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              fontSize: screenSize.width / 25,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Khoảng cách:",
                      style: TextStyle(fontSize: screenSize.width / 25),
                    ),
                    trailing: Text(
                      distance,
                      style: TextStyle(
                          fontSize: screenSize.width / 25,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Quảng đường đã đi:",
                      style: TextStyle(fontSize: screenSize.width / 25),
                    ),
                    trailing: Text(
                      actualDistanceMoved,
                      style: TextStyle(
                          fontSize: screenSize.width / 25,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Tổng tiền trả:",
                      style: TextStyle(fontSize: screenSize.width / 25),
                    ),
                    trailing: Text(
                      "${formatVND.format(actualFareAmount)} VNĐ",
                      style: TextStyle(
                          fontSize: screenSize.width / 25,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: MyColor.red),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: Text(
                      "ĐÁNH GIÁ",
                      style: TextStyle(
                        fontSize: screenSize.width / 23,
                        fontWeight: FontWeight.bold,
                        color: MyColor.green,
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Số sao: ",
                      style: TextStyle(fontSize: screenSize.width / 25),
                    ),
                    trailing: Text(
                      rateStar != 0 ? "$rateStar ⭐" : "Bị xoá bởi Admin",
                      style: TextStyle(
                          fontSize: screenSize.width / 25,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Nhận xét: ",
                      style: TextStyle(fontSize: screenSize.width / 25),
                    ),
                    visualDensity: const VisualDensity(vertical: 4),
                    trailing: SizedBox(
                      width: screenSize.width / 2,
                      child: SingleChildScrollView(
                        child: Text(
                          comment == "deletedByAdmin"
                              ? "Bị xoá bởi Admin"
                              : comment.isNotEmpty
                                  ? comment
                                  : "Không có nhận xét",
                          softWrap: true,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              fontSize: screenSize.width / 25,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }
}
