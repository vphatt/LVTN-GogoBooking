import 'package:admin_panel_web/widgets/user_data_list.dart';
import 'package:flutter/material.dart';

import '../methods/common_methods.dart';

class UserPage extends StatefulWidget {
  static const String id = "pageUser";
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  CommonMethods cMethod = CommonMethods();
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Scaffold(
          body: SelectionArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: UserDataList(),
          ),
        ),
      )),
    );
  }
}
