import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:driver_app/controller/splash_controller.dart';
import 'package:driver_app/utils/my_color.dart';
//import 'package:user_app/constants/notification/notification_custom.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final splashController = Get.put(SplashController());

  @override
  void initState() {
    super.initState();
    //MyNotification.requestNotificationPermission(context);
    splashController.checkPermission(context);
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(
    //     const SystemUiOverlayStyle(statusBarColor: MyColor.white));

    return SafeArea(
      child: Scaffold(
        backgroundColor: MyColor.white,
        body: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Center(
                child: Image.asset('assets/images/logogif.gif'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
