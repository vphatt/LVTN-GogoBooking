import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:driver_app/pages/splash_page.dart';
import 'package:driver_app/utils/my_color.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Driver App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: MyColor.green),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
