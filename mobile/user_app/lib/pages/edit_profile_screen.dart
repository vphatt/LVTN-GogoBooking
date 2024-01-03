import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:user_app/global/global_var.dart';
import 'package:user_app/pages/splash_page.dart';
import 'package:user_app/widgets/loading_dialog.dart';

import '../methods/common_methods.dart';
import '../utils/my_color.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  // final TextEditingController confirmController = TextEditingController();

  var emailFocusNode = FocusNode();
  var nameFocusNode = FocusNode();
  var phoneFocusNode = FocusNode();
  var passwordFocusNode = FocusNode();

  //Bien lay hinh anh
  XFile? imageFile;

  String uploadImageURL = '';
  //String? currentEmail = FirebaseAuth.instance.currentUser!.email;

  CommonMethods cMethods = CommonMethods();

  @override
  void initState() {
    super.initState();
    initialInfo();
  }

  //Lấy dữ dữ về
  initialInfo() async {
    DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(FirebaseAuth.instance.currentUser!.uid);

    await userRef.once().then((snap) {
      setState(() {
        usernameController.text = (snap.snapshot.value as Map)['name'];
        emailController.text = (snap.snapshot.value as Map)['email'];
        phoneController.text = (snap.snapshot.value as Map)['phone'];
      });
    });
  }

  // updateProcess(String property) {
  //   //Kiểm tra kết nối mạng
  //   cMethods.checkConnectivity(context);

  //   if (property == "name") {
  //     updateUserName();
  //   } else if (property == "avatar") {
  //     uploadImagetoStorage();
  //   } else if (property == "email") {
  //     updateEmail();
  //   } else if (property == "phone") {
  //     updatePhoneNumber();
  //   }
  // }

  showUpdatedDialog(String header, String content) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5))),
        title: Text(header, style: const TextStyle(fontSize: 20)),
        content: Text(content),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: MyColor.green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5))),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                "OK",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: MyColor.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  updateUserName() async {
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            LoadingDialog(messageText: "Đang xử lý..."));
    DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(FirebaseAuth.instance.currentUser!.uid);

    await userRef.update({
      "name": usernameController.text,
    });

    setState(() {
      userNameGB = usernameController.text;
    });

    // ignore: use_build_context_synchronously
    Navigator.pop(context);

    // ignore: use_build_context_synchronously
    cMethods.displaySnackbar("Cập nhật tên thành công!", context);
  }

  reAuthenticateForEmail(String currentEmail, String password) async {
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            LoadingDialog(messageText: "Kiểm tra tài khoản..."));

    final user = FirebaseAuth.instance.currentUser!;
    await user.reauthenticateWithCredential(EmailAuthProvider.credential(
      email: currentEmail,
      password: password,
    ));

    // ignore: use_build_context_synchronously
    Navigator.pop(context);

    updateEmail(password);
  }

  updateEmail(String password) async {
    final user = FirebaseAuth.instance.currentUser!;
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            LoadingDialog(messageText: "Xác thực email mới..."));

    await user.verifyBeforeUpdateEmail(emailController.text);

    // ignore: use_build_context_synchronously
    Navigator.pop(context);

    // ignore: use_build_context_synchronously
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5))),
        title: const Text("ĐĂNG NHẬP LẠI", style: TextStyle(fontSize: 20)),
        content: const Text(
            "Truy cập liên kết gửi đến email mới của bạn\nSau đó đăng nhập lại ứng dụng"),
        actions: [
          ElevatedButton(
            onPressed: () async {
              user.reload();
              Navigator.pop(context);

              FirebaseAuth.instance.signOut();

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => const SplashScreen()));
              //Restart.restartApp();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: MyColor.green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5))),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                "ĐĂNG NHẬP LẠI",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: MyColor.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  updatePhoneNumber() async {
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            LoadingDialog(messageText: "Đang xử lý..."));
    DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(FirebaseAuth.instance.currentUser!.uid);

    await userRef.update({
      "phone": phoneController.text,
    });

    setState(() {
      userPhoneGB = phoneController.text;
    });

    // ignore: use_build_context_synchronously
    Navigator.pop(context);

    // ignore: use_build_context_synchronously
    cMethods.displaySnackbar("Cập nhật số điện thoại thành công!", context);
  }

  //Tải hình ảnh lên kho lưu trữ
  uploadImagetoStorage() async {
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            LoadingDialog(messageText: "Đang cập nhật ảnh..."));

    String imageId = DateTime.now().toIso8601String();
    Reference referenceImage = FirebaseStorage.instance
        .ref()
        .child("Images")
        .child("UserAvt")
        .child(imageId);

    UploadTask uploadTask = referenceImage.putFile(File(imageFile!.path));

    TaskSnapshot snapshot = await uploadTask;

    uploadImageURL = await snapshot.ref.getDownloadURL();

    DatabaseReference driverRef = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(FirebaseAuth.instance.currentUser!.uid);

    await driverRef.update({
      "avatar": uploadImageURL,
    });

    setState(() {
      uploadImageURL;
      userAvtGB = uploadImageURL;
    });

    // ignore: use_build_context_synchronously
    Navigator.pop(context);

    // ignore: use_build_context_synchronously
    cMethods.displaySnackbar("Cập nhật ảnh thành công!", context);
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
    // setState(() {
    //   usernameController.text = userNameGB;
    //   emailController.text = userEmailGB;
    //   phoneController.text = userPhoneGB;
    // });
    final screenSize = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 70,
          elevation: 0.0,
          iconTheme: const IconThemeData(color: MyColor.white),
          centerTitle: true,
          title: const Text(
            'Hồ sơ',
            style: TextStyle(color: MyColor.white),
          ),
          backgroundColor: MyColor.green,
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: screenSize.width / 20),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8),
                child: Center(
                  child: Text(
                    'THÔNG TIN KHÁCH HÀNG',
                    style: TextStyle(color: MyColor.black, fontSize: 22),
                  ),
                ),
              ),

              //Ảnh khách hàng
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Stack(
                      children: [
                        imageFile == null
                            ? //Nếu người dùng chưa chọn hình ảnh
                            CircleAvatar(
                                radius: 70,
                                backgroundImage: NetworkImage(userAvtGB),
                              )
                            : CircleAvatar(
                                radius: 70,
                                backgroundImage:
                                    FileImage(File(imageFile!.path)),
                              ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                              radius: 20,
                              backgroundColor: MyColor.green,
                              child: IconButton(
                                  onPressed: () {
                                    selectImageFromGallery();
                                  },
                                  icon: const Icon(
                                    Icons.edit,
                                    color: MyColor.white,
                                  ))),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 50,
                        //width: 150,
                        child: imageFile != null
                            ? ElevatedButton(
                                onPressed: () {
                                  //uploadImagetoStorage();
                                  uploadImagetoStorage();
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
                                child: const Text('CẬP NHẬT ẢNH',
                                    style: TextStyle(
                                        fontSize: 15, color: MyColor.white)),
                              )
                            : ElevatedButton(
                                onPressed: () {
                                  //uploadImagetoStorage();
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(MyColor.grey),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    const RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(15)),
                                    ),
                                  ),
                                ),
                                child: const Text('CẬP NHẬT ẢNH',
                                    style: TextStyle(
                                        fontSize: 15, color: MyColor.white)),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(),

              //Ten nguoi dung
              Padding(
                padding: const EdgeInsets.all(5),
                child: ListTile(
                  title: TextField(
                    focusNode: nameFocusNode,
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
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      nameFocusNode.unfocus();
                      if (usernameController.text.trim().isEmpty) {
                        cMethods.displaySnackbar(
                            "Vui lòng nhập tên mới", context);
                      } else if (usernameController.text.trim() == userNameGB) {
                        cMethods.displaySnackbar(
                            "Tên mới khác với tên cũ", context);
                      } else {
                        updateUserName();
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(MyColor.green),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                      ),
                    ),
                    child: const Text('CẬP NHẬT',
                        style: TextStyle(fontSize: 15, color: MyColor.white)),
                  ),
                ),
              ),

              //Email
              Padding(
                padding: const EdgeInsets.all(5),
                child: ListTile(
                  title: TextField(
                    focusNode: emailFocusNode,
                    controller: emailController,
                    keyboardType: TextInputType.text,
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
                      prefixIcon: Icon(Icons.mail),
                    ),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      emailFocusNode.unfocus();
                      //Tái xác thực, nhập lại mật khẩu trước khi thực hiện
                      if (emailController.text.trim().isEmpty) {
                        cMethods.displaySnackbar(
                            "Vui lòng nhập email mới", context);
                      } else if (emailController.text.trim() == userEmailGB) {
                        cMethods.displaySnackbar(
                            "Email mới khác với email cũ", context);
                      } else {
                        // Dang ky sau khi da xac thuc
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            surfaceTintColor: MyColor.white,
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            title: const Text("XÁC NHẬN MẬT KHẨU:",
                                style: TextStyle(fontSize: 20)),
                            content: SizedBox(
                              height: 100,
                              width: 300,
                              child: TextField(
                                focusNode: passwordFocusNode,
                                obscureText: true,
                                controller: passwordController,
                                keyboardType: TextInputType.text,
                                style: const TextStyle(fontSize: 20),
                                decoration: const InputDecoration(
                                  hintText: 'Mật khẩu',
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
                                  prefixIcon: Icon(Icons.key),
                                ),
                              ),
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: MyColor.grey,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5))),
                                child: const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    "HUỶ",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: MyColor.white),
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  passwordFocusNode.unfocus();
                                  reAuthenticateForEmail(
                                    userEmailGB,
                                    passwordController.text,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: MyColor.green,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5))),
                                child: const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    "XÁC NHẬN",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: MyColor.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(MyColor.green),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                      ),
                    ),
                    child: const Text('CẬP NHẬT',
                        style: TextStyle(fontSize: 15, color: MyColor.white)),
                  ),
                ),
              ),

              //So dien thoai
              Padding(
                padding: const EdgeInsets.all(5),
                child: ListTile(
                  title: TextField(
                    focusNode: phoneFocusNode,
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
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      phoneFocusNode.unfocus();
                      if (phoneController.text.trim().length < 9 ||
                          phoneController.text.trim().length > 10) {
                        cMethods.displaySnackbar(
                            "Số điện thoại không hợp lệ", context);
                      } else {
                        updatePhoneNumber();
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(MyColor.green),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                      ),
                    ),
                    child: const Text('CẬP NHẬT',
                        style: TextStyle(fontSize: 15, color: MyColor.white)),
                  ),
                ),
              ),

              //Mat khau
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: TextField(
              //     controller: passwordController,
              //     keyboardType: TextInputType.text,
              //     obscureText: !_passwordVisible,
              //     style: const TextStyle(fontSize: 20),
              //     decoration: InputDecoration(
              //       hintText: 'Mật khẩu',
              //       filled: true,
              //       fillColor: MyColor.white,
              //       hintStyle: const TextStyle(
              //         color: MyColor.grey,
              //       ),
              //       border: const OutlineInputBorder(
              //         borderRadius: BorderRadius.all(
              //           Radius.circular(15),
              //         ),
              //       ),
              //       prefixIcon: const Icon(Icons.lock),
              //       suffixIcon: IconButton(
              //         onPressed: () {
              //           setState(() {
              //             _passwordVisible = !_passwordVisible;
              //           });
              //         },
              //         icon: Icon(_passwordVisible
              //             ? Icons.visibility
              //             : Icons.visibility_off),
              //       ),
              //     ),
              //   ),
              // ),

              // //Xac nhan mat khau
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: TextField(
              //     controller: confirmController,
              //     keyboardType: TextInputType.text,
              //     obscureText: !_confirmVisible,
              //     style: const TextStyle(fontSize: 20),
              //     decoration: InputDecoration(
              //       hintText: 'Nhập lại mật khẩu',
              //       filled: true,
              //       fillColor: MyColor.white,
              //       hintStyle: const TextStyle(
              //         color: MyColor.grey,
              //       ),
              //       border: const OutlineInputBorder(
              //         borderRadius: BorderRadius.all(
              //           Radius.circular(15),
              //         ),
              //       ),
              //       prefixIcon: const Icon(Icons.lock_outline),
              //       suffixIcon: IconButton(
              //         onPressed: () {
              //           setState(() {
              //             _confirmVisible = !_confirmVisible;
              //           });
              //         },
              //         icon: Icon(_confirmVisible
              //             ? Icons.visibility
              //             : Icons.visibility_off),
              //       ),
              //     ),
              //   ),
              // ),

              //Nut Dang ky
              // ElevatedButton(
              //   onPressed: () {
              //     //uploadImagetoStorage();
              //     updateInfo();
              //   },
              //   style: ButtonStyle(
              //     backgroundColor: MaterialStateProperty.all(MyColor.green),
              //     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              //       const RoundedRectangleBorder(
              //         borderRadius: BorderRadius.all(Radius.circular(15)),
              //       ),
              //     ),
              //   ),
              //   child: const Text('CẬP NHẬT THÔNG TIN',
              //       style: TextStyle(fontSize: 15, color: MyColor.white)),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
