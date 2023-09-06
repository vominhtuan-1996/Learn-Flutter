// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learnflutter/Helpper/utills_helpper.dart';
import 'package:learnflutter/attributeString/attributeString_widget.dart';
import 'package:learnflutter/shimmer/shimmer_utils/shimmer_utils.dart';
import 'package:learnflutter/shimmer/widget/shimmer_widget.dart';
import 'package:learnflutter/shimmer/widget/shimmer_loading_widget.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  bool switchValue = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Screen'),
      ),
      body: Shimmer(
        linearGradient: ShimmerUtils.shimmerGradient,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                ShimmerLoading(
                  isLoading: true,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/shimmer_widget');
                    },
                    child: const Text('Test Shimmer Widget'),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/hero_animation_screen');
                  },
                  child: const Text('Hero Animation Screen'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/info_screen');
                  },
                  child: const Text('Hive Demo'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/matix_screen');
                  },
                  child: const Text('matix Screen'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/progress_hud_screen');
                  },
                  child: const Text('progressHud Screen'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/popover_scren');
                  },
                  child: const Text('Popover Click'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/nested_scroll_screen');
                  },
                  child: const Text('nested_scroll_screen'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/courasel_screen');
                  },
                  child: const Text('courasel_screen'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/MenuController');
                  },
                  child: const Text('Menu'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/bmprogresshud_screen');
                  },
                  child: const Text('bmprogresshud_screen'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/intertiveview_screen');
                  },
                  child: const Text('InteractiveViewer'),
                ),
                Transform.scale(
                  scale: 1.5,
                  child: CupertinoSwitch(
                    // This bool value toggles the switch.
                    value: switchValue,
                    activeColor: Color(0xFFB6E13D), // CupertinoColors.activeGreen,
                    trackColor: Color(0xFFD9D9D9),
                    thumbColor: Colors.red,
                    onChanged: (bool? value) {
                      // This is called when the user toggles the switch.
                      setState(() {
                        switchValue = value ?? false;
                      });
                    },
                  ),
                ),
                CupertinoButton(
                  onPressed: () => _showActionSheet(context),
                  child: const Text('CupertinoActionSheet'),
                ),
                CupertinoButton(
                  onPressed: () => _showAlertDialog(context),
                  child: const Text('CupertinoAlertDialog'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/datetime_picker_screen');
                  },
                  child: const Text('Date time Picker'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/date_picker');
                  },
                  child: const Text('Date Picker'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/date_time_input');
                  },
                  child: const Text('date_time_input'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/calender');
                  },
                  child: const Text('calender'),
                ),
                ElevatedButton(
                  onPressed: () {
                    pushToController(context: context, useRootNavigator: true, route: '/tie_picker_screen');
                    // Navigator.of(context).pushNamed('/tie_picker_screen');
                  },
                  child: const Text('Tie Picker Screen'),
                ),
                AttriButedSringWidget(
                  typeAttriButed: AttriButedSring.attriButedChar,
                  message: 'Tuan IOS Su12',
                  charHighlight: 'U',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                  highlightStyle: TextStyle(
                    color: Colors.red,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  highlightColor: Colors.red,
                  ignoreCase: true,
                ),
                AttriButedSringWidget(
                  typeAttriButed: AttriButedSring.attriButedText,
                  message: 'Tuan IOS Su12',
                  texthighlight: 'Su',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                  highlightStyle: TextStyle(
                    color: Colors.red,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  highlightColor: Colors.red,
                  ignoreCase: true,
                ),
                AttriButedSringWidget(
                  typeAttriButed: AttriButedSring.attriButedRange,
                  message: 'Tuan IOS Su12',
                  start: 0,
                  end: 12,
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                  highlightStyle: TextStyle(
                    color: Colors.red,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  highlightColor: Colors.red,
                  ignoreCase: true,
                ),
                ShimmerLoading(
                  isLoading: true,
                  child: AttriButedSringWidget(
                    typeAttriButed: AttriButedSring.attriButedCustom,
                    listAttributedCustom: [
                      TextSpan(
                        text: 'Tuan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          fontSize: 20,
                        ),
                      ),
                      TextSpan(
                        text: 'IOS',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontSize: 12,
                        ),
                      ),
                      TextSpan(
                        text: 'Su12',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                          fontSize: 36,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _showActionSheet(BuildContext context) {
  showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) => CupertinoActionSheet(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Title'),
          Icon(Icons.close),
        ],
      ),
      message: Container(
        color: Colors.red,
        height: 120,
      ),
      actions: <CupertinoActionSheetAction>[
        CupertinoActionSheetAction(
          /// This parameter indicates the action would be a default
          /// default behavior, turns the action's text to bold text.
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Default Action'),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Action'),
        ),
        CupertinoActionSheetAction(
          /// This parameter indicates the action would perform
          /// a destructive action such as delete or exit and turns
          /// the action's text color to red.
          isDestructiveAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Destructive Action'),
        ),
      ],
    ),
  );
}

void _showAlertDialog(BuildContext context) {
  showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: const Text('Alert'),
      content: const Text('Proceed with destructive action?'),
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          /// This parameter indicates this action is the default,
          /// and turns the action's text to bold text.
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('No'),
        ),
        CupertinoDialogAction(
          /// This parameter indicates the action would perform
          /// a destructive action such as deletion, and turns
          /// the action's text color to red.
          isDestructiveAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Yes'),
        ),
      ],
    ),
  );
}

class ListItems extends StatelessWidget {
  const ListItems({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          InkWell(
            onTap: () {},
            child: Container(
              height: 50,
              color: Colors.amber[100],
              child: const Center(child: Text('Entry A')),
            ),
          ),
          const Divider(),
          Container(
            height: 50,
            color: Colors.amber[200],
            child: const Center(child: Text('Entry B')),
          ),
          const Divider(),
          Container(
            height: 50,
            color: Colors.amber[300],
            child: const Center(child: Text('Entry C')),
          ),
        ],
      ),
    );
  }
}
