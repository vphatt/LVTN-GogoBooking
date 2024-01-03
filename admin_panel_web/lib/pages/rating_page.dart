import 'package:admin_panel_web/widgets/rating_data_list.dart';
import 'package:flutter/material.dart';

import '../methods/common_methods.dart';

class RatingPage extends StatefulWidget {
  static const String id = "pageRating";
  const RatingPage({super.key});

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  CommonMethods cMethod = CommonMethods();
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Scaffold(
          body: SelectionArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: RatingDataList(),
          ),
        ),
      )),
    );
  }
}
