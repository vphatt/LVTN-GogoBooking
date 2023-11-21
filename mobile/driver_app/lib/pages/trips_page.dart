import 'package:driver_app/global/global_var.dart';
import 'package:driver_app/utils/my_color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timelines/timelines.dart';

class TripsPage extends StatefulWidget {
  const TripsPage({super.key});

  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
  String driverIncome = "0";
  String number = "0";
  DatabaseReference tripCompletedRef =
      FirebaseDatabase.instance.ref().child("tripRequests");

  List tripCompleted = [];

  //Lấy thông tin của những chuyến đã hoàn thành
  getInfoOfCompletedTrips() async {
    DatabaseReference tripRequestRef =
        FirebaseDatabase.instance.ref().child("tripRequests");
    //Lấy tổng số chuyến được yêu cầu, tại đây lấy cả chuyến của tài xế khác
    await tripRequestRef.once().then(
      (snap) async {
        if (snap.snapshot.value != null) {
          Map allTripMap = snap.snapshot.value as Map;

          // int allTripNumber = allTripMap.length;

          //Lọc ra những chuyến đã hoàn thành của tài xế hiện tại
          List completedTripsOfCurrentDriver = [];

          allTripMap.forEach((key, value) {
            if (value["status"] != "initial" &&
                value["status"] == "ended" &&
                value["driverId"] == FirebaseAuth.instance.currentUser!.uid) {
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

  //lấy tổng doanh thu
  getIncomeOfCurrentDriver() async {
    DatabaseReference currentDriverRef =
        FirebaseDatabase.instance.ref().child("drivers");

    await currentDriverRef
        .child(FirebaseAuth.instance.currentUser!.uid)
        .once()
        .then((snap) {
      if ((snap.snapshot.value as Map)["incomes"] != null) {
        setState(() {
          driverIncome = ((snap.snapshot.value as Map)["incomes"]).toString();
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getInfoOfCompletedTrips();
    getIncomeOfCurrentDriver();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
          body: Container(
        height: double.infinity,
        color: MyColor.green,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                width: screenSize.width / 1.5,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: MyColor.white,
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    const Text(
                      "Tổng thu nhập",
                      style: TextStyle(color: MyColor.black),
                    ),
                    Text(
                      "${formatVND.format(double.parse(driverIncome))} VNĐ",
                      style: const TextStyle(
                          color: MyColor.green,
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenSize.width / 20),
              child: Row(
                children: [
                  const Text(
                    "Số chuyển đã hoàn thành: ",
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

                //Lấy toàn bộ dữ liệu chuyến đi
                // Map dataTrips = snapshotData.data!.snapshot.value as Map;
                // List dataTripsList = [];
                // dataTrips.forEach((key, value) =>
                //     dataTripsList.add({"key": key, ...dataTrips}));
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: tripCompleted.length,
                    itemBuilder: ((context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: InkWell(
                          onTap: () {
                            List detail = tripCompleted[index];
                          },
                          child: Card(
                              elevation: 5,
                              surfaceTintColor: MyColor.grey,
                              child: Wrap(
                                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    //flex: 3,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: screenSize.width / 30,
                                          vertical: screenSize.width / 50),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            DateFormat("kk:mm - dd/MM/yyyy")
                                                .format(DateTime.parse(
                                                    tripCompleted[index]
                                                        ['requestDateTime'])),
                                            style: const TextStyle(
                                                color: MyColor.green,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            "${formatVND.format(double.parse(tripCompleted[index]['actualFareAmount'].toString()))} đ",
                                            style: const TextStyle(
                                                color: MyColor.red,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
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
                                              tripCompleted[index]['endAddress']
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
                              )),
                        ),
                      );
                    }));
              },
            )),
          ],
        ),
      )),
    );
  }
}
