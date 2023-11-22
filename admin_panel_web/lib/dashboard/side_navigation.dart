import 'package:admin_panel_web/dashboard/dashboard_page.dart';
import 'package:admin_panel_web/pages/driver_page.dart';
import 'package:admin_panel_web/pages/fare_page.dart';
import 'package:admin_panel_web/pages/trip_page.dart';
import 'package:admin_panel_web/pages/user_page.dart';
import 'package:admin_panel_web/utils/my_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SideNavigator extends StatefulWidget {
  const SideNavigator({super.key});

  @override
  State<SideNavigator> createState() => _SideNavigatorState();
}

class _SideNavigatorState extends State<SideNavigator> {
  Widget selectedScreen = const DashboardPage();

  routeToPage(selectedPage) {
    switch (selectedPage.route) {
      case DriverPage.id:
        setState(() {
          selectedScreen = const DriverPage();
        });
        break;
      case UserPage.id:
        setState(() {
          selectedScreen = const UserPage();
        });
        break;
      case TripPage.id:
        setState(() {
          selectedScreen = const TripPage();
        });
        break;
      case FarePage.id:
        setState(() {
          selectedScreen = const FarePage();
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      backgroundColor: MyColor.white,
      appBar: AppBar(
          iconTheme: const IconThemeData(color: MyColor.white),
          backgroundColor: MyColor.green,
          title: Image.asset(
            'assets/images/logo_small.png',
            height: 50,
          )),
      sideBar: SideBar(
        activeBackgroundColor: MyColor.greyLight,
        items: const [
          AdminMenuItem(
              title: "Người dùng",
              icon: FontAwesomeIcons.user,
              children: [
                AdminMenuItem(
                    title: "Tài Xế",
                    route: DriverPage.id,
                    icon: FontAwesomeIcons.car),
                AdminMenuItem(
                    title: "Khách Hàng",
                    route: UserPage.id,
                    icon: FontAwesomeIcons.person),
              ]),
          AdminMenuItem(
              title: "Chuyến",
              icon: FontAwesomeIcons.route,
              children: [
                AdminMenuItem(
                    title: "Chuyến đi",
                    route: TripPage.id,
                    icon: FontAwesomeIcons.locationArrow),
                AdminMenuItem(
                    title: "Giá chuyến",
                    route: FarePage.id,
                    icon: FontAwesomeIcons.dollarSign),
              ])
        ],
        selectedRoute: "/",
        onSelected: (selectedPage) {
          routeToPage(selectedPage);
        },
        // header: Container(
        //   height: 50,
        //   width: double.infinity,
        //   color: MyColor.greenTrans,
        //   child: const Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceAround,
        //     children: [
        //       Icon(
        //         Icons.accessibility,
        //         color: Colors.white,
        //       ),
        //       Icon(
        //         Icons.settings,
        //         color: Colors.white,
        //       ),
        //     ],
        //   ),
        // ),
        // footer: Container(
        //   height: 50,
        //   width: double.infinity,
        //   color: MyColor.greenTrans,
        //   child: const Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceAround,
        //     children: [
        //       Icon(
        //         Icons.admin_panel_settings,
        //         color: Colors.white,
        //       ),
        //       SizedBox(
        //         width: 10,
        //       ),
        //       Icon(
        //         Icons.computer,
        //         color: Colors.white,
        //       ),
        //     ],
        //   ),
        // ),
      ),
      body: selectedScreen,
    );
  }
}
