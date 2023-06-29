// ignore_for_file: unnecessary_import, unused_field, avoid_unnecessary_containers, prefer_const_constructors, sized_box_for_whitespace, no_leading_underscores_for_local_identifiers, unnecessary_const

import 'package:flutter/material.dart';
import 'package:learnflutter/ARKit/arkit_screen.dart';
// import 'package:flutter/widgets.dart';
import 'package:learnflutter/Helpper/defineConstraint.dart';
import 'package:learnflutter/Menu/MenuController.dart';

class TabbarMobiMapCustom extends StatefulWidget {
  const TabbarMobiMapCustom({super.key});

  @override
  State<TabbarMobiMapCustom> createState() => TabbarMobiMapCustomWidgetState();
}

class TabbarMobiMapCustomWidgetState extends State<TabbarMobiMapCustom> with SingleTickerProviderStateMixin {
  late TabController _controller;
  late int _index;

  @override
  void initState() {
    _controller = TabController(length: 5, vsync: this);
    _index = 0;
    super.initState();
  }

  static const List<Widget> _widgetOptions = <Widget>[
    Menu_Controller(),
    ARKitScreen(),
    Center(
      child: Text(
        'Index 2: School',
      ),
    ),
    Center(
        child: Text(
      'Index 3: School',
    )),
    Center(
      child: Text(
        'Index 4: School',
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _widgetOptions.elementAt(_index),
      ),
      bottomNavigationBar: Container(
        child: BottomNavigationBar(
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false, //selected item
          showUnselectedLabels: false,
          selectedFontSize: 0,
          unselectedFontSize: 0,
          currentIndex: _index,
          onTap: (int _index) {
            setState(() {
              this._index = _index;
            });
          },
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              activeIcon: iconNavigationBarItemCustom(IconTabbarMoBiMap.ic_tabbar_tool_selected.name, 'Chức năng', true),
              label: 'Chức năng',
              tooltip: '',
              icon: iconNavigationBarItemCustom(IconTabbarMoBiMap.ic_tabbar_tool_unselected.name, 'Chức năng', false),
            ),
            BottomNavigationBarItem(
              activeIcon: iconNavigationBarItemCustom(IconTabbarMoBiMap.ic_tabbar_search_selected.name, 'Tra cứu', true),
              label: 'Tra cứu',
              tooltip: '',
              icon: iconNavigationBarItemCustom(IconTabbarMoBiMap.ic_tabbar_search_unselected.name, 'Tra cứu', false),
            ),
            BottomNavigationBarItem(
              icon: Container(
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFDA758),
                    shape: BoxShape.circle,
                  ),
                  height: 50,
                  width: 50,
                  child: Center(
                    child: Image.asset(loadImageWithImageName(IconTabbarMoBiMap.ic_tabbar_scanQRCode.name, TypeImage.png)),
                  )),
              label: '',
              tooltip: '',
            ),
            BottomNavigationBarItem(
              activeIcon: iconNavigationBarItemCustom(IconTabbarMoBiMap.ic_tabbar_map_selected.name, 'Bản đồ', true),
              label: 'Bản đồ',
              tooltip: '',
              icon: iconNavigationBarItemCustom(IconTabbarMoBiMap.ic_tabbar_map_unselected.name, 'Bản đồ', false),
            ),
            BottomNavigationBarItem(
              activeIcon: iconNavigationBarItemCustom(IconTabbarMoBiMap.ic_tabbar_user_selected.name, 'Cá nhân', true),
              label: 'Cá nhân',
              tooltip: '',
              icon: iconNavigationBarItemCustom(IconTabbarMoBiMap.ic_tabbar_user_unselected.name, 'Cá nhân', false),
            ),
          ],
        ),
      ),
    );
  }

  Container iconNavigationBarItemCustom(String imageName, String tabbarName, bool active) {
    Color textColor = active ? Color(0xFFFDA758) : Color(0xFF795675);
    return Container(
        padding: EdgeInsets.symmetric(vertical: 0),
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            Container(
              height: 20,
              child: Image.asset(loadImageWithImageName(imageName, TypeImage.png)),
            ),
            SizedBox(
              height: tabbarName.isNotEmpty ? 9 : 0,
            ),
            Text(tabbarName, textAlign: TextAlign.center, style: textStyleManrope(textColor, tabbarName.isNotEmpty ? 12 : 0, FontWeight.normal)),
          ],
        ));
  }
}
