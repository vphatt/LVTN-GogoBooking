import 'package:driver_app/authentication/login_screen.dart';
import 'package:driver_app/global/global_var.dart';
import 'package:driver_app/utils/my_color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/loading_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: MyColor.green,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Card(
                elevation: 5,
                surfaceTintColor: MyColor.black,
                child: Wrap(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Center(
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircleAvatar(
                                radius: 70,
                                backgroundImage: NetworkImage(driverAvt),
                              ),
                            ),
                            Positioned(
                              left: 40,
                              right: 40,
                              bottom: 0,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      color: Colors.white70, width: 1),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                color: MyColor.green,
                                child: const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Text(
                                    "4.9 ⭐",
                                    style: TextStyle(color: MyColor.yellow),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text(driverName),
                      leading: const Icon(Icons.person),
                    ),
                    ListTile(
                      title: Text(driverEmail),
                      leading: const Icon(Icons.email),
                    ),
                    ListTile(
                      title: Text(driverPhone),
                      leading: const Icon(Icons.phone),
                    ),
                    ListTile(
                      title: Text("$carModel - $carColor - $carNumber"),
                      leading: const Icon(Icons.local_taxi_outlined),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
              child: Card(
                elevation: 5,
                surfaceTintColor: MyColor.black,
                child: ListTile(
                  title: Text("Đánh giá của khách hàng"),
                  leading: Icon(Icons.comment),
                  trailing: Icon(Icons.keyboard_arrow_right),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
              child: Card(
                elevation: 5,
                surfaceTintColor: MyColor.black,
                child: ListTile(
                  title: Text("Chỉnh sửa thông tin cá nhân"),
                  leading: Icon(Icons.edit),
                  trailing: Icon(Icons.keyboard_arrow_right),
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) =>
                        LoadingDialog(messageText: 'Đang đăng xuất...'),
                  );
                  FirebaseAuth.instance.signOut();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()));
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: MyColor.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5))),
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "ĐĂNG XUẤT",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: MyColor.white),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
