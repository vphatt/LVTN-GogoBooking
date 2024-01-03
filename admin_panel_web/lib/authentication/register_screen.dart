import 'package:admin_panel_web/authentication/login_screen.dart';
import 'package:admin_panel_web/methods/common_methods.dart';
import 'package:admin_panel_web/utils/my_color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../dashboard/side_navigation.dart';
import '../utils/global_var.dart';
import '../utils/loading_dialog.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  bool _passwordVisible = false;
  bool _confirmVisible = false;

  CommonMethods cMethods = CommonMethods();

  registrationProcess() {
    cMethods.checkConnectivity(context);

    registerFormValidation();
  }

  registerFormValidation() {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      cMethods.displaySnackbar("Vui lòng nhập đầy đủ thông tin", context);
    } else if (nameController.text.trim().length < 3) {
      cMethods.displaySnackbar(
          "Tên người dùng phải từ 4 kí tự trở lên", context);
    } else if (!RegExp(r'\S+@\S+\.\S+').hasMatch(emailController.text)) {
      cMethods.displaySnackbar("Email không hợp lệ", context);
    } else if (passwordController.text.trim().length <= 4) {
      cMethods.displaySnackbar("Mật khẩu phải từ 5 kí tự trở lên", context);
    } else if (passwordController.text.trim() !=
        confirmController.text.trim()) {
      cMethods.displaySnackbar("Mật khẩu xác nhận không khớp", context);
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
      // if(errorMsg is PlatformException) {
      //   if(s)
      // }
      if (errorMsg.code == "email-already-in-use") {
        Navigator.pop(context);
        cMethods.displaySnackbar("Email này đã tồn tại!", context);
      } else if (errorMsg.code == "weak-password") {
        Navigator.pop(context);
        cMethods.displaySnackbar("Mật khẩu quá yếu!", context);
      }
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
      "name": nameController.text.trim(),
    };
    adminRef.set(userDataMap);

    setState(() {
      adminEmail = emailController.text.trim();
    });

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SideNavigation(),
        ));
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
                            "ADMIN REGISTER",
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
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: TextField(
                      controller: nameController,
                      keyboardType: TextInputType.text,
                      style: const TextStyle(fontSize: 20),
                      decoration: const InputDecoration(
                        hintText: 'Họ và tên',
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
                        prefixIcon: Icon(Icons.person),
                      ),
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
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: TextField(
                      controller: confirmController,
                      keyboardType: TextInputType.text,
                      obscureText: !_confirmVisible,
                      style: const TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        hintText: 'Nhập lại mật khẩu',
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
                              _confirmVisible = !_confirmVisible;
                            });
                          },
                          icon: Icon(_confirmVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                        ),
                      ),
                    ),
                  ),

                  //Nut Dang ky
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Center(
                      child: SizedBox(
                        height: 60,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            //tiến hành đăng nhập
                            //loginProcess();
                            registrationProcess();
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(MyColor.red),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                              ),
                            ),
                          ),
                          child: const Text('ĐĂNG KÝ',
                              style: TextStyle(
                                  fontSize: 20, color: MyColor.white)),
                        ),
                      ),
                    ),
                  ),
                  const Center(
                    child: Text(
                      "HOẶC",
                      style: TextStyle(
                          color: MyColor.grey,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
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
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ));
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
