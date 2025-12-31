import 'package:flutter/material.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/core/app/device_dimension.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';
import 'package:learnflutter/utils_helper/extension/extension_textstyle.dart';
import 'package:learnflutter/component/routes/argument_screen_model.dart';
import 'package:learnflutter/component/routes/route.dart';
import 'package:learnflutter/modules/material/component/meterial_button_3/material_button_3.dart';
import 'package:learnflutter/core/app/app_colors.dart';

class RouterMaterialModel {
  RouterMaterialModel(this.title, this.router, this.description);

  final String title;
  final String description;
  final String router;
}

class MaterialScreen extends StatefulWidget {
  const MaterialScreen({super.key});
  @override
  State<MaterialScreen> createState() => MaterialScreenState();
}

class MaterialScreenState extends State<MaterialScreen> with TickerProviderStateMixin {
  DateTime selectedDate = DateTime.now();
  List components = [
    RouterMaterialModel(
      'Badges',
      Routes.materialBadge,
      'Badges are used to convey dynamic information, such as a count or status. A badge can include text, labels, or numbers. ',
    ),
    RouterMaterialModel(
      'Bottom app bars',
      Routes.materialBottomAppbar,
      'Bottom app bars display navigation and key actions at the bottom of a screen.',
    ),
    RouterMaterialModel(
      'Bottom sheets',
      Routes.materialBottomSheet,
      'Bottom sheets are surfaces containing supplementary content, anchored to the bottom of the screen.',
    ),
    RouterMaterialModel(
      'Buttons',
      Routes.materialButton,
      'Buttons help people take actions, such as sending an email, sharing a document, or liking a comment.',
    ),
    RouterMaterialModel(
      'Cards',
      Routes.materialCard,
      'Cards are versatile containers, holding anything from images to headlines, supporting text, buttons, lists, and other components.',
    ),
    RouterMaterialModel(
      'Carousel',
      Routes.materialCarousel,
      'Carousels contains a collection of items that can be scrolled on and off the screen.',
    ),
    RouterMaterialModel(
      'Checkboxes',
      Routes.materialCheckbox,
      'Checkboxes allow users to select one or more items from a set and can be used to turn an option on or off. They’re a kind of selection control that helps users make a choice from a set of options.',
    ),
    RouterMaterialModel(
      'Chips',
      Routes.materialChip,
      'Chips help people enter information, make selections, filter content, or trigger actions.',
    ),
    RouterMaterialModel(
      'Date picker',
      Routes.materialDatePicker,
      'Date pickers let users select a date, or a range of dates.',
    ),
    RouterMaterialModel(
      'Dialogs',
      Routes.materialDialog,
      'Dialogs provide important prompts in a user flow. They can require an action, communicate information for making decisions, or help users accomplish a focused task.',
    ),
    RouterMaterialModel(
      'Dividers',
      Routes.materialDivider,
      'A divider is a thin line used to group content in lists and layouts.',
    ),
    RouterMaterialModel(
      'Floating action buttons (FAB)',
      Routes.materialFloatingButton,
      'FABs help people take primary actions. They’re used to represent the most important action on a screen.',
    ),
    RouterMaterialModel(
      'Icon buttons',
      Routes.materialIConButton,
      'Icon buttons help people take supplementary actions with a single tap.',
    ),
    RouterMaterialModel(
      'Lists',
      Routes.materialLists,
      'Lists are continuous, vertical indexes of text and images.',
    ),
    RouterMaterialModel(
      'Menus',
      Routes.materialMenu,
      'Menus display a list of choices on a temporary surface. They appear when users interact with a button, action, or other control.\n For Android the target minimum is always 48dp minimum.',
    ),
    RouterMaterialModel(
      'Navigation bars',
      Routes.datetimePickerScreen,
      'Navigation bars offer a persistent, convenient way to switch between primary destinations in an app. 3-5 destinations is the recommended range.',
    ),
    RouterMaterialModel(
      'Navigation drawer',
      Routes.materialNavigationDrawer,
      'Navigation drawers provide access to destinations in your app.',
    ),
    RouterMaterialModel(
      'Navigation rail',
      Routes.materialNavigationRail,
      'Navigation rails provide access to primary destinations in your app, particularly in tablet and desktop screens.',
    ),
    RouterMaterialModel(
      'Progress indicators',
      Routes.materialProgressIndicators,
      'Progress indicators inform users about the status of ongoing processes, such as loading an app, submitting a form, or saving updates. They communicate an app’s state and indicate available actions, such as whether users can navigate away from the current screen.',
    ),
    RouterMaterialModel(
      'Radio buttons',
      Routes.materialRadioButton,
      'Radio buttons allow users to select one option from a set. They’re a selection control that often appears when users are asked to make decisions or select a choice from options.',
    ),
    RouterMaterialModel(
      'Search',
      Routes.materialSearchBar,
      'Search allows users to enter a keyword or phrase and get relevant information. It’s an alternative to other forms of navigation.',
    ),
    RouterMaterialModel(
      'Segmented buttons: outlined',
      Routes.datetimePickerScreen,
      'Segmented buttons help people select options, switch views, and sort elements. ',
    ),
    RouterMaterialModel(
      'Side Sheets',
      Routes.materialSideSheetScreen,
      'Side sheets are surfaces containing supplementary content or actions to support tasks as part of a flow. They are typically anchored on the right edge of larger screens like tablets and desktops.',
    ),
    RouterMaterialModel(
      'Sliders',
      Routes.materialSlider,
      'Sliders allow users to make selections from a range of values.',
    ),
    RouterMaterialModel(
      'Snackbars',
      Routes.materialSnackbar,
      'Snackbars provide brief messages about app processes at the bottom of the screen.',
    ),
    RouterMaterialModel(
      'Switch',
      Routes.materialSwitch,
      'Switches toggle the state of a single item on or off.',
    ),
    RouterMaterialModel(
      'Tabs',
      Routes.materialSegmentedScreen,
      'Tabs organize and support navigation between groups of related content at the same level of hierarchy.',
    ),
    RouterMaterialModel(
      'Text fields',
      Routes.materialTextField,
      'Text fields allow users to enter text into a UI. They typically appear in forms and dialogs.',
    ),
    RouterMaterialModel(
      'Time picker',
      Routes.materialTimePicker,
      'Time pickers help users select and set a specific time.',
    ),
    RouterMaterialModel(
      'Tooltips',
      Routes.datetimePickerScreen,
      'Tooltips are informative, specific, and action-oriented text labels that provide contextual support',
    ),
    RouterMaterialModel(
      'Top app bars',
      Routes.datetimePickerScreen,
      'Top app bars display information and actions at the top of a screen, such as the page title and shortcuts to actions.',
    ),
  ];
  bool light = true;
  @override
  void initState() {
    super.initState();
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
      appBar: AppBar(
        title: Text('Components', style: context.textTheme.headlineMedium),
      ),
      child: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              components.length,
              (index) {
                RouterMaterialModel model = components[index];
                return MaterialButton3(
                  backgoundColor: AppColors.white,
                  borderColor: AppColors.white,
                  borderRadius: DeviceDimension.padding,
                  shadowColor: AppColors.grey,
                  shadowOffset: Offset.zero,
                  onTap: () async {
                    Navigator.of(context).pushNamed(model.router,
                        arguments: ArgumentsScreenModel(title: '', data: model));
                  },
                  suffixIcon: Icons.arrow_forward_outlined,
                  suffixColor: AppColors.black,
                  type: MaterialButtonType.commonbutton,
                  lableText: model.title,
                  textAlign: TextAlign.left,
                  labelTextStyle: context.textTheme.bodyLarge?.underlined(
                    color: context.colorScheme.error,
                    distance: 1,
                    thickness: 4,
                    style: TextDecorationStyle.solid,
                  ),
                );
              },
            )
            // [
            //   MaterialTextField(
            //     enabled: true,
            //     readOnly: false,
            //     onChanged: (p0) {},
            //     hintText: 'Nhập từ khoá tìm kiếm',
            //     focusedBorderColor: AppColors.primary,
            //     counterText: 'Keep it short',
            //     helperText: 'Keep it short, this is just a demo.',
            //     decorationBorderColor: Colors.red,
            //     enabledBorderColor: AppColors.primary,
            //     disabledBorderColor: AppColors.black,
            //     prefixIcon: Icons.search,
            //     prefixIconColor: AppColors.primary,
            //     prefixIconConstraints: const BoxConstraints(maxWidth: 40, maxHeight: 30),
            //     onPrefixIconIconPressed: () {
            //       print('onPrefixIconIconPressed');
            //     },
            //     suffixIcon: Icons.close,
            //     suffixIconColor: AppColors.blue,
            //     suffixIconConstraints: const BoxConstraints(maxWidth: 40, maxHeight: 30),
            //     onSuffixIconPressed: () {
            //       print('onSuffixIconPressed');
            //     },
            //   ),
            //   SizedBox(
            //     width: 50,
            //     height: 50,
            //     child: MaterialButton3(
            //       backgoundColor: AppColors.white,
            //       borderColor: AppColors.primary,
            //       borderRadius: DeviceDimension.padding,
            //       shadowColor: AppColors.grey,
            //       onTap: () {
            //         showModalBottomSheet<void>(
            //           context: context,
            //           builder: (BuildContext context) {
            //             return SizedBox(
            //               height: context.mediaQuery.size.height / 2,
            //               child: Stack(
            //                 children: [
            //                   Column(
            //                     children: <Widget>[
            //                       SizedBox(height: DeviceDimension.padding / 2),
            //                       Container(
            //                         height: 3,
            //                         width: context.mediaQuery.size.width / 8,
            //                         decoration: AppBoxDecoration.boxDecorationBorderRadius(
            //                           borderRadiusValue: 8,
            //                           borderWidth: 1,
            //                           colorBackground: Colors.grey,
            //                         ),
            //                       ),
            //                       Expanded(
            //                         child: CupertinoDatePicker(
            //                           minimumYear: DateTime.now().year - 7,
            //                           maximumDate: DateTime.now(),
            //                           initialDateTime: selectedDate,
            //                           mode: CupertinoDatePickerMode.date,
            //                           dateOrder: DatePickerDateOrder.dmy,

