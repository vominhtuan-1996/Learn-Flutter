import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnflutter/base_loading_screen/base_loading.dart';
import 'package:learnflutter/core/app_text_style.dart';
import 'package:learnflutter/core/extension/extension_context.dart';
import 'package:learnflutter/core/global/var_global.dart';
import 'package:learnflutter/modules/setting/cubit/setting_cubit.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});
  @override
  State<SettingScreen> createState() => SettingScreenState();
}

class SettingScreenState extends State<SettingScreen> {
  bool switchValue = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = BlocProvider.of<SettingThemeCubit>(context);

    return BaseLoading(
        appBar: AppBar(
          title: Text('Setting'),
        ),
        isLoading: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                child: Row(
                  children: [
                    Container(
                      width: context.mediaQuery.size.width / 3,
                      child: Text(
                        '$textScale',
                        style: context.textTheme.bodySmall,
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: Container(
                        child: Row(
                          children: [
                            Text(
                              'A',
                              style: AppTextStyles.themeBodyMedium.copyWith(fontSize: 14),
                            ),
                            Slider(
                              min: 0.824,
                              max: 1.353,
                              value: textScale,
                              onChanged: (value) {
                                themeBloc.changeScaleText(value);
                                textScale = value;
                                print(value);
                                setState(() {});
                              },
                            ),
                            Text(
                              'A',
                              style: AppTextStyles.themeBodyMedium.copyWith(fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text('Mode'),
                  ),
                  Transform.scale(
                    scale: 1,
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
                        themeBloc.changeBrightness(value);
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ));
  }
}
