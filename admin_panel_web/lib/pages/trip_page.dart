import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../methods/common_methods.dart';
import '../utils/global_var.dart';
import '../utils/my_color.dart';
import '../widgets/trip_data_list.dart';

class TripPage extends StatefulWidget {
  static const String id = "pageTrip";
  const TripPage({super.key});

  @override
  State<TripPage> createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> {
  int countTrip = 0;
  int completedTrip = 0;
  int onTrip = 0;
  getAllTrip() async {
    //Lấy tất cả tài xế
    DatabaseReference tripRef =
        // ignore: deprecated_member_use
        FirebaseDatabase(databaseURL: flutterURL).ref().child("tripRequests");

    await tripRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        Map dataMap = snap.snapshot.value as Map;

        List dataList = [];

        dataMap.forEach((key, value) {
          dataList.add({
            "key": key,
            ...value,
          });
        });

        setState(() {
          countTrip = dataList.length;
        });
      }
    });
  }

  getCompletedTrip() async {
    //Lấy tất cả tài xế
    DatabaseReference tripRef =
        // ignore: deprecated_member_use
        FirebaseDatabase(databaseURL: flutterURL).ref().child("tripRequests");

    await tripRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        Map dataMap = snap.snapshot.value as Map;

        List dataList = [];

        dataMap.forEach((key, value) {
          if (value['status'] == "ended") {
            dataList.add({
              "key": key,
              ...value,
            });
          }
        });

        // for (var data in dataList) {
        //   if (data["status"] != "ended") {
        //     dataList.remove(data);
        //   }
        // }
        setState(() {
          completedTrip = dataList.length;
        });
      }
    });
  }

  getOnTrip() async {
    //Lấy tất cả tài xế
    DatabaseReference tripRef =
        // ignore: deprecated_member_use
        FirebaseDatabase(databaseURL: flutterURL).ref().child("tripRequests");

    await tripRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        Map dataMap = snap.snapshot.value as Map;

        List dataList = [];

        dataMap.forEach((key, value) {
          if (value['status'] == "onTrip") {
            dataList.add({
              "key": key,
              ...value,
            });
          }
        });

        // for (var data in dataList) {
        //   if (data["status"] != "onTrip") {
        //     dataList.remove(data);
        //   }
        // }

        setState(() {
          onTrip = dataList.length;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getOnTrip();
    getAllTrip();
    getCompletedTrip();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: SelectionArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Wrap(
                  children: [
                    Container(
                      height: 70,
                      width: 250,
                      decoration: BoxDecoration(
                          color: MyColor.green,
                          borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Center(
                          child: Text(
                            "Số chuyến: $countTrip",
                            style: const TextStyle(
                                color: MyColor.white, fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                      height: 70,
                      width: 250,
                      decoration: BoxDecoration(
                          color: MyColor.yellowDark,
                          borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Center(
                          child: Text(
                            "Đã hoàn thành: $completedTrip",
                            style: const TextStyle(
                                color: MyColor.white, fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                      height: 70,
                      width: 250,
                      decoration: BoxDecoration(
                          color: MyColor.rose,
                          borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Center(
                          child: Text(
                            "Đang thực hiện: $onTrip",
                            style: const TextStyle(
                                color: MyColor.white, fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                TripDataList(),
              ],
            ),
          ),
        ),
      )),
    );
  }
}
