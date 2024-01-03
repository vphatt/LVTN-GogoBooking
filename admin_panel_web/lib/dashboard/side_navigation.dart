import 'package:admin_panel_web/authentication/login_screen.dart';
import 'package:admin_panel_web/pages/driver_page.dart';
import 'package:admin_panel_web/pages/other_page.dart';
import 'package:admin_panel_web/pages/rating_page.dart';
import 'package:admin_panel_web/pages/trip_page.dart';
import 'package:admin_panel_web/pages/user_page.dart';
import 'package:admin_panel_web/utils/global_var.dart';
import 'package:admin_panel_web/utils/my_color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SideNavigation extends StatefulWidget {
  const SideNavigation({super.key});

  @override
  State<SideNavigation> createState() => _SideNavigationState();
}

class _SideNavigationState extends State<SideNavigation> {
  Widget selectedScreen = const DriverPage();

  routeToPage(selectedPage) {
    switch (selectedPage.route) {
      // case DashboardPage.id:
      //   setState(() {
      //     selectedScreen = const DashboardPage();
      //   });
      //   break;
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
      case RatingPage.id:
        setState(() {
          selectedScreen = const RatingPage();
        });
        break;
      case OtherPage.id:
        setState(() {
          selectedScreen = const OtherPage();
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
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.person),
                ),
                Text(
                  adminEmail,
                  style: const TextStyle(color: MyColor.white, fontSize: 20),
                ),
              ],
            ),
          ),
          const VerticalDivider(
            indent: 10,
            endIndent: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    title: const Text("ĐĂNG XUẤT?",
                        style: TextStyle(fontSize: 20)),
                    content: const Text("Bạn có chắc chắn muốn đăng xuất này?"),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: MyColor.grey,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5))),
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            "HUỶ",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: MyColor.white),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          FirebaseAuth.instance.signOut();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const LoginScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: MyColor.red,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5))),
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            "ĐĂNG XUẤT",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: MyColor.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: const Icon(
                Icons.logout,
                color: MyColor.white,
              ),
            ),
          ),
        ],
      ),
      sideBar: SideBar(
        iconColor: MyColor.green,
        textStyle:
            const TextStyle(color: MyColor.black, fontWeight: FontWeight.bold),
        backgroundColor: MyColor.white,
        activeBackgroundColor: MyColor.green,
        //borderColor: MyColor.red,
        activeTextStyle:
            const TextStyle(color: MyColor.white, fontWeight: FontWeight.bold),
        items: const [
          // AdminMenuItem(
          //     title: "DashBoard",
          //     route: DashboardPage.id,
          //     icon: FontAwesomeIcons.locationArrow),
          AdminMenuItem(
            title: "Người dùng",
            icon: FontAwesomeIcons.userGroup,
            children: [
              AdminMenuItem(
                  title: "Tài Xế",
                  route: DriverPage.id,
                  icon: FontAwesomeIcons.car),
              AdminMenuItem(
                  title: "Khách Hàng",
                  route: UserPage.id,
                  icon: FontAwesomeIcons.person),
            ],
          ),
          AdminMenuItem(
              title: "Chuyến đi",
              route: TripPage.id,
              icon: FontAwesomeIcons.locationArrow),
          AdminMenuItem(
              title: "Đánh giá",
              route: RatingPage.id,
              icon: FontAwesomeIcons.star),
          AdminMenuItem(
              title: "Tài nguyên",
              route: OtherPage.id,
              icon: FontAwesomeIcons.gear),
        ],
        selectedRoute: "/",
        onSelected: (selectedPage) {
          routeToPage(selectedPage);
        },
      ),
      body: selectedScreen,
    );
  }
}
