import 'package:admin_panel_web/widgets/user_data_list.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../methods/common_methods.dart';
import '../utils/global_var.dart';
import '../utils/my_color.dart';

class UserPage extends StatefulWidget {
  static const String id = "pageUser";
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  CommonMethods cMethod = CommonMethods();

  int countUser = 0;

  getAllDriver() async {
    //Lấy tất cả tài xế
    DatabaseReference userRef =
        // ignore: deprecated_member_use
        FirebaseDatabase(databaseURL: flutterURL).ref().child("users");

    await userRef.once().then((snap) {
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
          countUser = dataList.length;
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
          padding: const EdgeInsets.all(5),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Container(
                        height: 70,
                        width: 250,
                        decoration: BoxDecoration(
                            color: MyColor.green,
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Center(
                            child: Text(
                              "Số khách hàng: $countUser",
                              style: const TextStyle(
                                  color: MyColor.white, fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const UserDataList(),
              ],
            ),
          ),
        ),
      )),
    );
  }
}
