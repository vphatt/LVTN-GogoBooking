import 'package:admin_panel_web/methods/common_methods.dart';
import 'package:admin_panel_web/utils/my_color.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class DriverDataList extends StatefulWidget {
  const DriverDataList({super.key});

  @override
  State<DriverDataList> createState() => _DriverDataListState();
}

class _DriverDataListState extends State<DriverDataList> {
  //Lấy thông tin tài xế từ database
  final driversDataFromDatabase =
      FirebaseDatabase.instance.ref().child("drivers");

  CommonMethods cMethod = CommonMethods();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return StreamBuilder(
      stream: driversDataFromDatabase
          .onValue, //onValue => khi dữ liệu mới đc thêm vào từ driver app, web sẽ tự động cập nhật mà ko cần reload
      builder: (BuildContext context, snapshotData) {
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
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        Map dataMap = snapshotData.data!.snapshot.value as Map;
        List dataList = [];
        dataMap.forEach((key, value) {
          dataList.add({
            "key": key,
            ...value,
          });
        });

        //Xuất dữ liệu ra màn hình
        return SingleChildScrollView(
          //physics: ClampingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          child: DataTable(
              columnSpacing: (screenSize.width / 10) * 0.3,
              // ignore: deprecated_member_use
              dataRowHeight: 80,
              border: const TableBorder(
                top: BorderSide(width: 1),
                bottom: BorderSide(width: 1, color: MyColor.white),
                verticalInside: BorderSide(width: 1, color: MyColor.white),
                horizontalInside: BorderSide(width: 1, color: MyColor.white),
              ),
              headingTextStyle: const TextStyle(
                color: MyColor.white,
                fontWeight: FontWeight.bold,
              ),
              headingRowColor: MaterialStateColor.resolveWith((states) {
                return MyColor.green;
              }),
              columns: const [
                DataColumn(label: Text('ẢNH')),
                DataColumn(label: Text('ID TÀI XẾ')),
                DataColumn(label: Text('TÊN TÀI XẾ')),
                DataColumn(label: Text('SỐ ĐIỆN THOẠI')),
                DataColumn(label: Text('EMAIL')),
                DataColumn(label: Text('PHƯƠNG TIỆN')),
                DataColumn(label: Text('THU NHẬP')),
                DataColumn(label: Text('HÀNH ĐỘNG')),
              ],
              rows: List.generate(
                dataList.length,
                (index) {
                  return DataRow(
                      color: dataList[index]["blockStatus"] == "no"
                          ? MaterialStateColor.resolveWith((states) {
                              return index % 2 == 0
                                  ? MyColor.white
                                  : MyColor.greyLight;
                            })
                          : MaterialStateColor.resolveWith((states) {
                              return MyColor.rose;
                            }),
                      cells: [
                        DataCell(SizedBox(
                            width: screenSize.width / 25,
                            child: Image.network(
                              dataList[index]["avatar"].toString(),
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
                            width: screenSize.width / 15,
                            child: Text(dataList[index]["id"].toString()))),
                        DataCell(SizedBox(
                            width: screenSize.width / 10,
                            child: Text(dataList[index]["name"].toString()))),
                        DataCell(SizedBox(
                            width: screenSize.width / 20,
                            child: Text(dataList[index]["phone"].toString()))),
                        DataCell(SizedBox(
                            width: screenSize.width / 10,
                            child: Text(dataList[index]["email"].toString()))),
                        DataCell(SizedBox(
                            width: screenSize.width / 20,
                            child: Text(
                                "${dataList[index]["car_details"]["carModel"]}, ${dataList[index]["car_details"]["carColor"]}\n${dataList[index]["car_details"]["carNumber"]}"))),
                        DataCell(
                          SizedBox(
                              width: screenSize.width / 20,
                              child: dataList[index]["income"] != null
                                  ? Text("${dataList[index]["income"]} VND")
                                  : const Text("0 VND")),
                        ),
                        DataCell(
                          dataList[index]["blockStatus"] == "no"
                              ? SizedBox(
                                  width: screenSize.width / 10,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5),
                                        child: FilledButton(
                                          onPressed: () {},
                                          child: const Text(
                                            'Khoá',
                                            style: TextStyle(
                                              color: MyColor.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 5),
                                        child: FilledButton(
                                          style: ButtonStyle(backgroundColor:
                                              MaterialStateColor.resolveWith(
                                                  (states) {
                                            return MyColor.red;
                                          })),
                                          onPressed: () {},
                                          child: const Text(
                                            'Xoá',
                                            style: TextStyle(
                                              color: MyColor.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : SizedBox(
                                  width: screenSize.width / 20,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5),
                                        child: FilledButton(
                                          style: ButtonStyle(backgroundColor:
                                              MaterialStateColor.resolveWith(
                                                  (states) {
                                            return MyColor.yellowDark;
                                          })),
                                          onPressed: () {},
                                          child: const Text(
                                            'Mở khoá',
                                            style: TextStyle(
                                              color: MyColor.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 5),
                                        child: FilledButton(
                                          style: ButtonStyle(backgroundColor:
                                              MaterialStateColor.resolveWith(
                                                  (states) {
                                            return MyColor.red;
                                          })),
                                          onPressed: () {},
                                          child: const Text(
                                            'Xoá',
                                            style: TextStyle(
                                              color: MyColor.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ]);
                },
              )),
        );
      },
    );
  }
}
