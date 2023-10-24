import 'package:admin_panel_web/methods/common_methods.dart';
import 'package:admin_panel_web/widgets/drivers_data_list.dart';
import 'package:flutter/material.dart';

class DriverPage extends StatefulWidget {
  static const String id = "\pageDriver";
  const DriverPage({super.key});

  @override
  State<DriverPage> createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
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
                    'QUẢN LÝ TÀI XẾ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                //HEADER CỦA BẢNG DANH SÁCH TÀI XẾ

                //PHẦN DỮ LIỆU CỦA BẢNG
                const DriverDataList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
