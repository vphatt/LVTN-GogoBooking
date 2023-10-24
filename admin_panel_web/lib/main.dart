import 'package:admin_panel_web/dashboard/side_navigation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'utils/my_color.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyA5l04KaI6a4WqVlsBY-FPjNS4r1HAvORo",
      authDomain: "gogobooking-5ade1.firebaseapp.com",
      databaseURL:
          "https://gogobooking-5ade1-default-rtdb.asia-southeast1.firebasedatabase.app",
      projectId: "gogobooking-5ade1",
      storageBucket: "gogobooking-5ade1.appspot.com",
      messagingSenderId: "432655298375",
      appId: "1:432655298375:web:2dbae2fd764b5f3568e662",
      measurementId: "G-PCZGVZDFZL",
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gogo Web Admin Panel',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: MyColor.green),
        useMaterial3: true,
      ),
      home: const SideNavigator(),
    );
  }
}