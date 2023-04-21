// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, sized_box_for_whitespace, avoid_print, unused_local_variable, prefer_const_literals_to_create_immutables, library_private_types_in_public_api, unused_import, non_constant_identifier_names, use_full_hex_values_for_flutter_colors, override_on_non_overriding_member, unused_element

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learnflutter/Helpper/defineConstraint.dart';
import 'package:learnflutter/Helpper/flutter_section_table_view.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:learnflutter/Https/MBMHttpHelper.dart';
import 'Menu/MenuController.dart';

void main() {
  AppConfig.init(() {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  MyApp setState() => MyApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MenuController());
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({super.key});

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  final Future<String> _calculation = Future<String>.delayed(
    const Duration(seconds: 2),
    () => 'Data Loaded',
  );

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.displayMedium!,
      textAlign: TextAlign.center,
      child: FutureBuilder<String>(
        future: _calculation, // a previously-obtained Future<String> or null
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            children = <Widget>[
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Result: ${snapshot.data}'),
              ),
            ];
          } else if (snapshot.hasError) {
            children = <Widget>[
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Error: ${snapshot.error}'),
              ),
            ];
          } else {
            children = const <Widget>[
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Awaiting result...'),
              ),
            ];
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: children,
            ),
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class MinList extends StatelessWidget {
  final controller = SectionTableController(
      sectionTableViewScrollTo: (section, row, isScrollDown) {
    print('received scroll to $section $row scrollDown:$isScrollDown');
  });
  final refreshController = RefreshController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Min List'),
        ),
        body: SafeArea(
          child: SectionTableView(
            sectionCount: 9,
            numOfRowInSection: (section) {
              return section == 0 ? 3 : 4;
            },
            cellAtIndexPath: (section, row) {
              return Container(
                height: 44.0,
                child: Center(
                  child: Text('Cell $section $row'),
                ),
              );
            },
            headerInSection: (section) {
              return Container(
                height: 25.0,
                color: Colors.grey,
                child: Text('Header $section'),
              );
            },
            divider: Container(
              color: Colors.green,
              height: 1.0,
            ),
            cellHeightAtIndexPath: (int section, int row) {
              return 44;
            },
            controller: controller,
            dividerHeight: () {
              return 1;
            },
            onRefresh: (bool up) {},
            refreshController: refreshController,
            sectionHeaderHeight: (int section) {
              return 44;
            },
          ),
        ));
  }
}

class SectionList extends StatelessWidget {
  final controller = SectionTableController(
      sectionTableViewScrollTo: (section, row, isScrollDown) {
    print('received scroll to $section $row scrollDown:$isScrollDown');
  });
  final refreshController = RefreshController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Section List'),
      ),
      floatingActionButton: FloatingActionButton(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[Text('Scroll'), Icon(Icons.keyboard_arrow_down)],
          ),
          onPressed: () {
            controller.animateTo(2, -1).then((complete) {
              print('animated $complete');
            });
          }),
      body: SafeArea(
        child: SectionTableView(
          sectionCount: 9,
          numOfRowInSection: (section) {
            return section == 0 ? 3 : 4;
          },
          cellAtIndexPath: (section, row) {
            return Container(
              height: 44.0,
              child: Center(
                child: Text('Cell $section $row'),
              ),
            );
          },
          headerInSection: (section) {
            return Container(
              height: 44.0,
              color: Colors.grey,
              alignment: Alignment.center,
              child: Text('Header $section'),
            );
          },
          divider: Container(
            color: Colors.black12,
            height: 1.0,
          ),
          controller: controller, //SectionTableController
          sectionHeaderHeight: (section) => 25.0,
          dividerHeight: () => 1.0,
          cellHeightAtIndexPath: (section, row) => 44.0,
          onRefresh: (bool up) {}, refreshController: refreshController,
        ),
      ),
    );
  }
}

class FullList extends StatefulWidget {
  @override
  _FullListState createState() => _FullListState();
}

class _FullListState extends State<FullList> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  int sectionCount = 9;
  final controller = SectionTableController(
      sectionTableViewScrollTo: (section, row, isScrollDown) {
    print('received scroll to $section $row scrollDown:$isScrollDown');
  });
  final refreshController = RefreshController();

  Indicator refreshHeaderBuilder(BuildContext context, int mode) {
    return ClassicIndicator(
      mode: mode,
      releaseText: '释放以刷新',
      refreshingText: '刷新中...',
      completeText: '完成',
      failedText: '失败',
      idleText: '下拉以刷新',
      noDataText: '',
      key: Null,
    );
  }

  Indicator refreshFooterBuilder(BuildContext context, int mode) {
    return ClassicIndicator(
      mode: mode,
      releaseText: '释放以加载',
      refreshingText: '加载中...',
      completeText: '加载完成',
      failedText: '加载失败',
      idleText: '上拉以加载',
      noDataText: '',
      idleIcon: const Icon(Icons.arrow_upward, color: Colors.grey),
      releaseIcon: const Icon(Icons.arrow_downward, color: Colors.grey),
      key: Null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Full List'),
      ),
      floatingActionButton: FloatingActionButton(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[Text('Scroll'), Icon(Icons.keyboard_arrow_down)],
          ),
          onPressed: () {
            controller.animateTo(2, -1).then((complete) {
              print('animated $complete');
            });
          }),
      body: SafeArea(
        child: SectionTableView(
          refreshHeaderBuilder: refreshHeaderBuilder,
          refreshFooterBuilder: refreshFooterBuilder,
          enablePullDown: true,
          enablePullUp: true,
          onRefresh: (up) {
            print('on refresh $up');

            Future.delayed(const Duration(milliseconds: 2009)).then((val) {
              refreshController.sendBack(up, RefreshStatus.completed);
              setState(() {
                if (up) {
                  sectionCount = 5;
                } else {
                  sectionCount++;
                }
              });
            });
          },
          refreshController: refreshController,
          sectionCount: sectionCount,
          numOfRowInSection: (section) {
            return section == 0 ? 3 : 4;
          },
          cellAtIndexPath: (section, row) {
            return Container(
              height: 44.0,
              child: Center(
                child: Text('Cell $section $row'),
              ),
            );
          },
          headerInSection: (section) {
            return Container(
              height: 25.0,
              color: Colors.grey,
              child: Text('Header $section'),
            );
          },
          divider: Container(
            color: Colors.green,
            height: 1.0,
          ),
          controller: controller, //SectionTableController
          sectionHeaderHeight: (section) => 25.0,
          dividerHeight: () => 1.0,
          cellHeightAtIndexPath: (section, row) => 44.0,
        ),
      ),
    );
  }
}
