import 'package:flutter/material.dart';
import 'package:learnflutter/core/app/device_dimension.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';
import 'package:learnflutter/modules/material/component/component_material_mixi.dart';
import 'package:learnflutter/modules/material/component/meterial_button_3/material_button_3.dart';
import 'package:learnflutter/modules/material/material_screen.dart';
import 'package:learnflutter/modules/material/material_screen_detail.dart';
import 'package:learnflutter/core/app/app_colors.dart';

class MaterialToolTip extends StatefulWidget {
  const MaterialToolTip({super.key, required this.data});
  final RouterMaterialModel data;
  @override
  State<MaterialToolTip> createState() => _MaterialToolTipState();
}

class _MaterialToolTipState extends State<MaterialToolTip> with ComponentMaterialDetail {
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
              padding: EdgeInsets.symmetric(vertical: DeviceDimension.padding / 2),
              child: const Text('Filled buttons'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                5,
                (index) {
                  return MaterialButton3(
                    disible: true,
                    backgoundColor: context.theme.colorScheme.onPrimary,
                    borderColor: context.theme.colorScheme.onPrimary,
                    borderRadius: DeviceDimension.padding,
                    shadowColor: AppColors.grey,
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
                        disible: true,
                        backgoundColor: context.theme.colorScheme.onPrimary,
                        borderColor: context.theme.colorScheme.onPrimary,
                        borderRadius: DeviceDimension.padding,
                        shadowColor: AppColors.grey,
                        textAlign: TextAlign.left,
                        prefixIcon: Icons.add,
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
              child: const Text('Outlined buttons'),
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
                    labelTextStyle: context.textTheme.bodyMedium
                        ?.copyWith(color: context.theme.colorScheme.onPrimary),
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
                        labelTextStyle: context.textTheme.bodyMedium
                            ?.copyWith(color: context.theme.colorScheme.onPrimary),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: DeviceDimension.padding / 2),
              child: const Text('Text buttons'),
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
                    labelTextStyle: context.textTheme.bodyMedium
                        ?.copyWith(color: context.theme.colorScheme.onPrimary),
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
                        labelTextStyle: context.textTheme.bodyMedium
                            ?.copyWith(color: context.theme.colorScheme.onPrimary),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: DeviceDimension.padding / 2),
              child: const Text('Elevated buttons'),
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
                    shadowOffset: const Offset(0.6, 2.3),
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
                        shadowOffset: const Offset(1.6, 2.3),
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
              child: const Text('Tonal buttons'),
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
                    shadowOffset: const Offset(0.6, 2.3),
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
                        shadowOffset: const Offset(1.6, 2.3),
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
