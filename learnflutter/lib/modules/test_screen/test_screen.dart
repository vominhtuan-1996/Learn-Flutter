// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learnflutter/app/device_dimension.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/component/tap_builder/tap_animated_button_builder.dart';
import 'package:learnflutter/component/tap_builder/tap_delayed_pressed_button_builder.dart';
import 'package:learnflutter/core/global/func_global.dart';
import 'package:learnflutter/l10n/helper.dart';
import 'package:learnflutter/modules/material/component/metarial_radio_button/radio_item_model.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';
import 'package:learnflutter/component/routes/route.dart';
import 'package:learnflutter/component/attribute_string/attribute_string_widget.dart';
import 'package:learnflutter/modules/animation/widget/icon_animation_widget.dart';
import 'package:learnflutter/utils_helper/dialog_utils.dart';
import 'package:learnflutter/modules/material/component/meterial_button_3/material_button_3.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

// import 'package:file';
class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  _launchURL() async {
    final Uri url = Uri.parse('https://iam.fpt.vn/auth/realms/fpt/protocol/openid-connect/auth?client_id=fproject_portal&response_type=code&redirect_uri=https://ip.fpt.vn/keycloak/callback');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  List uploadList = [
    RadioItemModel(id: 'id', title: 'start of 2320 libraries in 2,847ms (compile: 57 ms, reload: 1137 ms, reassemble: 1542 ms)'),
    RadioItemModel(id: 'id', title: '2'),
    RadioItemModel(id: 'id', title: 'of 2320 libraries in 2,847ms (compile: 57 ms, reload: 1137 ms, reassemble: 1542 ms)'),
    RadioItemModel(id: 'id', title: '4'),
    RadioItemModel(id: 'id', title: '5'),
    RadioItemModel(
        id: 'id',
        title:
            'of 2320 libraries in 2,847ms (compile: 57 ms, reload: 1137 ms, reassemble: 1542 ms)of 2320 libraries in 2,847ms (compile: 57 ms, reload: 1137 ms, reassemble: 1542 ms)of 2320 libraries in 2,847ms (compile: 57 ms, reload: 1137 ms, reassemble: 1542 ms)of 2320 libraries in 2,847ms (compile: 57 ms, reload: 1137 ms, reassemble: 1542 ms)of 2320 libraries in 2,847ms (compile: 57 ms, reload: 1137 ms, reassemble: 1542 ms)of 2320 libraries in 2,847ms (compile: 57 ms, reload: 1137 ms, reassemble: 1542 ms)of 2320 libraries in 2,847ms (compile: 57 ms, reload: 1137 ms, reassemble: 1542 ms)of 2320 libraries in 2,847ms (compile: 57 ms, reload: 1137 ms, reassemble: 1542 ms)'),
    RadioItemModel(id: 'id', title: '7'),
    RadioItemModel(id: 'id', title: '8'),
    RadioItemModel(id: 'id', title: 'of 2320 libraries in 2,847ms (compile: 57 ms, reload: 1137 ms, reassemble: 1542 ms)'),
    RadioItemModel(id: 'id', title: '10'),
    RadioItemModel(id: 'id', title: 'end 11 of 2320 libraries in 2,847ms (compile: 57 ms, reload: 1137 ms, reassemble: 1542 ms)'),
  ];

  void splitCodeString() {
    var value =
        'https://ip.fpt.vn/keycloak/callback?session_state=99b4a2fe-3ba2-41d4-97a8-b4c0031b038f&code=66d06447-8e2d-4914-807f-52d26f65c120.99b4a2fe-3ba2-41d4-97a8-b4c0031b038f.ab352c75-07da-4d36-9912-09e722986f3d';
    var newValue = value.split("?");
    var newValues = newValue.last.split("&");
    Map<String, dynamic> map = {};
    for (var item in newValues) {
      var items = item.split("=");
      map[items.first] = items.last;
    }
    print(map['code']);
  }

