import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  static const String id = "/";
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/dashboard.png',
          height: 300,
        ),
      ],
    );
  }
}
