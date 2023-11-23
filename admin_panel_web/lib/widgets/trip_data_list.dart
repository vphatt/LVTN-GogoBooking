import 'package:admin_panel_web/utils/my_color.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/global_var.dart';

class TripDataList extends StatefulWidget {
  const TripDataList({super.key});

  @override
  State<TripDataList> createState() => _TripDataListState();
}

class TripData extends DataTableSource {
  List dataList = [];
  int index;

  launchGoogleMapToViewTrip(startLat, startLng, endLat, endLng) async {
    String directionAPIUrl =
        "https://www.google.com/maps/dir/$startLat,$startLng/$endLat,$endLng/";

    if (await canLaunchUrl(Uri.parse(directionAPIUrl))) {
      await launchUrl(Uri.parse(directionAPIUrl));
    } else {
      throw "Không thể mở Google Maps";
    }
  }

  TripData(this.dataList, this.index);
  @override
  DataRow? getRow(int index) {
    return dataList[index]["tripId"] == "noresult"
        ? const DataRow(cells: [
            DataCell(Text("")),
            DataCell(Text("")),
            DataCell(Text("Không có kết quả!")),
            DataCell(Text("")),
            DataCell(Text("")),
            DataCell(Text("")),
            DataCell(Text("")),
            DataCell(Text("")),
            DataCell(Text("")),
          ])
        : DataRow(
            color: index % 2 == 0
                ? const MaterialStatePropertyAll(MyColor.white)
                : const MaterialStatePropertyAll(MyColor.greyLight),
            cells: [
              DataCell(SizedBox(child: Text((index + 1).toString()))),
              DataCell(SizedBox(
                  width: 130,
                  child: Text(
                    dataList[index]["tripId"].toString(),
                    maxLines: 2,
                    //overflow: TextOverflow.ellipsis,
                  ))),
              DataCell(SizedBox(
                  child: Text(dataList[index]["userName"].toString()))),
              DataCell(SizedBox(
                  child: Text(dataList[index]["driverName"].toString()))),
              DataCell(SizedBox(
                child: Text(
                  DateFormat("kk:mm - dd/MM/yyyy").format(
                      DateTime.parse(dataList[index]['requestDateTime'])),
                ),
              )),
              DataCell(SizedBox(
                  child: Text("${dataList[index]["actualFareAmount"]} VNĐ"))),
              DataCell(SizedBox(
                  width: 120,
                  child: Text(
                    dataList[index]["startAddress"].toString(),
                    maxLines: 4,
                    //overflow: TextOverflow.ellipsis,
                  ))),
              DataCell(SizedBox(
                  width: 130,
                  child: Text(
                    dataList[index]["endAddress"].toString(),
                    maxLines: 4,
                    //overflow: TextOverflow.ellipsis,
                  ))),
              DataCell(SizedBox(
                  child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      String startLat =
                          dataList[index]["startLatLng"]["latitude"];
                      String startLng =
                          dataList[index]["startLatLng"]["longitude"];

                      String endLat = dataList[index]["endLatLng"]["latitude"];
                      String endLng = dataList[index]["endLatLng"]["longitude"];
                      //Chuyển sang trang google map để xem tuyến đường
                      launchGoogleMapToViewTrip(
                        startLat,
                        startLng,
                        endLat,
                        endLng,
                      );
                    },
                    icon: const Icon(
                      Icons.map,
                      color: MyColor.green,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      showDialog(
                          context: navigatorKey.currentContext!,
                          builder: (context) => AlertDialog(
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                                title: Row(
                                  children: [
                                    const Text("Xoá chuyến có id: ",
                                        style: TextStyle(fontSize: 20)),
                                    Text(
                                      dataList[index]["tripId"],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    )
                                  ],
                                ),
                                content: const Text(
                                    "Bạn có chắc chắn muốn xoá thông tin chuyến này?"),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: MyColor.grey,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5))),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Text(
                                        "HUỶ",
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: MyColor.white),
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      await FirebaseDatabase.instance
                                          .ref()
                                          .child("tripRequests")
                                          .child(dataList[index]["tripId"])
                                          .remove();
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: MyColor.red,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5))),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Text(
                                        "XOÁ",
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: MyColor.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ));
                    },
                    icon: const Icon(
                      Icons.delete,
                      color: MyColor.red,
                    ),
                  ),
                ],
              )))
            ],
          );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => index;

  @override
  int get selectedRowCount => 0;
}

class _TripDataListState extends State<TripDataList> {
  TextEditingController searchController = TextEditingController();
  List searchResult = [];