  bool switchValue = true;
  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      isLoading: false,
      appBar: AppBar(
        title: Text(DemoLocalizations.of(context).title),
      ),
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        onPressed: () async {},
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              AnimatedTapButtonBuilder(
                child: Text('AnimatedTapButtonBuilder'),
                onTap: () {
                  print('object');
                },
              ),
              TapDelayedPressedButton(
                padding: EdgeInsets.all(DeviceDimension.padding / 2),
                minPressedDuration: Duration(milliseconds: 200),
                inactiveColor: Colors.red,
                pressedColor: Colors.blue,
                child: Text('TapDelayedPressedButton'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.troubleShootingScreen);
                },
                child: Text('TroubleShootingScreen'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.draggableExampleScreen);
                },
                child: Text('FloatingDraggableWidget'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.treeScreen);
                },
                child: Text('Tree Node'),
              ),

              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.balanceBar);
                },
                child: Text('balanceBar'),
              ),

              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.segmented);
                },
                child: Text('get point into file svg'),
              ),
              MaterialButton3.icon(
                fabIcon: Icons.close,
                onPressed: () {},
              ),
              MaterialButton3.extended(
                onPressed: () async {
                  DialogUtils.showLoadingAnimation(contextDialog: context, savePath: await downLoadFolder());
                },
                prefixIcon: Icons.abc,
                lableText: 'Test',
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.segmented);
                },
                child: Text('Segmented'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.scanScreen);
                },
                child: Text('Scan'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.pickFile);
                },
                child: Text('Pick File'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.log);
                },
                child: Text('Log'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.menu);
                },
                child: Text('Siler AppBar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.notificationScrollScreen);
                },
                child: Text('NotificationScrollScreen'),
              ),

              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.reducerScreen);
                },
                child: Text('reducer Screen'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.customPaintScreen);
                },
                child: Text('custom Paint Screen'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.graphicsScreen);
                },
                child: Text('graphics Screen'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.materialScreen);
                },
                child: Text('material 3 UI'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.customScrollScreen);
                },
                child: Text('customScrollScreen'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.regexExampleScreen);
                },
                child: Text('regexExampleScreen'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.dragTargetScreen);
                },
                child: Text('dragTargetScreen'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.chart);
                },
                child: Text('chart Screen'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.refreshControl);
                },
                child: Text('refreshControl Screen'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.colorPicker);
                },
                child: Text('colorPicker Screen'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.arkit);
                },
                child: Text('AR Kit Screen'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.setting);
                },
                child: Text('Test setting'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.animationScreen);
                },
                child: Text('Test Animation'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.materialSegmentedScreen);
                },
                child: Text('Test Material Segmented'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.silderVerticalScreen);
                },
                child: Text('Test Slider Vertical'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.numberFormatScreen);
                },
                child: Text('Test NumberForamtter'),
              ),
              ElevatedButton(
                onPressed: splitCodeString,
                child: Text('Split String'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/page_theme_screen');
                },
                child: Text(
                  'Test Theme',
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/web_browser_screen');
                },
                child: Text('Test Web Browser'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/draggel_scroll_screen');
                },
                child: Text('Test draggel_scroll_screen'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/path_provider_screen');
                },
                child: Text('path_provider_screen'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.openFileScreen);
                },
                child: Text('Tap to open file'),
              ),
              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.of(context).push(MaterialPageRoute(
              //       builder: (context) => const QRViewExample(),
              //     ));
              //   },
              //   child: const Text('qrView'),
              // ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/camera_screen');
                },
                child: const Text('Test Camera'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.pageLoadingScreen);
                },
                child: const Text('Page Loading Screen'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.snackBarScreen);
                },
                child: const Text('AweseomSnackBarExample'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.shimmerWidget);
                },
                child: const Text('Test Shimmer Widget'),
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
                  Navigator.of(context).pushNamed(Routes.nesredScroll);
                },
                child: const Text('nested_scroll_screen'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.courasel);
                },
                child: const Text('courasel_screen'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.menuControler);
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
                  Navigator.of(context).pushNamed(Routes.intertiveviewScreen);
                },
                child: const Text('InteractiveViewer'),
              ),
              Transform.scale(
                scale: 1.5,
                child: CupertinoSwitch(
                  // This bool value toggles the switch.
                  value: switchValue,
                  activeTrackColor: Color(0xFFB6E13D), // CupertinoColors.activeGreen,
                  inactiveTrackColor: Color(0xFFD9D9D9),
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
                onPressed: () => _showActionSheet(
                    context: context,
                    title: 'Hihi',
                    titleCancleAction: '???',
                    content: IconAnimationWidget(
                      isRotate: true,
                    )),
                child: const Text('CupertinoActionSheet'),
              ),
              CupertinoButton(
                onPressed: () => _showAlertDialog(context),
                child: const Text('CupertinoAlertDialog'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.datetimePickerScreen);
                },
                child: const Text('Date time Picker'),
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
              AttributedStringWidget.charecter(
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
              AttributedStringWidget.text(
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
              AttributedStringWidget.range(
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
            ],
          ),
        ),
      ),
    );
  }
}

void _showActionSheet({
  required BuildContext context,
  String title = 'Thông báo',
  Widget content = const Text('Nothing'),
  String titleCancleAction = 'Cancle',
}) {
  showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) => CupertinoActionSheet(
      title: Text(title),
      message: content,
      cancelButton: CupertinoActionSheetAction(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(
          titleCancleAction,
          style: context.textTheme.titleMedium?.copyWith(color: Colors.blue),
        ),
      ),
      // actions: <CupertinoActionSheetAction>[
      //   CupertinoActionSheetAction(
      //     /// This parameter indicates the action would be a default
      //     /// default behavior, turns the action's text to bold text.
      //     isDefaultAction: true,
      //     onPressed: () {
      //       Navigator.pop(context);
      //     },
      //     child: const Text('Default Action'),
      //   ),
      //   CupertinoActionSheetAction(
      //     onPressed: () {
      //       Navigator.pop(context);
      //     },
      //     child: const Text('Action'),
      //   ),
      //   CupertinoActionSheetAction(
      //     /// This parameter indicates the action would perform
      //     /// a destructive action such as delete or exit and turns
      //     /// the action's text color to red.
      //     isDestructiveAction: true,
      //     onPressed: () {
      //       Navigator.pop(context);
      //     },
      //     child: const Text('Destructive Action'),
      //   ),
      // ],
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
  const ListItems({super.key});

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
