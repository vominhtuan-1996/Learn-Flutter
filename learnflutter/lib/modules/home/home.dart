// tạo 1 màn hình home sử dụng tabbar button , gồm 5 tab , tab ở giữa có UI circle button lớn hơn các tab còn lạiimport 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:learnflutter/core/app/app_box_decoration.dart';
import 'package:learnflutter/core/app/app_colors.dart';
import 'package:learnflutter/extendsion_ui/shape/border/arrow_elastic_shape.dart';
import 'package:learnflutter/extendsion_ui/shape/clipper/wave.dart';
import 'package:learnflutter/modules/test_screen/test_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    // Placeholder for the first tab content
    ClipPath(
      clipper: ShapeBorderClipper(
        shape: ArrowElasticShape(progress: 1),
      ),
      child: Container(
        width: 40,
        height: 40,
        color: Colors.blue,
      ),
    ),
    // Text('Index 0: Home'),
    // Text('Index 0: Home'),
    // Text('Index 1: Search'),
    TestScreen(), // Middle tab with a different UI
    Text('Index 3: Notifications'),
    Text('Index 4: Profile'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    // KeyboardService.instance.listener = (visible, height) {
    //   print("Keyboard: $visible  height = $height");

    //   /// TODO: xử lý logic toàn app tại đây
    //   /// Ví dụ: show/hide 1 global overlay
    //   KeyboardOverlayController.instance.update(visible, height);
    // };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          // shape:
          boxShadow: [AppShadowBox.boxShadowPrimary],
        ),
        child: PhysicalShape(
          clipper: WaveClipper(),
          elevation: 20,
          color: Colors.white,
          shadowColor: AppColors.primaryText,
          child: BottomAppBar(
            elevation: 0,
            color: Colors.transparent,
            // notchMargin: 8, // notchMargin is not a property of BottomAppBar when using a custom shape
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildTabItem(0, Icons.home),
                _buildTabItem(1, Icons.search),
                _buildTabItem(2, Icons.notifications),
                _buildTabItem(3, Icons.person),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, IconData icon) {
    return Expanded(
      child: IconButton(
        icon: Icon(
          icon,
          color: _selectedIndex == index ? Colors.blue : Colors.grey,
        ),
        onPressed: () => _onItemTapped(index),
      ),
    );
  }
}
