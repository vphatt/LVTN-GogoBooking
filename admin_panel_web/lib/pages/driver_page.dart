import 'package:admin_panel_web/methods/common_methods.dart';
import 'package:admin_panel_web/widgets/driver_data_list.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../utils/global_var.dart';
import '../utils/my_color.dart';

class DriverPage extends StatefulWidget {
  static const String id = "pageDriver";
  const DriverPage({super.key});

  @override
  State<DriverPage> createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
  CommonMethods cMethod = CommonMethods();
  int countDriver = 0;
  int countDriverActive = 0;
  getAllDriver() async {
    //Lấy tất cả tài xế
    DatabaseReference driverRef =
        // ignore: deprecated_member_use
        FirebaseDatabase(databaseURL: flutterURL).ref().child("drivers");

    await driverRef.once().then((snap) {
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
          countDriver = dataList.length;
        });
      }
    });

    //Lấy tất cả tài xế
    DatabaseReference driverActiveRef =
        // ignore: deprecated_member_use
        FirebaseDatabase(databaseURL: flutterURL).ref().child("driverActive");

    await driverActiveRef.once().then((snap) {
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
          countDriverActive = dataList.length;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();

    getAllDriver();
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
                Row(
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
                            "Số tài xế: $countDriver",
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
                            "Hoạt động: $countDriverActive",
                            style: const TextStyle(
                                color: MyColor.white, fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const DriverDataList(),
              ],
            ),
          ),
        ),
      )),
    );
  }
}
