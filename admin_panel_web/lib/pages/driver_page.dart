import 'package:admin_panel_web/methods/common_methods.dart';
import 'package:admin_panel_web/widgets/driver_data_list.dart';
import 'package:flutter/material.dart';

class DriverPage extends StatefulWidget {
  static const String id = "pageDriver";
  const DriverPage({super.key});

  @override
  State<DriverPage> createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
  CommonMethods cMethod = CommonMethods();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Scaffold(
          body: SelectionArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: DriverDataList(),
          ),
        ),
      )),
    );
  }
}
