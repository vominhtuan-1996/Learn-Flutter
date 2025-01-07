import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/core/global/func_global.dart';
import 'package:learnflutter/modules/color_picker/color_picker.dart';

class ColorPickerScreen extends StatefulWidget {
  const ColorPickerScreen({super.key});
  @override
  State<ColorPickerScreen> createState() => ColorPickerScreenState();
}

class ColorPickerScreenState extends State<ColorPickerScreen> {
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
    Color currentColor = getThemeBloc(context).state.themeBackgound ?? const Color(0xffe100ff);
    return BaseLoading(
        isLoading: false,
        child: Container(
          color: currentColor,
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20),
              CircleColorPicker(
                initialColor: currentColor,
                thumbRadius: 10,
                colorListener: (int value) {
                  getThemeBloc(context).changeThemeBackground(Color(value));
                  setState(() {
                    currentColor = Color(value);
                    print(currentColor);
                  });
                },
              ),
              SizedBox(height: 20),
              BarColorPicker(
                  initialColor: currentColor,
                  width: 300,
                  thumbColor: Colors.white,
                  cornerRadius: 10,
                  pickMode: PickMode.Color,
                  colorListener: (int value) {
                    getThemeBloc(context).changeThemeBackground(Color(value));
                    setState(() {
                      currentColor = Color(value);
                    });
                  }),
              SizedBox(height: 20),
              BarColorPicker(
                  initialColor: currentColor,
                  cornerRadius: 10,
                  pickMode: PickMode.Grey,
                  colorListener: (int value) {
                    getThemeBloc(context).changeThemeBackground(Color(value));
                    setState(() {
                      currentColor = Color(value);
                    });
                  }),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  Clipboard.setData(ClipboardData(text: currentColor.value.toRadixString(16))).then(
                    (value) {
                      final snackBar = SnackBar(
                        /// need to set following properties for best effect of awesome_snackbar_content
                        elevation: 0,
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.transparent,
                        content: AwesomeSnackbarContent(
                          title: 'Thông báo!',
                          message: 'Color ${currentColor.value.toRadixString(16)} copied to clipboard',
                          color: Colors.orange,
                          contentType: ContentType.help,
                        ),
                      );

                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(snackBar);
                    },
                  );
                },
                child: Container(
                  width: 150,
                  height: 50,
                  color: currentColor,
                  alignment: Alignment.center,
                  child: Text(currentColor.value.toRadixString(16)),
                ),
              ),
            ],
          ),
        ));
  }
}
