import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timelines/timelines.dart';
import 'package:user_app/pages/detail_trip_history_screen.dart';

import '../global/global_var.dart';
import '../utils/my_color.dart';

class HistoryTripPage extends StatefulWidget {
  const HistoryTripPage({super.key});

  @override
  State<HistoryTripPage> createState() => _HistoryTripPageState();
}

class _HistoryTripPageState extends State<HistoryTripPage> {
  String driverIncome = "0";
  String number = "0";
  DatabaseReference tripCompletedRef =
      FirebaseDatabase.instance.ref().child("tripRequests");

  List tripCompleted = [];

  String requestDateTime = "";
  double actualFareAmount = 0.0;

  //Lấy thông tin của những chuyến đã hoàn thành
  getInfoOfCompletedTrips() async {
    //Lấy tổng số chuyến được yêu cầu, tại đây lấy cả chuyến của tài xế khác
    await tripCompletedRef.orderByChild("requestDateTime").once().then(
      (snap) async {
        if (snap.snapshot.value != null) {
          Map allTripMap = snap.snapshot.value as Map;

          // int allTripNumber = allTripMap.length;

          //Lọc ra những chuyến đã hoàn thành của tài xế hiện tại
          List completedTripsOfCurrentDriver = [];

          allTripMap.forEach((key, value) {
            if (value["status"] == "ended" &&
                value["userId"] == FirebaseAuth.instance.currentUser!.uid) {
              completedTripsOfCurrentDriver.add({"key": key, ...value});
            }
          });

          setState(() {
            number = completedTripsOfCurrentDriver.length.toString();
            tripCompleted = completedTripsOfCurrentDriver;
          });
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getInfoOfCompletedTrips();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 70,
          elevation: 0.0,
          iconTheme: const IconThemeData(color: MyColor.white),
          centerTitle: true,
          title: const Text(
            'Lịch sử đặt xe',
            style: TextStyle(color: MyColor.white),
          ),
          backgroundColor: MyColor.green,
        ),
        body: Container(
          height: double.infinity,
          color: MyColor.green,
          child: Column(
            children: [
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: screenSize.width / 20),
                child: Row(
                  children: [
                    const Text(
                      "Số chuyển đã đặt: ",
                      style: TextStyle(color: MyColor.white),
                    ),
                    Text(
                      number,
                      style: const TextStyle(
                          color: MyColor.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ],
                ),
              ),
              const Divider(
                color: MyColor.green,
                indent: 30,
                endIndent: 30,
              ),
              Expanded(
                child: StreamBuilder(
                  stream: tripCompletedRef.onValue,
                  builder: (BuildContext context, snapshotData) {
                    if (snapshotData.hasError) {
                      return const Center(
                        child: Text(
                          "Có lỗi xảy ra!",
                          style: TextStyle(color: MyColor.red),
                        ),
                      );
                    }

                    if (!(snapshotData.hasData)) {
                      return const Center(
                        child: Text(
                          "Bạn chưa có hoạt động nào",
                          style: TextStyle(color: MyColor.green),
                        ),
                      );
                    }

                    if (snapshotData.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: MyColor.white,
                        ),
                      );
                    }

                    //Lấy toàn bộ dữ liệu chuyến đi
                    // Map dataTrips = snapshotData.data!.snapshot.value as Map;
                    // List dataTripsList = [];
                    // dataTrips.forEach((key, value) =>
                    //     dataTripsList.add({"key": key, ...dataTrips}));
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: tripCompleted.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: ((context, index) {
                        if (tripCompleted.isNotEmpty) {
                          requestDateTime = DateFormat("kk:mm - dd/MM/yyyy")
                              .format(DateTime.parse(
                                  tripCompleted[index]['requestDateTime']));

                          actualFareAmount = double.parse(tripCompleted[index]
                                  ['actualFareAmount']
                              .toString());

                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          DetailTripHistoryScreen(
                                              tripId: tripCompleted[index]
                                                      ["tripId"]
                                                  .toString())));
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Card(
                                elevation: 5,
                                surfaceTintColor: MyColor.grey,
                                child: Column(
                                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: screenSize.width / 30,
                                          vertical: screenSize.width / 50),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            requestDateTime,
                                            style: const TextStyle(
                                                color: MyColor.green,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            "${formatVND.format(actualFareAmount)} VNĐ",
                                            style: const TextStyle(
                                                color: MyColor.red,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),

                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: screenSize.width / 20),
                                      child: Column(
                                        children: [
                                          //Điểm đón khách
                                          TimelineTile(
                                            nodePosition: 0,
                                            contents: Container(
                                              padding: EdgeInsets.all(
                                                  screenSize.height / 90),
                                              child: Text(
                                                tripCompleted[index]
                                                        ['startAddress']
                                                    .toString(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: MyColor.black,
                                                  fontSize:
                                                      screenSize.height / 60,
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
                                            ),
                                          ),

                                          //Điểm trả khách
                                          TimelineTile(
                                            nodePosition: 0,
                                            contents: Container(
                                              padding: EdgeInsets.all(
                                                  screenSize.height / 90),
                                              child: Text(
                                                tripCompleted[index]
                                                        ['endAddress']
                                                    .toString(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: MyColor.black,
                                                  fontSize:
                                                      screenSize.height / 60,
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
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    //Spacer(),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                        return null;
                      }),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
