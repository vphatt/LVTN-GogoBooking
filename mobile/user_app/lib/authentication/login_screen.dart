import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:user_app/authentication/register_screen.dart';
import 'package:user_app/widgets/loading_dialog.dart';

import '../global/global_var.dart';
import '../methods/common_methods.dart';
import '../pages/home_page.dart';
import '../utils/my_color.dart';

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

  loginProcess() {
    //Kiểm tra kết nối mạng
    cMethods.checkConnectivity(context);

    //Xác th form đăng nhập
    loginFormValidation();
  }

  loginFormValidation() {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      cMethods.displaySnackbar("Vui lòng nhập đầy đủ thông tin", context);
    } else if (!emailController.text.contains('@')) {
      cMethods.displaySnackbar("Email không hợp lệ", context);
    } else if (passwordController.text.trim().length <= 5) {
      cMethods.displaySnackbar("Mật khẩu phải từ 6 kí tự trở lên", context);
    } else {
      loginUser();
    }
  }

  //Phương thức đăng nhập
  loginUser() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: 'Đang đăng nhập...'),
    );

    final User? userFirebase = (await FirebaseAuth.instance
            .signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    )
            // ignore: body_might_complete_normally_catch_error
            .catchError((errorMsg) {
      cMethods.displaySnackbar(errorMsg.toString(), context);
    }))
        .user;

    if (!context.mounted) return;
    Navigator.pop(context);

    //Kiểm tra người dùng có tồn tại hay không
    if (userFirebase != null) {
      // ignore: deprecated_member_use
      DatabaseReference usersRef = FirebaseDatabase(databaseURL: flutterURL)
          .ref()
          .child('users')
          .child(userFirebase.uid);
      usersRef.once().then((snap) {
        if (snap.snapshot.value != null) {
          //Kiem tra tai khoan co bi khoa khong
          if ((snap.snapshot.value as Map)["blockStatus"] == 'no') {
            //lấy tên của người dùng đã đăng nhập
            userNameGB = (snap.snapshot.value as Map)['name'];
            userPhoneGB = (snap.snapshot.value as Map)['phone'];
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
                ));
          } else {
            FirebaseAuth.instance.signOut();
            cMethods.displaySnackbar(
                "Tài khoản bị khoá! Liên hệ phatduongvgt@gmail.com để được hỗ trợ.",
                context);
          }
        } else {
          FirebaseAuth.instance.signOut();
          cMethods.displaySnackbar("Tài khoản không tồn tại!", context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size; //Kich thuoc man hinh
    return Scaffold(
      backgroundColor: MyColor.green,
      body: SingleChildScrollView(
        child: Column(
          children: [
            //Phan logo
            Container(
              //height: screenSize.height / 2,
              decoration: const BoxDecoration(),
              child: Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: screenSize.height / 10,
                    ),
                    Text(
                      'CHÀO MỪNG ĐẾN VỚI',
                      style: TextStyle(
                          color: MyColor.white,
                          fontSize: screenSize.width / 15,
                          fontWeight: FontWeight.bold),
                    ),
                    Image.asset(
                      'assets/images/logo_small.png',
                      fit: BoxFit.fitWidth,
                    ),
                    const SizedBox(
                      height: 10,
                    )
                  ],
                ),
              ),
            ),

            //Phan dang ky
            Container(
              padding: EdgeInsets.symmetric(horizontal: screenSize.width / 15),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Center(
                      child: Text(
                        'KHÁCH HÀNG ĐĂNG NHẬP',
                        style: TextStyle(color: MyColor.white, fontSize: 20),
                      ),
                    ),
                  ),

                  //Email
                  Padding(
                    padding: const EdgeInsets.all(8.0),
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
                    padding: const EdgeInsets.all(8.0),
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
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 70,
                      width: 200,
                      child: ElevatedButton(
                        onPressed: () {
                          //tiến hành đăng nhập
                          loginProcess();
                        },
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                          ),
                        ),
                        child: const Text('ĐĂNG NHẬP',
                            style: TextStyle(fontSize: 20)),
                      ),
                    ),
                  )
                ],
              ),
            ),

            //Nut ve dang nhap
            RichText(
              text: TextSpan(
                //text: 'Bạn đã có tài khoản',
                children: <WidgetSpan>[
                  WidgetSpan(
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Bạn chưa có tài khoản?',
                        style: TextStyle(color: MyColor.white, fontSize: 20),
                      ),
                    ),
                  ),
                  WidgetSpan(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'ĐĂNG KÝ',
                        style: TextStyle(color: MyColor.yellow, fontSize: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
