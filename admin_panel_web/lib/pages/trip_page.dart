import 'package:flutter/material.dart';

import '../methods/common_methods.dart';
import '../widgets/trip_data_list.dart';

class TripPage extends StatefulWidget {
  static const String id = "pageTrip";
  const TripPage({super.key});

  @override
  State<TripPage> createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> {
  CommonMethods cMethod = CommonMethods();
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Scaffold(
          body: SelectionArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: TripDataList(),
          ),
        ),
      )),
    );
  }
}
