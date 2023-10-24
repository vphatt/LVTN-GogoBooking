import 'package:admin_panel_web/methods/common_methods.dart';
import 'package:admin_panel_web/utils/my_color.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class UserDataList extends StatefulWidget {
  const UserDataList({super.key});

  @override
  State<UserDataList> createState() => _UserDataListState();
}

class _UserDataListState extends State<UserDataList> {
  //Lấy thông tin tài xế từ database
  final usersDataFromDatabase = FirebaseDatabase.instance.ref().child("users");

  CommonMethods cMethod = CommonMethods();

  //get data => null;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return StreamBuilder(
      stream: usersDataFromDatabase
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
                DataColumn(label: Text('ID KHÁCH HÀNG')),
                DataColumn(label: Text('TÊN KHÁCH HÀNG')),
                DataColumn(label: Text('SỐ ĐIỆN THOẠI')),
                DataColumn(label: Text('EMAIL')),
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
                            width: screenSize.width / 10,
                            child: Text(dataList[index]["id"].toString()))),
                        DataCell(SizedBox(
                            width: screenSize.width / 10,
                            child: Text(dataList[index]["name"].toString()))),
                        DataCell(SizedBox(
                            width: screenSize.width / 10,
                            child: Text(dataList[index]["phone"].toString()))),
                        DataCell(SizedBox(
                            width: screenSize.width / 10,
                            child: Text(dataList[index]["email"].toString()))),
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
                                  width: screenSize.width / 10,
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

        //     ListView.builder(
        //   shrinkWrap: true,
        //   itemCount: dataList.length,
        //   itemBuilder: (context, index) {
        //     return Row(
        //       //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //       crossAxisAlignment: CrossAxisAlignment.center,
        //       children: [
        //         cMethod.bodyData(2, Text(dataList[index]["id"].toString())),
        //         cMethod.bodyData(1, Text(dataList[index]["name"].toString())),
        //         cMethod.bodyData(1, Text(dataList[index]["phone"].toString())),
        //         cMethod.bodyData(1, Text(dataList[index]["email"].toString())),
        //         cMethod.bodyData(
        //             1,
        //             dataList[index]["blockStatus"] == "no"
        //                 ? const Text(
        //                     'Đang hoạt động!',
        //                     style: TextStyle(
        //                       color: MyColor.green,
        //                       fontWeight: FontWeight.bold,
        //                     ),
        //                   )
        //                 : const Text(
        //                     'Đang bị khoá!',
        //                     style: TextStyle(
        //                       color: MyColor.red,
        //                       fontWeight: FontWeight.bold,
        //                     ),
        //                   )),
        //         cMethod.bodyData(
        //             1,
        //             dataList[index]["blockStatus"] == "no"
        //                 ? FilledButton(
        //                     onPressed: () {},
        //                     child: const Text(
        //                       'Khoá',
        //                       style: TextStyle(
        //                         color: MyColor.white,
        //                         fontSize: 15,
        //                         fontWeight: FontWeight.bold,
        //                       ),
        //                     ),
        //                   )
        //                 : FilledButton(
        //                     onPressed: () {},
        //                     child: const Text(
        //                       'Mở khoá',
        //                       style: TextStyle(
        //                         color: MyColor.white,
        //                         fontSize: 15,
        //                         fontWeight: FontWeight.bold,
        //                       ),
        //                     ),
        //                   )),
        //       ],
        //     );
        //   },
        // );
      },
    );
  }
}