  final usersDataFromDatabase =
      FirebaseDatabase.instance.ref().child("tripRequests");

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        //onValue => khi dữ liệu mới đc thêm vào từ driver app, web sẽ tự động cập nhật mà ko cần reload
        stream: usersDataFromDatabase.onValue,
        builder: (context, snapshotData) {
          //Nếu có lỗi, thông báo ra màn hình
          if (snapshotData.hasError) {
            return const Center(
              child: Text(
                'Oops... Có lỗi xảy ra! Vui lòng thử lại sau!',
                style: TextStyle(
                    fontSize: 30,
                    color: MyColor.green,
                    fontWeight: FontWeight.bold),
              ),
            );
          }

          //Đang đợi dữ liệu, hiện hình tròn loading xoay
          if (snapshotData.connectionState == ConnectionState.waiting) {
            return PaginatedDataTable(
                arrowHeadColor: MyColor.blue,
                header: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      flex: 5,
                      child: Text(
                        "QUẢN LÝ CHUYẾN",
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: ListTile(
                        leading: const Icon(Icons.search),
                        title: TextField(
                          controller: searchController,
                          decoration: const InputDecoration(
                              hintText: "Tên khách hàng, tài xế..."),
                        ),
                        trailing: IconButton(
                            onPressed: () {}, icon: const Icon(Icons.close)),
                      ),
                    )
                  ],
                ),
                rowsPerPage:
                    1, // searchResult.length < 10 ? searchResult.length : 10,
                columns: const [
                  DataColumn(
                      label: Text('STT',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('ID CHUYẾN',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                    label: Text('KHÁCH HÀNG',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text('TÀI XẾ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                      label: Text('NGÀY YÊU CẦU',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('GIÁ CHUYẾN',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('ĐIỂM ĐÓN',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('ĐIỂM TRẢ',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('THAO TÁC',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                source: TripData(searchResult, searchResult.length));
          }

          Map dataMap = snapshotData.data!.snapshot.value as Map;

          List dataList = [];

          dataMap.forEach((key, value) {
            dataList.add({
              "key": key,
              ...value,
            });
          });

          for (var data in dataList) {
            if (data["status"] != "ended") {
              dataList.remove(data);
            }
          }

          return PaginatedDataTable(
              dataRowMaxHeight: 80,
              dataRowMinHeight: 10,
              columnSpacing: 60,
              showFirstLastButtons: true,
              arrowHeadColor: MyColor.blue,
              header: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    flex: 5,
                    child: Text(
                      "QUẢN LÝ CHUYẾN",
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: ListTile(
                      leading: const Icon(Icons.search),
                      title: TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                            hintText: "Tên khách hàng, tài xế..."),
                        onChanged: (value) {
                          if (value.isNotEmpty &&
                              ((dataList.where(
                                    (element) => element["userName"]
                                        .toString()
                                        .toLowerCase()
                                        .contains(
                                          value.toLowerCase(),
                                        ),
                                  )).isNotEmpty ||
                                  (dataList.where(
                                    (element) => element["driverName"]
                                        .toString()
                                        .toLowerCase()
                                        .contains(
                                          value.toLowerCase(),
                                        ),
                                  )).isNotEmpty)) {
                            setState(() {
                              if ((dataList.where(
                                (element) => element["userName"]
                                    .toString()
                                    .toLowerCase()
                                    .contains(
                                      value.toLowerCase(),
                                    ),
                              )).isNotEmpty) {
                                searchResult = dataList
                                    .where((element) => element["userName"]
                                        .toString()
                                        .toLowerCase()
                                        .contains(value.toLowerCase()))
                                    .toList();
                              } else if ((dataList.where(
                                (element) => element["driverName"]
                                    .toString()
                                    .toLowerCase()
                                    .contains(
                                      value.toLowerCase(),
                                    ),
                              )).isNotEmpty) {
                                searchResult = dataList
                                    .where(
                                      (element) => element["driverName"]
                                          .toString()
                                          .toLowerCase()
                                          .contains(
                                            value.toLowerCase(),
                                          ),
                                    )
                                    .toList();
                              }
                            });
                          } else if (value.isEmpty) {
                            setState(() {
                              searchResult = dataList;
                            });
                          } else if (value.isNotEmpty &&
                              ((dataList.where((element) => element["userName"]
                                          .toString()
                                          .toLowerCase()
                                          .contains(value.toLowerCase())))
                                      .isEmpty ||
                                  (dataList.where((element) =>
                                          element["driverName"]
                                              .toString()
                                              .toLowerCase()
                                              .contains(value.toLowerCase())))
                                      .isEmpty)) {
                            setState(
                              () {
                                searchResult = [
                                  {
                                    "tripId": "noresult",
                                  }
                                ];
                              },
                            );
                          }
                        },
                      ),
                      trailing: IconButton(
                          onPressed: () {
                            setState(() {
                              searchController.clear();
                              searchResult = dataList;
                            });
                          },
                          icon: const Icon(Icons.close)),
                    ),
                  )
                ],
              ),
              rowsPerPage: dataList.length < 10 ? dataList.length : 10,
              columns: const [
                DataColumn(
                    label: Text('STT',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('ID CHUYẾN',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                  label: Text('KHÁCH HÀNG',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('TÀI XẾ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                    label: Text('NGÀY YÊU CẦU',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('GIÁ CHUYẾN',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('ĐIỂM ĐÓN',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('ĐIỂM TRẢ',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('THAO TÁC',
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              source: searchResult.isNotEmpty
                  ? TripData(searchResult, searchResult.length)
                  : TripData(dataList, dataList.length));
        });
  }
}
