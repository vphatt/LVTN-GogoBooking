import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/my_color.dart';

class FarePage extends StatefulWidget {
  static const String id = "pageFare";
  const FarePage({super.key});

  @override
  State<FarePage> createState() => _FarePageState();
}

class _FarePageState extends State<FarePage> {
  TextEditingController openDoorController = TextEditingController();
  TextEditingController under30kmController = TextEditingController();
  TextEditingController over30kmController = TextEditingController();

  DatabaseReference fareTripRef =
      FirebaseDatabase.instance.ref().child("fareTrip");

  //final _formKey = GlobalKey<FormState>();

  getFareTrip() {
    fareTripRef.once().then((snap) {
      openDoorController.text = (snap.snapshot.value! as Map)["openDoor"];
      under30kmController.text = (snap.snapshot.value! as Map)["under30km"];
      over30kmController.text = (snap.snapshot.value! as Map)["over30km"];
    });
  }

  @override
  void initState() {
    super.initState();
    getFareTrip();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SelectionArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
                child: DataTable(
              dataRowMaxHeight: 100,
              dataRowMinHeight: 10,
              columns: [
                const DataColumn(
                  label: Text(
                    "QUẢN LÝ GIÁ CƯỚC",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                // DataColumn(
                //   label: Expanded(
                //     child: Text(
                //       "DƯỚI 30 KM",
                //       style: TextStyle(fontWeight: FontWeight.bold),
                //     ),
                //   ),
                // ),
                // DataColumn(
                //   label: Expanded(
                //     child: Text(
                //       "TRÊN 30 KM",
                //       style: TextStyle(fontWeight: FontWeight.bold),
                //     ),
                //   ),
                // ),
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
                        await FirebaseDatabase.instance
                            .ref()
                            .child("fareTrip")
                            .update({
                          "openDoor": openDoorController.text,
                          "under30km": under30kmController.text,
                          "over30km": over30kmController.text,
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
                      Container(
                        width: 400,
                        padding: const EdgeInsets.all(15),
                        child: Form(
                          //key: _formKey,
                          child: Wrap(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: TextFormField(
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
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: TextFormField(
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
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  controller: over30kmController,
                                  decoration: const InputDecoration(
                                      label: Text(
                                        "Giá trên 30 km",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)))),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const DataCell(SizedBox())
                    // DataCell(
                    //   SizedBox(
                    //     width: 150,
                    //     child: TextField(
                    //       keyboardType: TextInputType.number,
                    //       controller: under30kmController,
                    //       decoration: const InputDecoration(
                    //           border: OutlineInputBorder(
                    //               borderRadius:
                    //                   BorderRadius.all(Radius.circular(10)))),
                    //     ),
                    //   ),
                    // ),
                    // DataCell(
                    //   SizedBox(
                    //     width: 150,
                    //     child: TextField(
                    //       keyboardType: TextInputType.number,
                    //       controller: over30kmController,
                    //       decoration: const InputDecoration(
                    //           border: OutlineInputBorder(
                    //               borderRadius:
                    //                   BorderRadius.all(Radius.circular(10)))),
                    //     ),
                    //   ),
                    // ),
                    // DataCell(
                    //   SizedBox(
                    //     child: ElevatedButton(
                    //       onPressed: () async {
                    //         // ignore: unnecessary_type_check
                    //         if (int.parse(openDoorController.text) is int) {
                    //           await FirebaseDatabase.instance
                    //               .ref()
                    //               .child("fareTrip")
                    //               .update({
                    //             "openDoor": openDoorController.text,
                    //             // "under30km": under30kmController.text,
                    //             // "over30km": over30kmController.text,
                    //           });
                    //         } else {
                    //           print('Chỉ nhập số');
                    //         }
                    //         // await FirebaseDatabase.instance
                    //         //     .ref()
                    //         //     .child("fareTrip")
                    //         //     .update({
                    //         //   "openDoor": openDoorController.text,
                    //         //   "under30km": under30kmController.text,
                    //         //   "over30km": over30kmController.text,
                    //         // });
                    //       },
                    //       style: ElevatedButton.styleFrom(
                    //           backgroundColor: MyColor.green,
                    //           shape: RoundedRectangleBorder(
                    //               borderRadius: BorderRadius.circular(5))),
                    //       child: Text(
                    //         "CẬP NHẬT",
                    //         style: TextStyle(
                    //             fontSize: 15,
                    //             fontWeight: FontWeight.bold,
                    //             color: MyColor.white),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ],
            )

                // SizedBox(
                //   width: 700,
                //   child: Column(
                //     children: [
                //       ListTile(
                //         leading: const Text(
                //           "GIÁ MỞ CỬA: ",
                //           style: TextStyle(
                //               fontSize: 20, fontWeight: FontWeight.bold),
                //         ),
                //         title: TextField(
                //           keyboardType: TextInputType.number,
                //           controller: openDoorController,
                //           decoration: const InputDecoration(
                //               border: OutlineInputBorder(
                //                   borderRadius:
                //                       BorderRadius.all(Radius.circular(10)))),
                //         ),
                //         trailing: ElevatedButton(
                //           onPressed: () async {
                //             await FirebaseDatabase.instance
                //                 .ref()
                //                 .child("fareTrip")
                //                 .update({"openDoor": openDoorController.text});
                //           },
                //           style: ElevatedButton.styleFrom(
                //               backgroundColor: MyColor.green,
                //               shape: RoundedRectangleBorder(
                //                   borderRadius: BorderRadius.circular(5))),
                //           child: const Padding(
                //             padding: EdgeInsets.all(15),
                //             child: Text(
                //               "CẬP NHẬT",
                //               style: TextStyle(
                //                   fontSize: 15,
                //                   fontWeight: FontWeight.bold,
                //                   color: MyColor.white),
                //             ),
                //           ),
                //         ),
                //       ),
                //       ListTile(
                //         leading: const Text(
                //           "DƯỚI 30 KM: ",
                //           style: TextStyle(
                //               fontSize: 20, fontWeight: FontWeight.bold),
                //         ),
                //         title: TextField(
                //           keyboardType: TextInputType.number,
                //           controller: under30kmController,
                //           decoration: const InputDecoration(
                //               border: OutlineInputBorder(
                //                   borderRadius:
                //                       BorderRadius.all(Radius.circular(10)))),
                //         ),
                //         trailing: ElevatedButton(
                //           onPressed: () async {
                //             await FirebaseDatabase.instance
                //                 .ref()
                //                 .child("fareTrip")
                //                 .update({"under30km": under30kmController.text});
                //           },
                //           style: ElevatedButton.styleFrom(
                //               backgroundColor: MyColor.green,
                //               shape: RoundedRectangleBorder(
                //                   borderRadius: BorderRadius.circular(5))),
                //           child: const Padding(
                //             padding: EdgeInsets.all(15),
                //             child: Text(
                //               "CẬP NHẬT",
                //               style: TextStyle(
                //                   fontSize: 15,
                //                   fontWeight: FontWeight.bold,
                //                   color: MyColor.white),
                //             ),
                //           ),
                //         ),
                //       ),
                //       ListTile(
                //         leading: const Text(
                //           "TRÊN 30 KM: ",
                //           style: TextStyle(
                //               fontSize: 20, fontWeight: FontWeight.bold),
                //         ),
                //         title: TextField(
                //           keyboardType: TextInputType.number,
                //           controller: over30kmController,
                //           decoration: const InputDecoration(
                //               border: OutlineInputBorder(
                //                   borderRadius:
                //                       BorderRadius.all(Radius.circular(10)))),
                //         ),
                //         trailing: ElevatedButton(
                //           onPressed: () async {
                //             await FirebaseDatabase.instance
                //                 .ref()
                //                 .child("fareTrip")
                //                 .update({"over30km": over30kmController.text});
                //           },
                //           style: ElevatedButton.styleFrom(
                //               backgroundColor: MyColor.green,
                //               shape: RoundedRectangleBorder(
                //                   borderRadius: BorderRadius.circular(5))),
                //           child: const Padding(
                //             padding: EdgeInsets.all(15),
                //             child: Text(
                //               "CẬP NHẬT",
                //               style: TextStyle(
                //                   fontSize: 15,
                //                   fontWeight: FontWeight.bold,
                //                   color: MyColor.white),
                //             ),
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                ),
          ),
        ),
      ),
    );
  }
}
