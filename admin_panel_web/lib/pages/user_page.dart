import 'package:flutter/material.dart';

import '../methods/common_methods.dart';
import '../widgets/users_data_list.dart';

class UserPage extends StatefulWidget {
  static const String id = "\pageUser";
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
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
                    'QUẢN LÝ KHÁCH HÀNG',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                //HEADER CỦA BẢNG DANH SÁCH TÀI XẾ
                // Row(
                //   children: [
                //     cMethod.headerData(2, "ID KHÁCH HÀNG"),
                //     cMethod.headerData(1, "TÊN KHÁCH HÀNG"),
                //     cMethod.headerData(1, "SỐ ĐIỆN THOẠI"),
                //     cMethod.headerData(1, "EMAIL"),
                //     cMethod.headerData(1, "TRẠNG THÁI"),
                //     cMethod.headerData(1, "HÀNH ĐỘNG"),
                //   ],
                // ),

                //PHẦN DỮ LIỆU CỦA BẢNG
                const UserDataList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