            //                           // use24hFormat: true,
            //                           // This shows day of week alongside day of month
            //                           // This is called when the user changes the date.
            //                           onDateTimeChanged: (DateTime newDate) {
            //                             selectedDate = newDate;
            //                           },
            //                         ),
            //                       ),
            //                       SizedBox(
            //                         width: context.mediaQuery.size.width,
            //                         child: MaterialButton3(
            //                           backgoundColor: AppColors.white,
            //                           borderColor: AppColors.white,
            //                           borderRadius: DeviceDimension.padding,
            //                           shadowColor: AppColors.grey,
            //                           onTap: () async {
            //                             setState(() => selectedDate);
            //                             DialogUtils.dismissPopup(context);
            //                           },
            //                           type: MaterialButtonType.commonbutton,
            //                           lableText: 'OK',
            //                           labelTextStyle: context.textTheme.bodyMedium?.copyWith(color: Colors.black),
            //                         ),
            //                       ),
            //                       SizedBox(height: DeviceDimension.padding),
            //                       SizedBox(
            //                         width: context.mediaQuery.size.width,
            //                         child: MaterialButton3(
            //                           backgoundColor: AppColors.white,
            //                           borderColor: AppColors.white,
            //                           borderRadius: DeviceDimension.padding,
            //                           shadowColor: AppColors.grey,
            //                           onTap: () async {
            //                             DialogUtils.dismissPopup(context);
            //                           },
            //                           type: MaterialButtonType.commonbutton,
            //                           lableText: 'Cancle',
            //                           labelTextStyle: context.textTheme.bodyMedium?.copyWith(color: Colors.black),
            //                         ),
            //                       ),
            //                     ],
            //                   ),
            //                   Positioned(
            //                     right: 10,
            //                     top: 10,
            //                     child: GestureDetector(
            //                       onTap: () => Navigator.pop(context),
            //                       child: const Center(
            //                           child: Icon(
            //                         Icons.close,
            //                         color: Colors.black,
            //                         size: 30,
            //                       )),
            //                     ),
            //                   )
            //                 ],
            //               ),
            //             );
            //           },
            //         );
            //       },
            //       type: MaterialButtonType.fab,
            //       fabIcon: Icons.accessibility,
            //       fabIconColor: Colors.blue,
            //     ),
            //   ),
            //   SizedBox(height: DeviceDimension.padding),
            //   SizedBox(
            //     width: 150,
            //     child: MaterialButton3(
            //       backgoundColor: AppColors.green,
            //       borderColor: AppColors.green,
            //       borderRadius: DeviceDimension.padding,
            //       shadowColor: AppColors.grey,
            //       onTap: () async {
            //         DialogUtils.dialogBuilder(
            //           context: context,
            //           type: TypeDialog.custom,
            //           contentWidget: const SizedBox(
            //             height: 200,
            //             child: Card(
            //               clipBehavior: Clip.hardEdge,
            //               color: Colors.red,
            //               child: Center(child: Text('data')),
            //             ),
            //           ),
            //         );
            //       },
            //       type: MaterialButtonType.commonbutton,
            //       lableText: 'show Card',
            //       labelTextStyle: context.textTheme.bodyMedium?.copyWith(color: Colors.white),
            //     ),
            //   ),
            //   SizedBox(height: DeviceDimension.padding),
            //   SizedBox(
            //     width: 150,
            //     child: MaterialButton3(
            //       backgoundColor: AppColors.green,
            //       borderColor: AppColors.green,
            //       borderRadius: DeviceDimension.padding,
            //       shadowColor: AppColors.grey,
            //       onTap: () async {
            //         DialogUtils.showActionSheet(
            //             context: context,
            //             title: 'Hihi',
            //             titleCancleAction: '???',
            //             content: Container(
            //               width: context.mediaQuery.size.width,
            //               height: 100,
            //               color: Colors.red,
            //               child: Material(
            //                 child: MaterialTextField(
            //                   enabled: true,
            //                   readOnly: false,
            //                   onChanged: (p0) {},
            //                   hintText: 'Nhập từ khoá tìm kiếm',
            //                   focusedBorderColor: AppColors.primary,
            //                   counterText: 'Keep it short',
            //                   helperText: 'Keep it short, this is just a demo.',
            //                   decorationBorderColor: Colors.red,
            //                   enabledBorderColor: AppColors.primary,
            //                   disabledBorderColor: AppColors.black,
            //                   prefixIcon: Icons.search,
            //                   prefixIconColor: AppColors.primary,
            //                   prefixIconConstraints: const BoxConstraints(maxWidth: 40, maxHeight: 30),
            //                   onPrefixIconIconPressed: () {
            //                     print('onPrefixIconIconPressed');
            //                   },
            //                   suffixIcon: Icons.close,
            //                   suffixIconColor: AppColors.blue,
            //                   suffixIconConstraints: const BoxConstraints(maxWidth: 40, maxHeight: 30),
            //                   onSuffixIconPressed: () {
            //                     print('onSuffixIconPressed');
            //                   },
            //                 ),
            //               ),
            //               // child: Column(
            //               //   children: [
            //               //     IconAnimationWidget(
            //               //       isRotate: true,
            //               //     ),
            //               //     IconAnimationWidget(
            //               //       isRotate: false,
            //               //     ),
            //               //     RippleAnimationWidget()
            //               //   ],
            //               // ),
            //             ));
            //       },
            //       type: MaterialButtonType.commonbutton,
            //       lableText: 'Bottom Action Sheet ',
            //       labelTextStyle: context.textTheme.bodyMedium?.copyWith(color: Colors.white),
            //     ),
            //   ),
            //   SizedBox(height: DeviceDimension.padding),
            //   SizedBox(
            //     width: 150,
            //     child: MaterialButton3(
            //       backgoundColor: AppColors.green,
            //       borderColor: AppColors.green,
            //       borderRadius: DeviceDimension.padding,
            //       shadowColor: AppColors.grey,
            //       onTap: () async {
            //         _selectDate(context);
            //         // DialogUtils.showDatimePicker(
            //         //   onComplete: (p0) {},
            //         // );
            //       },
            //       type: MaterialButtonType.commonbutton,
            //       lableText: 'showDatimePicker',
            //       labelTextStyle: context.textTheme.bodyMedium?.copyWith(color: Colors.white),
            //     ),
            //   ),
            //   SizedBox(height: DeviceDimension.padding),
            //   SizedBox(width: 150, child: Text(selectedDate.toString())),
            //   SizedBox(height: DeviceDimension.padding),
            //   SizedBox(
            //     width: 120,
            //     child: MaterialButton3(
            //       backgoundColor: AppColors.green,
            //       borderColor: AppColors.green,
            //       borderRadius: DeviceDimension.padding,
            //       shadowColor: Colors.transparent,
            //       shadowOffset: Offset.zero,
            //       onTap: () async {
            //         DialogUtils.dialogBuilder(
            //           context: context,
            //           type: TypeDialog.custom,
            //           contentWidget: Container(
            //             width: double.maxFinite,
            //             height: 200,
            //             padding: const EdgeInsets.all(10),
            //             child: M3Carousel(
            //               visible: 3,
            //               borderRadius: 20,
            //               slideAnimationDuration: 500,
            //               titleFadeAnimationDuration: 300,
            //               childClick: (int index) {
            //                 print("Clicked $index");
            //               },
            //               children: [
            //                 IconAnimationWidget(),
            //                 IconAnimationWidget(
            //                   icon: Icons.notification_add_rounded,
            //                   isRotate: true,
            //                 ),
            //                 RippleAnimationWidget(),
            //                 Container(
            //                   height: 100,
            //                   width: 100,
            //                   color: Colors.pink,
            //                 ),
            //                 Container(
            //                   height: 100,
            //                   width: 100,
            //                   color: Colors.black,
            //                 )
            //               ],
            //             ),
            //           ),
            //         );
            //       },
            //       type: MaterialButtonType.extendedfab,
            //       lableText: 'Show Dialogs',
            //       labelTextStyle: context.textTheme.bodyMedium?.copyWith(color: Colors.white),
            //     ),
            //   ),
            //   SizedBox(height: DeviceDimension.padding),
            //   SizedBox(
            //     height: 60,
            //     child: MaterialButton3(
            //       backgoundColor: Colors.white,
            //       borderColor: AppColors.grey,
            //       borderRadius: DeviceDimension.padding,
            //       shadowColor: Colors.transparent,
            //       shadowOffset: Offset.zero,
            //       onTap: () {},
            //       type: MaterialButtonType.segmentedbutton,
            //       lableText: 'Enable',
            //       prefixIcon: Icons.check_circle,
            //       prefixColor: Colors.black,
            //       labelTextStyle: context.textTheme.bodyMedium?.copyWith(color: Colors.green),
            //     ),
            //   ),
            //   MaterialButton3(
            //     backgoundColor: Colors.white,
            //     borderColor: AppColors.white,
            //     borderRadius: DeviceDimension.padding,
            //     shadowColor: Colors.transparent,
            //     shadowOffset: Offset.zero,
            //     onTap: () {
            //       print('object');
            //     },
            //     type: MaterialButtonType.iconbutton,
            //     fabIcon: Icons.accessibility,
            //     fabIconColor: Colors.blue,
            //   ),
            //   Container(
            //     width: double.maxFinite,
            //     height: 200,
            //     padding: const EdgeInsets.all(10),
            //     child: M3Carousel(
            //       visible: 3,
            //       borderRadius: 20,
            //       slideAnimationDuration: 500,
            //       titleFadeAnimationDuration: 300,
            //       childClick: (int index) {
            //         print("Clicked $index");
            //       },
            //       children: [
            //         IconAnimationWidget(),
            //         IconAnimationWidget(
            //           icon: Icons.notification_add_rounded,
            //           isRotate: true,
            //         ),
            //         RippleAnimationWidget(),
            //         Container(
            //           height: 100,
            //           width: 100,
            //           color: Colors.pink,
            //         ),
            //         Container(
            //           height: 100,
            //           width: 100,
            //           color: Colors.black,
            //         )
            //       ],
            //     ),
            //   ),
            //   Container(
            //     height: 30,
            //     width: 90,
            //     child: Switch(
            //       value: light,
            //       trackOutlineColor: const MaterialStatePropertyAll<Color?>(Colors.transparent),
            //       activeTrackColor: Colors.red,
            //       activeThumbImage: Image.asset(loadImageWithImageName('ic_search_organe', TypeImage.png)).image,
            //       inactiveThumbImage: Image.asset(loadImageWithImageName('ic_tabbar_user_selected', TypeImage.png)).image,
            //       onChanged: (bool value) {},
            //     ),
            //   ),
            //   SizedBox(
            //     height: 30,
            //   ),
            //   MaterialCheckBox(
            //     disible: false,
            //     scale: 1.6,
            //     isChecked: true,
            //     checkedColor: Colors.black,
            //     borderColor: Colors.black,
            //     onChangedCheck: (value) {
            //       print(value);
            //     },
            //     borderRadius: 6,
            //     fillColor: Colors.transparent,
            //   ),
            // ],
            ),
      ),
    );
  }
}
