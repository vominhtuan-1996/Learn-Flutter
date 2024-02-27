import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learnflutter/base_loading_screen/base_loading.dart';
import 'package:learnflutter/core/device_dimension.dart';
import 'package:learnflutter/core/extension/extension_context.dart';
import 'package:learnflutter/helpper/datetime_format/datetime_format.dart';
import 'package:learnflutter/helpper/images/images_helper.dart';
import 'package:learnflutter/modules/animation/widget/icon_animation_widget.dart';
import 'package:learnflutter/modules/animation/widget/ripple_animation_widget.dart';
import 'package:learnflutter/modules/material/component/material_carousel.dart';
import 'package:learnflutter/modules/material/component/meterial_button_3/material_button_3.dart';
import 'package:learnflutter/modules/material/component/material_textfield.dart';
import 'package:learnflutter/src/app_box_decoration.dart';
import 'package:learnflutter/src/app_colors.dart';
import 'package:learnflutter/utils_helper/dialog_utils.dart';

class MaterialScreen extends StatefulWidget {
  const MaterialScreen({super.key});
  @override
  State<MaterialScreen> createState() => MaterialScreenState();
}

class MaterialScreenState extends State<MaterialScreen> {
  DateTime selectedDate = DateTime.now();

  bool light = true;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      isLoading: false,
      child: SingleChildScrollView(
        child: Column(
          children: [
            MaterialTextField(
              enabled: true,
              readOnly: false,
              onChanged: (p0) {},
              hintText: 'Nhập từ khoá tìm kiếm',
              focusedBorderColor: AppColors.primary,
              counterText: 'Keep it short',
              helperText: 'Keep it short, this is just a demo.',
              decorationBorderColor: Colors.red,
              enabledBorderColor: AppColors.primary,
              disabledBorderColor: AppColors.black,
              prefixIcon: Icons.search,
              prefixIconColor: AppColors.primary,
              prefixIconConstraints: const BoxConstraints(maxWidth: 40, maxHeight: 30),
              onPrefixIconIconPressed: () {
                print('onPrefixIconIconPressed');
              },
              suffixIcon: Icons.close,
              suffixIconColor: AppColors.blue,
              suffixIconConstraints: const BoxConstraints(maxWidth: 40, maxHeight: 30),
              onSuffixIconPressed: () {
                print('onSuffixIconPressed');
              },
            ),
            SizedBox(
              width: 50,
              height: 50,
              child: MaterialButton3(
                backgoundColor: AppColors.white,
                borderColor: AppColors.primary,
                borderRadius: DeviceDimension.padding,
                shadowColor: AppColors.grey,
                onTap: () {
                  showModalBottomSheet<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return SizedBox(
                        height: context.mediaQuery.size.height / 2,
                        child: Stack(
                          children: [
                            Column(
                              children: <Widget>[
                                SizedBox(height: DeviceDimension.padding / 2),
                                Container(
                                  height: 3,
                                  width: context.mediaQuery.size.width / 8,
                                  decoration: AppBoxDecoration.boxDecorationBorderRadius(
                                    borderRadiusValue: 8,
                                    borderWidth: 1,
                                    colorBackground: Colors.grey,
                                  ),
                                ),
                                Expanded(
                                  child: CupertinoDatePicker(
                                    minimumYear: DateTime.now().year - 7,
                                    maximumDate: DateTime.now(),
                                    initialDateTime: selectedDate,
                                    mode: CupertinoDatePickerMode.date,
                                    dateOrder: DatePickerDateOrder.dmy,

                                    // use24hFormat: true,
                                    // This shows day of week alongside day of month
                                    // This is called when the user changes the date.
                                    onDateTimeChanged: (DateTime newDate) {
                                      selectedDate = newDate;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: context.mediaQuery.size.width,
                                  child: MaterialButton3(
                                    backgoundColor: AppColors.white,
                                    borderColor: AppColors.white,
                                    borderRadius: DeviceDimension.padding,
                                    shadowColor: AppColors.grey,
                                    onTap: () async {
                                      setState(() => selectedDate);
                                      DialogUtils.dismissPopup(context);
                                    },
                                    type: MaterialButtonType.commonbutton,
                                    lableText: 'OK',
                                    labelTextStyle: context.textTheme.bodyMedium?.copyWith(color: Colors.black),
                                  ),
                                ),
                                SizedBox(height: DeviceDimension.padding),
                                SizedBox(
                                  width: context.mediaQuery.size.width,
                                  child: MaterialButton3(
                                    backgoundColor: AppColors.white,
                                    borderColor: AppColors.white,
                                    borderRadius: DeviceDimension.padding,
                                    shadowColor: AppColors.grey,
                                    onTap: () async {
                                      DialogUtils.dismissPopup(context);
                                    },
                                    type: MaterialButtonType.commonbutton,
                                    lableText: 'Cancle',
                                    labelTextStyle: context.textTheme.bodyMedium?.copyWith(color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              right: 10,
                              top: 10,
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: const Center(
                                    child: Icon(
                                  Icons.close,
                                  color: Colors.black,
                                  size: 30,
                                )),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
                type: MaterialButtonType.fab,
                fabIcon: Icons.accessibility,
                fabIconColor: Colors.blue,
              ),
            ),
            SizedBox(height: DeviceDimension.padding),
            SizedBox(
              width: 150,
              child: MaterialButton3(
                backgoundColor: AppColors.green,
                borderColor: AppColors.green,
                borderRadius: DeviceDimension.padding,
                shadowColor: AppColors.grey,
                onTap: () async {
                  DialogUtils.dialogBuilder(
                    context: context,
                    type: TypeDialog.custom,
                    contentWidget: const SizedBox(
                      height: 200,
                      child: Card(
                        clipBehavior: Clip.hardEdge,
                        color: Colors.red,
                        child: Center(child: Text('data')),
                      ),
                    ),
                  );
                },
                type: MaterialButtonType.commonbutton,
                lableText: 'show Card',
                labelTextStyle: context.textTheme.bodyMedium?.copyWith(color: Colors.white),
              ),
            ),
            SizedBox(height: DeviceDimension.padding),
            SizedBox(
              width: 150,
              child: MaterialButton3(
                backgoundColor: AppColors.green,
                borderColor: AppColors.green,
                borderRadius: DeviceDimension.padding,
                shadowColor: AppColors.grey,
                onTap: () async {
                  DialogUtils.showActionSheet(
                      context: context,
                      title: 'Hihi',
                      titleCancleAction: '???',
                      content: Container(
                        width: context.mediaQuery.size.width,
                        height: 100,
                        color: Colors.red,
                        child: Material(
                          child: MaterialTextField(
                            enabled: true,
                            readOnly: false,
                            onChanged: (p0) {},
                            hintText: 'Nhập từ khoá tìm kiếm',
                            focusedBorderColor: AppColors.primary,
                            counterText: 'Keep it short',
                            helperText: 'Keep it short, this is just a demo.',
                            decorationBorderColor: Colors.red,
                            enabledBorderColor: AppColors.primary,
                            disabledBorderColor: AppColors.black,
                            prefixIcon: Icons.search,
                            prefixIconColor: AppColors.primary,
                            prefixIconConstraints: const BoxConstraints(maxWidth: 40, maxHeight: 30),
                            onPrefixIconIconPressed: () {
                              print('onPrefixIconIconPressed');
                            },
                            suffixIcon: Icons.close,
                            suffixIconColor: AppColors.blue,
                            suffixIconConstraints: const BoxConstraints(maxWidth: 40, maxHeight: 30),
                            onSuffixIconPressed: () {
                              print('onSuffixIconPressed');
                            },
                          ),
                        ),
                        // child: Column(
                        //   children: [
                        //     IconAnimationWidget(
                        //       isRotate: true,
                        //     ),
                        //     IconAnimationWidget(
                        //       isRotate: false,
                        //     ),
                        //     RippleAnimationWidget()
                        //   ],
                        // ),
                      ));
                },
                type: MaterialButtonType.commonbutton,
                lableText: 'Bottom Action Sheet ',
                labelTextStyle: context.textTheme.bodyMedium?.copyWith(color: Colors.white),
              ),
            ),
            SizedBox(height: DeviceDimension.padding),
            SizedBox(
              width: 150,
              child: MaterialButton3(
                backgoundColor: AppColors.green,
                borderColor: AppColors.green,
                borderRadius: DeviceDimension.padding,
                shadowColor: AppColors.grey,
                onTap: () async {
                  _selectDate(context);
                  // DialogUtils.showDatimePicker(
                  //   onComplete: (p0) {},
                  // );
                },
                type: MaterialButtonType.commonbutton,
                lableText: 'showDatimePicker',
                labelTextStyle: context.textTheme.bodyMedium?.copyWith(color: Colors.white),
              ),
            ),
            SizedBox(height: DeviceDimension.padding),
            SizedBox(width: 150, child: Text(selectedDate.toString())),
            SizedBox(height: DeviceDimension.padding),
            SizedBox(
              width: 120,
              child: MaterialButton3(
                backgoundColor: AppColors.green,
                borderColor: AppColors.green,
                borderRadius: DeviceDimension.padding,
                shadowColor: Colors.transparent,
                shadowOffset: Offset.zero,
                onTap: () async {
                  DialogUtils.dialogBuilder(
                    context: context,
                    type: TypeDialog.custom,
                    contentWidget: Container(
                      width: double.maxFinite,
                      height: 200,
                      padding: const EdgeInsets.all(10),
                      child: M3Carousel(
                        visible: 3,
                        borderRadius: 20,
                        slideAnimationDuration: 500,
                        titleFadeAnimationDuration: 300,
                        childClick: (int index) {
                          print("Clicked $index");
                        },
                        children: [
                          IconAnimationWidget(),
                          IconAnimationWidget(
                            icon: Icons.notification_add_rounded,
                            isRotate: true,
                          ),
                          RippleAnimationWidget(),
                          Container(
                            height: 100,
                            width: 100,
                            color: Colors.pink,
                          ),
                          Container(
                            height: 100,
                            width: 100,
                            color: Colors.black,
                          )
                        ],
                      ),
                    ),
                  );
                },
                type: MaterialButtonType.extendedfab,
                lableText: 'Show Dialogs',
                labelTextStyle: context.textTheme.bodyMedium?.copyWith(color: Colors.white),
              ),
            ),
            SizedBox(height: DeviceDimension.padding),
            SizedBox(
              height: 60,
              child: MaterialButton3(
                backgoundColor: Colors.white,
                borderColor: AppColors.grey,
                borderRadius: DeviceDimension.padding,
                shadowColor: Colors.transparent,
                shadowOffset: Offset.zero,
                onTap: () {},
                type: MaterialButtonType.segmentedbutton,
                lableText: 'Enable',
                prefixIcon: Icons.check_circle,
                prefixColor: Colors.black,
                labelTextStyle: context.textTheme.bodyMedium?.copyWith(color: Colors.green),
              ),
            ),
            MaterialButton3(
              backgoundColor: Colors.white,
              borderColor: AppColors.white,
              borderRadius: DeviceDimension.padding,
              shadowColor: Colors.transparent,
              shadowOffset: Offset.zero,
              onTap: () {
                print('object');
              },
              type: MaterialButtonType.iconbutton,
              fabIcon: Icons.accessibility,
              fabIconColor: Colors.blue,
            ),
            Container(
              width: double.maxFinite,
              height: 200,
              padding: const EdgeInsets.all(10),
              child: M3Carousel(
                visible: 3,
                borderRadius: 20,
                slideAnimationDuration: 500,
                titleFadeAnimationDuration: 300,
                childClick: (int index) {
                  print("Clicked $index");
                },
                children: [
                  IconAnimationWidget(),
                  IconAnimationWidget(
                    icon: Icons.notification_add_rounded,
                    isRotate: true,
                  ),
                  RippleAnimationWidget(),
                  Container(
                    height: 100,
                    width: 100,
                    color: Colors.pink,
                  ),
                  Container(
                    height: 100,
                    width: 100,
                    color: Colors.black,
                  )
                ],
              ),
            ),
            Container(
              height: 30,
              width: 90,
              child: Switch(
                value: light,
                trackOutlineColor: const MaterialStatePropertyAll<Color?>(Colors.transparent),
                activeTrackColor: Colors.red,
                activeThumbImage: Image.asset(AssetNameImageSvg.ic_folder).image,
                onChanged: (bool value) {
                  setState(() {
                    light = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
