import 'package:flutter/material.dart';

import 'package:kvis_sf/views/DashboardPage.dart';
import 'package:kvis_sf/views/NewsPage.dart';
import 'package:kvis_sf/views/SchedulePage.dart';
import 'package:kvis_sf/views/AccountPage.dart';

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
  int _pageNumber = 0;

  void _goToPage(int index) {
    controller.animateToPage(index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic);
  }

  void _changedPage(int index) {
    setState(() {
      _pageNumber = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              child: Image.asset('images/header-logo.png'),
              height: 65.0,
              padding: EdgeInsets.all(5.0),
            ),
            Expanded(
              child: PageView(
                  controller: controller,
                  onPageChanged: _changedPage,
                  children: widget.children),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
          onTap: _goToPage,
          type: BottomNavigationBarType.fixed,
          currentIndex: _pageNumber,
          items: widget.navigationBarChildren),
    );
  }
}
