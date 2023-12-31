// ignore_for_file: deprecated_member_use

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/global_var.dart';
import '../utils/my_color.dart';

class OtherPage extends StatefulWidget {
  static const String id = "pageOther";
  const OtherPage({super.key});

  @override
  State<OtherPage> createState() => _OtherPageState();
}

class _OtherPageState extends State<OtherPage> {
  TextEditingController openDoorController = TextEditingController();
  TextEditingController under30kmController = TextEditingController();
  TextEditingController over30kmController = TextEditingController();

  TextEditingController goongMapApiController = TextEditingController();
  TextEditingController googleMapApiController = TextEditingController();

  DatabaseReference fareTripRef =
      FirebaseDatabase(databaseURL: flutterURL).ref().child("fareTrip");

  getFareTrip() {
    fareTripRef.once().then((snap) {
      openDoorController.text = (snap.snapshot.value! as Map)["openDoor"];
      under30kmController.text = (snap.snapshot.value! as Map)["under30km"];
      over30kmController.text = (snap.snapshot.value! as Map)["over30km"];
    });
  }

  DatabaseReference apiKeyRef =
      FirebaseDatabase(databaseURL: flutterURL).ref().child("apiKey");
  getAPIKey() {
    apiKeyRef.once().then((snap) {
      goongMapApiController.text =
          (snap.snapshot.value! as Map)["goongMap"]["key"];
    });
  }

  @override
  void initState() {
    super.initState();
    getFareTrip();
    getAPIKey();
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
                  DataTable(
                    dataRowMaxHeight: 100,
                    dataRowMinHeight: 10,
                    columns: [
                      const DataColumn(
                        label: Text(
                          "QUẢN LÝ TÀI NGUYÊN",
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: const RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5))),
                                  title: const Text("Cập nhật thành công!",
                                      style: TextStyle(fontSize: 20)),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: MyColor.green,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5))),
                                      child: const Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Text(
                                          "XÁC NHẬN",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: MyColor.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              FirebaseDatabase(databaseURL: flutterURL)
                                  .ref()
                                  .child("fareTrip")
                                  .update({
                                "openDoor": openDoorController.text,
                                "under30km": under30kmController.text,
                                "over30km": over30kmController.text,
                              });

                              FirebaseDatabase(databaseURL: flutterURL)
                                  .ref()
                                  .child("apiKey")
                                  .child("goongMap")
                                  .update({
                                "key": goongMapApiController.text,
                              });
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: MyColor.green,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5))),
                            child: const Text(
                              "CẬP NHẬT",
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: MyColor.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                    rows: [
                      DataRow(
                        cells: [
                          DataCell(
                            SizedBox(
                              width: 600,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  controller: openDoorController,
                                  decoration: const InputDecoration(
                                      label: Text(
                                        "Giá mở cửa",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)))),
                                ),
                              ),
                            ),
                          ),
                          const DataCell(SizedBox())
                        ],
                      ),
                      DataRow(
                        cells: [
                          DataCell(
                            SizedBox(
                              width: 600,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  controller: under30kmController,
                                  decoration: const InputDecoration(
                                      label: Text(
                                        "Giá dưới 30 km",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)))),
                                ),
                              ),
                            ),
                          ),
                          const DataCell(SizedBox())
                        ],
                      ),
                      DataRow(
                        cells: [
                          DataCell(
                            SizedBox(
                              width: 600,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  controller: over30kmController,
                                  decoration: const InputDecoration(
                                      label: Text(
                                        "Giá từ 30 km trở lên",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)))),
                                ),
                              ),
                            ),
                          ),
                          const DataCell(SizedBox())
                        ],
                      ),
                      DataRow(
                        cells: [
                          DataCell(
                            SizedBox(
                              width: 600,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: TextFormField(
                                  keyboardType: TextInputType.text,
                                  controller: goongMapApiController,
                                  decoration: const InputDecoration(
                                      label: Text(
                                        "Goong Map API",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)))),
                                ),
                              ),
                            ),
                          ),
                          const DataCell(SizedBox())
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
