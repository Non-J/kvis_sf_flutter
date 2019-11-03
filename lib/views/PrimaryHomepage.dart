import 'package:flutter/material.dart';
import 'package:kvis_sf/views/DashboardPage.dart';
import 'package:kvis_sf/views/SchedulePage.dart';

class primaryHomepage extends StatefulWidget {
  primaryHomepage({Key key}) : super(key: key);

  final PageController pageController = PageController();

  final List<BottomNavigationBarItem> navigationBarChildren = [
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard),
      title: Text('Dashboard'),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_today),
      title: Text('Schedule'),
    ),
  ];

  final List<Widget> children = [
    DashboardWidget(),
    ScheduleWidget(),
  ];

  @override
  _primaryHomepageState createState() => _primaryHomepageState();
}

class _primaryHomepageState extends State<primaryHomepage> {
  int _pageNumber = 0;

  void _goToPage(int index) {
    widget.pageController.animateToPage(index,
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
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onLongPress: () {
                Navigator.pushNamed(context, '/debug');
              },
              child: Container(
                child: Image.asset('images/header-logo.png'),
                height: 65.0,
                padding: EdgeInsets.all(5.0),
                color: Color.fromRGBO(212, 234, 209, 1.0),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 1.0],
                    colors: [
                      Color.fromRGBO(212, 234, 209, 1.0),
                      Color.fromRGBO(184, 213, 233, 1.0),
                    ],
                  ),
                ),
                child: PageView(
                    controller: widget.pageController,
                    onPageChanged: _changedPage,
                    children: widget.children),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(184, 213, 233, 1.0),
        ),
        child: BottomNavigationBar(
          onTap: _goToPage,
          type: BottomNavigationBarType.fixed,
          elevation: 0.0,
          backgroundColor: Color.fromRGBO(255, 255, 255, 0.0),
          currentIndex: _pageNumber,
          items: widget.navigationBarChildren,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text('Profile'),
        icon: Icon(Icons.person),
        onPressed: () async {
          Navigator.of(context).pushNamed('/profile');
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
