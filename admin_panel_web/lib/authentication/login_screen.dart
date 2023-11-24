import 'package:admin_panel_web/methods/common_methods.dart';
import 'package:admin_panel_web/utils/my_color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../dashboard/side_navigation.dart';
import '../utils/global_var.dart';
import '../utils/loading_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _passwordVisible = false;

  CommonMethods cMethods = CommonMethods();

  registrationProcess() {
    cMethods.checkConnectivity(context);

    registerFormValidation();
  }

  registerFormValidation() {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      cMethods.displaySnackbar("Vui lòng nhập đầy đủ thông tin", context);
    } else if (!RegExp(r'\S+@\S+\.\S+').hasMatch(emailController.text)) {
      cMethods.displaySnackbar("Email không hợp lệ", context);
    } else if (passwordController.text.trim().length <= 5) {
      cMethods.displaySnackbar("Mật khẩu phải từ 6 kí tự trở lên", context);
    } else {
      // Dang ky sau khi da xac thuc
      registerAdmin();
    }
  }

  registerAdmin() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: 'Đăng ký tài khoản...'),
    );

    final User? adminFirebase = (await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: emailController.text.trim(),
                password: passwordController.text.trim())

            // ignore: body_might_complete_normally_catch_error
            .catchError((errorMsg) {
      cMethods.displaySnackbar(errorMsg.toString(), context);
    }))
        .user;

    if (!context.mounted) return;
    Navigator.pop(context);

    // ignore: deprecated_member_use
    DatabaseReference adminRef = FirebaseDatabase(databaseURL: flutterURL)
        .ref()
        .child("admins")
        .child(adminFirebase!.uid);
    Map userDataMap = {
      "email": emailController.text.trim(),
      "id": adminFirebase.uid,
    };
    adminRef.set(userDataMap);
  }

  ///******************************************************************************* */
  ///
  ///Đăng nhập admin
  loginProcess() {
    cMethods.checkConnectivity(context);
    loginFormValidation();
  }

  loginFormValidation() {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      cMethods.displaySnackbar("Vui lòng nhập đầy đủ thông tin", context);
    } else if (!RegExp(r'\S+@\S+\.\S+').hasMatch(emailController.text)) {
      cMethods.displaySnackbar("Email không hợp lệ", context);
    } else if (passwordController.text.trim().length <= 5) {
      cMethods.displaySnackbar("Mật khẩu phải từ 6 kí tự trở lên", context);
    } else {
      // Dang ky sau khi da xac thuc
      loginAdmin();
    }
  }

  loginAdmin() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: 'Đang đăng nhập...'),
    );

    final User? adminFirebase = (await FirebaseAuth.instance
            .signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    )
            // ignore: body_might_complete_normally_catch_error
            .catchError((errorMsg) {
      cMethods.displaySnackbar("Tài khoản không tồn tại!", context);

      Navigator.pop(context);
    }))
        .user;

    if (!context.mounted) return;
    Navigator.pop(context);

    if (adminFirebase != null) {
      // ignore: deprecated_member_use
      DatabaseReference usersRef = FirebaseDatabase(databaseURL: flutterURL)
          .ref()
          .child('admins')
          .child(adminFirebase.uid);
      usersRef.once().then((snap) {
        if (snap.snapshot.value != null) {
          //lấy tên của người dùng đã đăng nhập
          adminEmail = (snap.snapshot.value as Map)['email'];

          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SideNavigator(),
              ));
        } else {
          FirebaseAuth.instance.signOut();
          cMethods.displaySnackbar("Tài khoản không tồn tại!", context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SelectionArea(
        child: Scaffold(
          backgroundColor: MyColor.greyLight,
          body: Center(
            child: Container(
              width: 400,
              decoration: const BoxDecoration(
                color: MyColor.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: MyColor.grey,
                    blurRadius: 3,
                    offset: Offset(3, 3),
                  ),
                ],
              ),
              child: Wrap(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: MyColor.green,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "ADMIN LOGIN",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: MyColor.white),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(fontSize: 20),
                      decoration: const InputDecoration(
                          hintText: 'Email',
                          filled: true,
                          fillColor: MyColor.white,
                          hintStyle: TextStyle(
                            color: MyColor.grey,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(15),
                            ),
                          ),
                          prefixIcon: Icon(Icons.email)),
                    ),
                  ),

                  //Mat khau
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: TextField(
                      controller: passwordController,
                      keyboardType: TextInputType.text,
                      obscureText: !_passwordVisible,
                      style: const TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        hintText: 'Mật khẩu',
                        filled: true,
                        fillColor: MyColor.white,
                        hintStyle: const TextStyle(
                          color: MyColor.grey,
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(15),
                          ),
                        ),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                          icon: Icon(_passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                        ),
                      ),
                    ),
                  ),

                  //Nut Dang nhap
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Center(
                      child: SizedBox(
                        height: 60,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            //tiến hành đăng nhập
                            loginProcess();
                            //registrationProcess();
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(MyColor.green),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                              ),
                            ),
                          ),
                          child: const Text('ĐĂNG NHẬP',
                              style: TextStyle(
                                  fontSize: 20, color: MyColor.white)),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
