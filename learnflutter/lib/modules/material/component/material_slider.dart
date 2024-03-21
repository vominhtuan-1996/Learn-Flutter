import 'package:flutter/material.dart';
import 'package:learnflutter/core/device_dimension.dart';
import 'package:learnflutter/core/extension/extension_context.dart';
import 'package:learnflutter/modules/material/component/component_material_mixi.dart';
import 'package:learnflutter/modules/material/component/meterial_button_3/material_button_3.dart';
import 'package:learnflutter/modules/material/material_screen.dart';
import 'package:learnflutter/modules/material/material_screen_detail.dart';
import 'package:learnflutter/modules/slider_vertical/progess_bar_custom.dart';
import 'package:learnflutter/src/app_colors.dart';

class MaterialSlider extends StatefulWidget {
  const MaterialSlider({super.key, required this.data});
  final RoouterMaterialModel data;
  @override
  State<MaterialSlider> createState() => _MaterialSliderState();
}

class _MaterialSliderState extends State<MaterialSlider> with ComponentMaterialDetail {
  double valueSlider = 50;
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
    return MaterialScreenDetail(
      title: widget.data.title,
      description: widget.data.description,
      contentWidget: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 100),
              child: SizedBox(
                width: 200,
                height: 50,
                child: ProgressBar(
                  barColor: Color(0xFF6750A4),
                  thumbColor: Color(0xFF6750A4),
                  thumbSize: 30.0,
                  strokeWidth: 10,
                  strokeCap: StrokeCap.round,
                  min: 0,
                  max: 1000,
                  showLabel: true,
                  backGroundLabel: Colors.yellow,
                  onChanged: (value) {
                    print(value);
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: DeviceDimension.padding, horizontal: DeviceDimension.padding),
              child: ProgressBar(
                barColor: Color(0xFF6750A4),
                thumbColor: Color(0xFF6750A4),
                thumbSize: 30.0,
                strokeWidth: 10,
                strokeCap: StrokeCap.round,
                min: 0,
                max: 1000,
                showLabel: false,
                backGroundLabel: Colors.yellow,
                onChanged: (value) {
                  print(value);
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(DeviceDimension.padding),
              child: ProgressBar(
                barColor: Color(0xFF6750A4),
                thumbColor: Color(0xFF6750A4),
                thumbSize: 30.0,
                strokeWidth: 10,
                strokeCap: StrokeCap.round,
                min: 0,
                max: 1000,
                showLabel: true,
                backGroundLabel: Colors.blue,
                styleLabel: TextStyle(
                  color: Colors.red,
                  fontSize: 24,
                ),
                onChanged: (value) {
                  print(value);
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                5,
                (index) {
                  return MaterialButton3(
                    disible: false,
                    backgoundColor: Colors.white,
                    borderColor: Colors.grey,
                    borderRadius: DeviceDimension.padding,
                    shadowColor: AppColors.grey,
                    shadowOffset: Offset.zero,
                    textAlign: TextAlign.center,
                    onTap: () async {
                      print('object');
                    },
                    type: MaterialButtonType.commonbutton,
                    lableText: 'Label',
                    labelTextStyle: context.textTheme.bodyMedium?.copyWith(color: context.theme.colorScheme.onPrimary),
                  );
                },
              ),
            ),
            SizedBox(
              height: DeviceDimension.padding,
            ),
            Wrap(
              alignment: WrapAlignment.spaceAround,
              children: List.generate(
                5,
                (index) {
                  return Padding(
                    padding: EdgeInsets.all(DeviceDimension.padding / 2),
                    child: SizedBox(
                      width: 90,
                      child: MaterialButton3(
                        disible: false,
                        backgoundColor: Colors.white,
                        borderColor: Colors.grey,
                        borderRadius: DeviceDimension.padding,
                        shadowColor: AppColors.grey,
                        shadowOffset: Offset.zero,
                        textAlign: TextAlign.left,
                        prefixIcon: Icons.add,
                        prefixColor: context.theme.colorScheme.onPrimary,
                        onTap: () async {
                          print('object');
                        },
                        type: MaterialButtonType.commonbutton,
                        lableText: 'Label',
                        labelTextStyle: context.textTheme.bodyMedium?.copyWith(color: context.theme.colorScheme.onPrimary),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: DeviceDimension.padding / 2),
              child: Text('Text buttons'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                5,
                (index) {
                  return MaterialButton3(
                    disible: false,
                    backgoundColor: Colors.white,
                    borderColor: Colors.white,
                    borderRadius: DeviceDimension.padding,
                    shadowColor: AppColors.grey,
                    shadowOffset: Offset.zero,
                    textAlign: TextAlign.center,
                    onTap: () async {
                      print('object');
                    },
                    type: MaterialButtonType.commonbutton,
                    lableText: 'Label',
                    labelTextStyle: context.textTheme.bodyMedium?.copyWith(color: context.theme.colorScheme.onPrimary),
                  );
                },
              ),
            ),
            SizedBox(
              height: DeviceDimension.padding,
            ),
            Wrap(
              alignment: WrapAlignment.spaceAround,
              children: List.generate(
                5,
                (index) {
                  return Padding(
                    padding: EdgeInsets.all(DeviceDimension.padding / 2),
                    child: SizedBox(
                      width: 90,
                      child: MaterialButton3(
                        disible: false,
                        backgoundColor: Colors.white,
                        borderColor: Colors.white,
                        borderRadius: DeviceDimension.padding,
                        shadowColor: AppColors.grey,
                        textAlign: TextAlign.left,
                        shadowOffset: Offset.zero,
                        prefixIcon: Icons.add,
                        prefixColor: context.theme.colorScheme.onPrimary,
                        onTap: () async {
                          print('object');
                        },
                        type: MaterialButtonType.commonbutton,
                        lableText: 'Label',
                        labelTextStyle: context.textTheme.bodyMedium?.copyWith(color: context.theme.colorScheme.onPrimary),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: DeviceDimension.padding / 2),
              child: Text('Elevated buttons'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                5,
                (index) {
                  return MaterialButton3(
                    disible: false,
                    backgoundColor: context.theme.colorScheme.onPrimary,
                    borderColor: Colors.grey,
                    borderRadius: DeviceDimension.padding,
                    shadowColor: AppColors.grey,
                    shadowOffset: Offset(0.6, 2.3),
                    textAlign: TextAlign.center,
                    onTap: () async {
                      print('object');
                    },
                    type: MaterialButtonType.commonbutton,
                    lableText: 'Label',
                    labelTextStyle: context.textTheme.bodyMedium?.copyWith(color: Colors.white),
                  );
                },
              ),
            ),
            SizedBox(
              height: DeviceDimension.padding,
            ),
            Wrap(
              alignment: WrapAlignment.spaceAround,
              children: List.generate(
                5,
                (index) {
                  return Padding(
                    padding: EdgeInsets.all(DeviceDimension.padding / 2),
                    child: SizedBox(
                      width: 90,
                      child: MaterialButton3(
                        disible: false,
                        backgoundColor: context.theme.colorScheme.onPrimary,
                        borderColor: context.theme.colorScheme.onPrimary,
                        borderRadius: DeviceDimension.padding,
                        shadowColor: AppColors.grey,
                        textAlign: TextAlign.left,
                        prefixIcon: Icons.add,
                        shadowOffset: Offset(1.6, 2.3),
                        prefixColor: Colors.white,
                        onTap: () async {
                          print('object');
                        },
                        type: MaterialButtonType.commonbutton,
                        lableText: 'Label',
                        labelTextStyle: context.textTheme.bodyMedium?.copyWith(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: DeviceDimension.padding / 2),
              child: Text('Tonal buttons'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                5,
                (index) {
                  return MaterialButton3(
                    disible: false,
                    backgoundColor: context.theme.colorScheme.onPrimary,
                    borderColor: Colors.grey,
                    borderRadius: DeviceDimension.padding,
                    shadowColor: AppColors.grey,
                    shadowOffset: Offset(0.6, 2.3),
                    textAlign: TextAlign.center,
                    onTap: () async {
                      print('object');
                    },
                    type: MaterialButtonType.commonbutton,
                    lableText: 'Label',
                    labelTextStyle: context.textTheme.bodyMedium?.copyWith(color: Colors.white),
                  );
                },
              ),
            ),
            SizedBox(
              height: DeviceDimension.padding,
            ),
            Wrap(
              alignment: WrapAlignment.spaceAround,
              children: List.generate(
                5,
                (index) {
                  return Padding(
                    padding: EdgeInsets.all(DeviceDimension.padding / 2),
                    child: SizedBox(
                      width: 90,
                      child: MaterialButton3(
                        disible: false,
                        backgoundColor: context.theme.colorScheme.onPrimary,
                        borderColor: context.theme.colorScheme.onPrimary,
                        borderRadius: DeviceDimension.padding,
                        shadowColor: AppColors.grey,
                        textAlign: TextAlign.left,
                        prefixIcon: Icons.add,
                        shadowOffset: Offset(1.6, 2.3),
                        prefixColor: Colors.white,
                        onTap: () async {
                          print('object');
                        },
                        type: MaterialButtonType.commonbutton,
                        lableText: 'Label',
                        labelTextStyle: context.textTheme.bodyMedium?.copyWith(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
