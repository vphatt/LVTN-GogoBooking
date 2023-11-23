import 'package:admin_panel_web/utils/my_color.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../utils/global_var.dart';

class DriverDataList extends StatefulWidget {
  const DriverDataList({super.key});

  @override
  State<DriverDataList> createState() => _DriverDataListState();
}

class DriverData extends DataTableSource {
  List dataList = [];
  int index;

  DriverData(this.dataList, this.index);
  @override
  DataRow? getRow(int index) {
    return dataList[index]["name"] == "noresult"
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
            DataCell(Text("")),
          ])
        : DataRow(
            color: index % 2 == 0
                ? const MaterialStatePropertyAll(MyColor.white)
                : const MaterialStatePropertyAll(MyColor.greyLight),
            cells: [
              DataCell(SizedBox(child: Text((index + 1).toString()))),
              DataCell(SizedBox(
                  width: 80,
                  child: Image.network(
                    dataList[index]["avatar"].toString(),
                    fit: BoxFit.cover,
                    width: 50,
                    height: 50,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text(
                        'Lỗi tải ảnh!',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      );
                    },
                  ))),
              DataCell(SizedBox(
                  width: 130,
                  child: Text(
                    dataList[index]["id"].toString(),
                    maxLines: 2,
                    //overflow: TextOverflow.ellipsis,
                  ))),
              DataCell(
                  SizedBox(child: Text(dataList[index]["name"].toString()))),
              DataCell(
                  SizedBox(child: Text(dataList[index]["phone"].toString()))),
              DataCell(
                  SizedBox(child: Text(dataList[index]["email"].toString()))),
              DataCell(SizedBox(
                  child: Text(
                      "${dataList[index]["car_details"]["carModel"]}, ${dataList[index]["car_details"]["carColor"]}\n${dataList[index]["car_details"]["carNumber"]}"))),
              DataCell(
                SizedBox(
                    child: dataList[index]["incomes"] != null
                        ? Text("${dataList[index]["incomes"]} VND")
                        : const Text("0 VND")),
              ),
              DataCell(
                SizedBox(
                    child: dataList[index]["blockStatus"] == "no"
                        ? const Text("Đang hoạt động",
                            style: TextStyle(
                                color: MyColor.green,
                                fontStyle: FontStyle.italic))
                        : const Text("Đang tạm khoá",
                            style: TextStyle(
                                color: MyColor.red,
                                fontStyle: FontStyle.italic))),
              ),
              DataCell(
                SizedBox(
                  child: Row(
                    children: [
                      dataList[index]["blockStatus"] == "no"
                          ? IconButton(
                              onPressed: () async {
                                await FirebaseDatabase.instance
                                    .ref()
                                    .child("drivers")
                                    .child(dataList[index]["id"])
                                    .update(
                                  {
                                    "blockStatus": "yes",
                                  },
                                );
                              },
                              icon: const Icon(Icons.lock, color: MyColor.red))
                          : IconButton(
                              onPressed: () async {
                                await FirebaseDatabase.instance
                                    .ref()
                                    .child("drivers")
                                    .child(dataList[index]["id"])
                                    .update({
                                  "blockStatus": "no",
                                });
                              },
                              icon: const Icon(Icons.lock_open,
                                  color: MyColor.green)),
                      IconButton(
                        onPressed: () {
                          showDialog(
                              context: navigatorKey.currentContext!,
                              builder: (context) => AlertDialog(
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5))),
                                    title: Row(
                                      children: [
                                        const Text("Xoá tài xế: ",
                                            style: TextStyle(fontSize: 20)),
                                        Text(
                                          dataList[index]["name"],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        )
                                      ],
                                    ),
                                    content: const Text(
                                        "Bạn có chắc chắn muốn xoá tài xế này?"),
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
                                              .child("drivers")
                                              .child(dataList[index]["id"])
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
                          color: MyColor.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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

class _DriverDataListState extends State<DriverDataList> {
  TextEditingController searchController = TextEditingController();
  List searchResult = [];

  final usersDataFromDatabase =
      FirebaseDatabase.instance.ref().child("drivers");

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
                        "QUẢN LÝ TÀI XẾ",
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: ListTile(
                        leading: const Icon(Icons.search),
                        title: TextField(
                          controller: searchController,
                          decoration: const InputDecoration(
                              hintText: "Tên, số điện thoại, email..."),
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
                      label: Text(
                    'ẢNH',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                  DataColumn(
                      label: Text('ID TÀI XẾ',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                    label: Text('TÊN TÀI XẾ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                      label: Text('SỐ ĐIỆN THOẠI',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('EMAIL',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('PHƯƠNG TIỆN',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('THU NHẬP',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('TRẠNG THÁI',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('THAO TÁC',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                source: DriverData(searchResult, searchResult.length));
          }

          Map dataMap = snapshotData.data!.snapshot.value as Map;

          List dataList = [];

          dataMap.forEach((key, value) {
            dataList.add({
              "key": key,
              ...value,
            });
          });

          return PaginatedDataTable(
              showFirstLastButtons: true,
              arrowHeadColor: MyColor.blue,
              header: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    flex: 5,
                    child: Text(
                      "QUẢN LÝ TÀI XẾ",
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: ListTile(
                      leading: const Icon(Icons.search),
                      title: TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                            hintText: "Tên, số điện thoại, email..."),
                        onChanged: (value) {
                          if (value.isNotEmpty &&
                              ((dataList.where(
                                    (element) => element["name"]
                                        .toString()
                                        .toLowerCase()
                                        .contains(
                                          value.toLowerCase(),
                                        ),
                                  )).isNotEmpty ||
                                  (dataList.where(
                                    (element) => element["phone"]
                                        .toString()
                                        .toLowerCase()
                                        .contains(
                                          value.toLowerCase(),
                                        ),
                                  )).isNotEmpty ||
                                  (dataList.where(
                                    (element) => element["email"]
                                        .toString()
                                        .toLowerCase()
                                        .contains(
                                          value.toLowerCase(),
                                        ),
                                  )).isNotEmpty)) {
                            setState(() {
                              if ((dataList.where(
                                (element) => element["name"]
                                    .toString()
                                    .toLowerCase()
                                    .contains(
                                      value.toLowerCase(),
                                    ),
                              )).isNotEmpty) {
                                searchResult = dataList
                                    .where((element) => element["name"]
                                        .toString()
                                        .toLowerCase()
                                        .contains(value.toLowerCase()))
                                    .toList();
                              } else if ((dataList.where(
                                (element) => element["email"]
                                    .toString()
                                    .toLowerCase()
                                    .contains(
                                      value.toLowerCase(),
                                    ),
                              )).isNotEmpty) {
                                searchResult = dataList
                                    .where(
                                      (element) => element["email"]
                                          .toString()
                                          .toLowerCase()
                                          .contains(
                                            value.toLowerCase(),
                                          ),
                                    )
                                    .toList();
                              } else {
                                searchResult = dataList
                                    .where(
                                      (element) => element["phone"]
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
                              ((dataList.where((element) => element["name"]
                                          .toString()
                                          .toLowerCase()
                                          .contains(value.toLowerCase())))
                                      .isEmpty ||
                                  (dataList.where((element) => element["phone"]
                                          .toString()
                                          .toLowerCase()
                                          .contains(value.toLowerCase())))
                                      .isEmpty ||
                                  dataList
                                      .where(
                                        (element) => element["email"]
                                            .toString()
                                            .toLowerCase()
                                            .contains(
                                              value.toLowerCase(),
                                            ),
                                      )
                                      .isEmpty)) {
                            setState(
                              () {
                                searchResult = [
                                  {
                                    "name": "noresult",
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
                    label: Text(
                  'ẢNH',
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
                DataColumn(
                    label: Text('ID TÀI XẾ',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                  label: Text('TÊN TÀI XẾ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                    label: Text('SỐ ĐIỆN THOẠI',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('EMAIL',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('PHƯƠNG TIỆN',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('THU NHẬP',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('TRẠNG THÁI',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('THAO TÁC',
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              source: searchResult.isNotEmpty
                  ? DriverData(searchResult, searchResult.length)
                  : DriverData(dataList, dataList.length));
        });
  }
}
