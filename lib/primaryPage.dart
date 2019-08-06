import 'package:flutter/material.dart';

import 'dashboardPage.dart';
import 'newsPage.dart';
import 'schedulePage.dart';
import 'accountPage.dart';

class PrimaryHomepage extends StatefulWidget {
  PrimaryHomepage({Key key}) : super(key: key);

  final List<BottomNavigationBarItem> navigationBarChildren = [
    BottomNavigationBarItem(
        icon: new Icon(Icons.dashboard), title: new Text("Dashboard")),
    BottomNavigationBarItem(
        icon: new Icon(Icons.pages), title: new Text("News")),
    BottomNavigationBarItem(
        icon: new Icon(Icons.date_range), title: new Text("Schedule")),
    BottomNavigationBarItem(
        icon: new Icon(Icons.account_box), title: new Text("Account")),
  ];

  final List<Widget> children = [
    DashboardWidget(),
    NewsWidget(),
    ScheduleWidget(),
    AccountWidget(),
  ];

  @override
  _PrimaryHomepageState createState() => _PrimaryHomepageState();
}

class _PrimaryHomepageState extends State<PrimaryHomepage> {
  final controller = PageController();
  int pageSelection = 0;

  void goToPage(int index) {
    controller.animateToPage(index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic);
  }

  void changedPage(int index) {
    setState(() {
      pageSelection = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              child: Image.asset('images/logo-lowres.png'),
              height: 65.0,
              padding: EdgeInsets.all(5.0),
            ),
            Expanded(
              child: PageView(
                  controller: controller,
                  onPageChanged: changedPage,
                  children: widget.children),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
          onTap: goToPage,
          type: BottomNavigationBarType.fixed,
          currentIndex: pageSelection,
          items: widget.navigationBarChildren),
    );
  }
}
