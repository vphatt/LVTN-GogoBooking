import 'package:driver_app/pages/home_page.dart';
import 'package:driver_app/pages/profile_page.dart';
import 'package:driver_app/pages/trips_page.dart';
import 'package:driver_app/utils/my_color.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  //Sử dụng tab cho trang này
  TabController? tabController;
  int index = 0; //Index chuyển trang

  //Xác định index để đồng bộ thứ tự chuyển trang
  tabClicked(int i) {
    setState(() {
      index = i;
      tabController!.index = index;
    });
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: tabController,
          children: const [
            HomePage(),
            //IncomePage(),
            TripsPage(),
            ProfilePage(),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black.withOpacity(.1),
              )
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenSize.width / 50,
                vertical: screenSize.height / 60),
            child: GNav(
              haptic: true,
              //tabBorderRadius: 5,
              duration: const Duration(milliseconds: 50),
              gap: 5,
              color: MyColor.grey,
              activeColor: MyColor.green,
              iconSize: 30,
              tabBackgroundColor: MyColor.green.withOpacity(0.2),
              padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width / 20,
                  vertical: screenSize.height / 70),
              tabs: const [
                GButton(
                  icon: Icons.home,
                  text: 'Trang chủ',
                ),
                // GButton(
                //   icon: Icons.route,
                //   text: 'Thu nhập',
                // ),
                GButton(
                  icon: Icons.map,
                  text: 'Chuyến đi',
                ),
                GButton(
                  icon: Icons.person,
                  text: 'Hồ sơ',
                )
              ],
              selectedIndex: index,
              onTabChange: tabClicked,
            ),
          ),
        ),
      ),
    );
  }
}
