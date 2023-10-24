import 'package:flutter/material.dart';

import '../methods/common_methods.dart';

class TripPage extends StatefulWidget {
  static const String id = "\pageTrip";
  const TripPage({super.key});

  @override
  State<TripPage> createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> {
  CommonMethods cMethod = CommonMethods();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  child: const Text(
                    'QUẢN LÝ CHUYẾN ĐI',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                //HEADER CỦA BẢNG DANH SÁCH TÀI XẾ
                Row(
                  children: [
                    cMethod.headerData(2, "ID CHUYẾN"),
                    cMethod.headerData(1, "TÊN TÀI TẾ"),
                    cMethod.headerData(1, "TÊN KHÁCH HÀNG"),
                    cMethod.headerData(1, "THỜI GIAN"),
                    cMethod.headerData(1, "TUYẾN"),
                    cMethod.headerData(1, "GIÁ CƯỚC"),
                    cMethod.headerData(1, "CHI TIẾT"),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
