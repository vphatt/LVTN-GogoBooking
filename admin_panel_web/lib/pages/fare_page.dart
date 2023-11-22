import 'package:flutter/material.dart';

class FarePage extends StatefulWidget {
  static const String id = "pageFare";
  const FarePage({super.key});

  @override
  State<FarePage> createState() => _FarePageState();
}

class _FarePageState extends State<FarePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("Quản ký giá"),
    );
  }
}
