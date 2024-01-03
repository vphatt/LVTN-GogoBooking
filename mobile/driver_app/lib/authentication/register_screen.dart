import 'dart:io';

import 'package:driver_app/pages/dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:driver_app/authentication/login_screen.dart';
import 'package:driver_app/global/global_var.dart';
import 'package:driver_app/methods/common_methods.dart';
import 'package:driver_app/utils/my_color.dart';
import 'package:driver_app/widgets/loading_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

//import 'package:firebase_core/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController vehicleModelController = TextEditingController();
  final TextEditingController vehicleColorController = TextEditingController();
  final TextEditingController carNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  //Bien de thuc hien an/hien password
  bool _passwordVisible = false;
  bool _confirmVisible = false;

  //method tu common_methods.dart
  CommonMethods cMethods = CommonMethods();

  //Bien lay hinh anh
  XFile? imageFile;

  String uploadImageURL = '';

  registrationProcess() {
    //Kiểm tra kết nối mạng
    cMethods.checkConnectivity(context);

    //Xác thuc form đăng ký
    //registerFormValidation();

    if (imageFile != null) {
      uploadImagetoStorage();
    }
  }

  registerFormValidation() {
    if (usernameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        vehicleModelController.text.trim().isEmpty ||
        vehicleColorController.text.trim().isEmpty ||
        carNumberController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        confirmController.text.trim().isEmpty) {
      cMethods.displaySnackbar("Vui lòng nhập đầy đủ thông tin", context);
    } else if (usernameController.text.trim().length < 3) {
      cMethods.displaySnackbar(
          "Tên người dùng phải từ 4 kí tự trở lên", context);
    } else if (!RegExp(r'\S+@\S+\.\S+').hasMatch(emailController.text)) {
      cMethods.displaySnackbar("Email không hợp lệ", context);
    } else if (phoneController.text.trim().length < 9 ||
        phoneController.text.trim().length > 10) {
      cMethods.displaySnackbar("Số điện thoại không hợp lệ", context);
    } else if (passwordController.text.trim().length <= 5) {
      cMethods.displaySnackbar("Mật khẩu phải từ 6 kí tự trở lên", context);
    } else if (passwordController.text.trim() !=
        confirmController.text.trim()) {
      cMethods.displaySnackbar("Mật khẩu xác nhận không khớp", context);
    } else {
      // Dang ky sau khi da xac thuc
      uploadImagetoStorage();
      //registerUser();
    }
  }

  //Tải hình ảnh lên kho lưu trữ
  uploadImagetoStorage() async {
    String imageId = DateTime.now().toIso8601String();
    Reference referenceImage = FirebaseStorage.instance
        .ref()
        .child("Images")
        .child("DriverAvt")
        .child(imageId);

    UploadTask uploadTask = referenceImage.putFile(File(imageFile!.path));

    TaskSnapshot snapshot = await uploadTask;

    uploadImageURL = await snapshot.ref.getDownloadURL();

    setState(() {
      uploadImageURL;
    });

    registerDriver();
  }

  //Hàm tạo người dùng mới
  registerDriver() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: 'Đăng ký tài khoản...'),
    );

    final User? userFirebase = (await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    )
            // ignore: body_might_complete_normally_catch_error
            .catchError((errorMsg) {
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
    DatabaseReference usersRef = FirebaseDatabase(databaseURL: flutterURL)
        .ref()
        .child("drivers")
        .child(userFirebase!.uid);

    // Map driverCarInfo = {
    //   "carModel": vehicleModelController.text.trim(),
    //   "carColor": vehicleColorController.text.trim(),
    //   "carNumber": carNumberController.text.trim(),
    // };

    Map driverDataMap = {
      "name": usernameController.text.trim(),
      "email": emailController.text.trim(),
      "phone": phoneController.text.trim(),
      "avatar": uploadImageURL,
      "car_details": carNumberController.text.trim(),
      "id": userFirebase.uid,
      "rating": 0.0,
      "incomes": 0,
      "blockStatus": "no" //Tinh trang tai khoan co bi khoa hay khong
    };
    usersRef.set(driverDataMap); //lưu thông tin và database

    //Sau khi đăng ký thành công, chuyển người dùng đến trang chủ
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Dashboard(),
        ));
  }

  //Hàm chọn hình ảnh từ thư viện ảnh của thiết bị
  selectImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imageFile = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size; //Kich thuoc man hinh
    return SafeArea(
      child: Scaffold(
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
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        'CHÀO MỪNG ĐẾN VỚI',
                        style: TextStyle(
                            color: MyColor.white,
                            fontSize: screenSize.width / 20,
                            fontWeight: FontWeight.bold),
                      ),
                      Image.asset(
                        'assets/images/logo_small.png',
                        height: 100,
                        fit: BoxFit.fitWidth,
                      ),
                      const SizedBox(
                        height: 5,
                      )
                    ],
                  ),
                ),
              ),

              //Phan dang ky
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: screenSize.width / 15),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Center(
                        child: Text(
                          'NHẬP THÔNG TIN ĐĂNG KÝ',
                          style: TextStyle(color: MyColor.white, fontSize: 20),
                        ),
                      ),
                    ),
                    //Anh chan dung tai xe
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        children: [
                          imageFile == null
                              ? //Nếu người dùng chưa chọn hình ảnh
                              const CircleAvatar(
                                  radius: 60,
                                  backgroundImage: AssetImage(
                                      "assets/images/driver_profile.png"),
                                )
                              : CircleAvatar(
                                  radius: 60,
                                  backgroundImage:
                                      FileImage(File(imageFile!.path)),
                                ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                                radius: 20,
                                backgroundColor: MyColor.white,
                                child: IconButton(
                                    onPressed: () {
                                      selectImageFromGallery();
                                    },
                                    icon: const Icon(
                                      Icons.edit,
                                      color: MyColor.green,
                                    ))),
                          )
                        ],
                      ),
                    ),

                    //Ten nguoi dung
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: usernameController,
                        keyboardType: TextInputType.text,
                        style: const TextStyle(fontSize: 20),
                        decoration: const InputDecoration(
                            hintText: 'Tên người dùng',
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
                            prefixIcon: Icon(Icons.person)),
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

                    //So dien thoai
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(fontSize: 20),
                        decoration: const InputDecoration(
                            hintText: 'Số điện thoại',
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
                            prefixIcon: Icon(Icons.phone)),
                      ),
                    ),

                    //Mau xe
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: TextField(
                    //     controller: vehicleModelController,
                    //     keyboardType: TextInputType.text,
                    //     style: const TextStyle(fontSize: 20),
                    //     decoration: const InputDecoration(
                    //         hintText: 'Mẫu xe',
                    //         filled: true,
                    //         fillColor: MyColor.white,
                    //         hintStyle: TextStyle(
                    //           color: MyColor.grey,
                    //         ),
                    //         border: OutlineInputBorder(
                    //           borderRadius: BorderRadius.all(
                    //             Radius.circular(15),
                    //           ),
                    //         ),
                    //         prefixIcon: Icon(FontAwesomeIcons.car)),
                    //   ),
                    // ),

                    //Mau xe
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: TextField(
                    //     controller: vehicleColorController,
                    //     keyboardType: TextInputType.text,
                    //     style: const TextStyle(fontSize: 20),
                    //     decoration: const InputDecoration(
                    //         hintText: 'Màu xe',
                    //         filled: true,
                    //         fillColor: MyColor.white,
                    //         hintStyle: TextStyle(
                    //           color: MyColor.grey,
                    //         ),
                    //         border: OutlineInputBorder(
                    //           borderRadius: BorderRadius.all(
                    //             Radius.circular(15),
                    //           ),
                    //         ),
                    //         prefixIcon: Icon(FontAwesomeIcons.palette)),
                    //   ),
                    // ),

                    //So xe
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: carNumberController,
                        keyboardType: TextInputType.text,
                        style: const TextStyle(fontSize: 20),
                        decoration: const InputDecoration(
                            hintText: 'Biển số xe',
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
                            prefixIcon: Icon(FontAwesomeIcons.hashtag)),
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

                    //Xac nhan mat khau
                    Padding(
                      padding: const EdgeInsets.all(8.0),
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
                          prefixIcon: const Icon(Icons.lock_outline),
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
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 70,
                        width: 200,
                        child: ElevatedButton(
                          onPressed: () {
                            //Tien hanh dang ky tai khoan
                            registrationProcess();
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                              ),
                            ),
                          ),
                          child: const Text('ĐĂNG KÝ',
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
                          'Bạn đã có tài khoản?',
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
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'ĐĂNG NHẬP',
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
      ),
    );
  }
}
