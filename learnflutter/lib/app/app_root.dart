import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnflutter/core/app/device_dimension.dart';
import 'package:learnflutter/custom_widget/keyboard_avoiding.dart';
import 'package:learnflutter/modules/setting/cubit/setting_cubit.dart';
import 'package:learnflutter/modules/setting/state/setting_state.dart';
import 'package:learnflutter/modules/test_screen/test_screen.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';

class AppRoot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingThemeCubit, SettingThemeState>(
      buildWhen: (p, c) => p.themeData != c.themeData, // chỉ rebuild khi theme đổi
      builder: (context, state) {
        DeviceDimension().initValue(context);

        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: KeyboardAvoider(
            child: FlutterSplashScreen.gif(
              duration: const Duration(seconds: 8),
              backgroundColor: Colors.white,
              nextScreen: const TestScreen(),
              gifPath: 'assets/images/laucher_mobimap_rii_2.gif',
              gifWidth: context.mediaQuery.size.width,
              gifHeight: context.mediaQuery.size.height,
            ),
          ),
        );
      },
    );
  }
}
