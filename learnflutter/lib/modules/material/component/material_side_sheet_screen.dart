import 'package:flutter/material.dart';
import 'package:learnflutter/core/app/device_dimension.dart';
import 'package:learnflutter/modules/scroll_physic/extension/scroll_physics/nobounce_scroll_physics.dart';
import 'package:learnflutter/modules/animation/widget/scale_translate.dart';
import 'package:learnflutter/modules/material/component/material_side_sheet/material_side_sheet.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';
import 'package:learnflutter/modules/animation/widget/icon_animation_widget.dart';
import 'package:learnflutter/modules/material/component/component_material_mixi.dart';
import 'package:learnflutter/modules/material/component/meterial_button_3/material_button_3.dart';
import 'package:learnflutter/modules/material/material_screen.dart';
import 'package:learnflutter/modules/material/material_screen_detail.dart';
import 'package:learnflutter/core/app/app_colors.dart';
import 'package:learnflutter/utils_helper/dialog_utils.dart';

class MaterialSideSheetScreen extends StatefulWidget {
  const MaterialSideSheetScreen({super.key, required this.data});
  final RouterMaterialModel data;
  @override
  State<MaterialSideSheetScreen> createState() => _MaterialSideSheetScreenScreenState();
}

class _MaterialSideSheetScreenScreenState extends State<MaterialSideSheetScreen> with ComponentMaterialDetail {
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
      contentWidget: Column(
        children: [
          SizedBox(
            child: MaterialButton3(
              backgoundColor: AppColors.green,
              borderColor: AppColors.green,
              borderRadius: DeviceDimension.padding,
              shadowColor: AppColors.grey,
              textAlign: TextAlign.center,
              onTap: () async {
                showModalSideSheet(
                  // Required
                  context,
                  // Pass your content widget (required)
                  body: Container(
                    width: context.mediaQuery.size.width / 2,
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  direction: DirectionSideSheet.right,
                  alignment: Alignment.bottomRight,
                  // Required
                  header: 'Edit user',
                  barrierDismissible: true,
                  addBackIconButton: false,
                  addCloseIconButton: true,
                  addActions: true,
                  addDivider: true,
                  confirmActionTitle: 'Update',
                  cancelActionTitle: 'Cancel',
                  confirmActionOnPressed: () {
                    Navigator.pop(context);
                    debugPrint('on confirm action');
                  },
                  cancelActionOnPressed: () {
                    Navigator.pop(context);
                    debugPrint('on cancel event');
                  },
                  transitionDuration: const Duration(milliseconds: 500),
                  closeButtonTooltip: 'Close',
                  backButtonTooltip: 'Back',
                  onDismiss: () {
                    debugPrint('on dismiss event');
                  },
                  onClose: () {
                    Navigator.pop(context);
                    debugPrint('on close event');
                  },
                  footerBuilder: (context) {
                    return Container();
                  },
                );
              },
              type: MaterialButtonType.commonbutton,
              lableText: 'Right Side Sheet',
              labelTextStyle: context.textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
          ),
          SizedBox(
            child: MaterialButton3(
              backgoundColor: AppColors.green,
              borderColor: AppColors.green,
              borderRadius: DeviceDimension.padding,
              shadowColor: AppColors.grey,
              textAlign: TextAlign.center,
              onTap: () async {
                showModalSideSheet(
                  // Required
                  context,
                  // Pass your content widget (required)
                  body: Container(
                    width: context.mediaQuery.size.width / 2,
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  direction: DirectionSideSheet.left,
                  alignment: Alignment.bottomLeft,
                  // Required
                  header: 'Edit user',
                  barrierDismissible: false,
                  addBackIconButton: false,
                  addCloseIconButton: true,
                  addActions: true,
                  addDivider: true,
                  confirmActionTitle: 'Update',
                  cancelActionTitle: 'Cancel',
                  confirmActionOnPressed: () {
                    Navigator.pop(context);
                    debugPrint('on confirm action');
                  },
                  cancelActionOnPressed: () {
                    Navigator.pop(context);
                    debugPrint('on cancel event');
                  },
                  transitionDuration: const Duration(milliseconds: 500),
                  closeButtonTooltip: 'Close',
                  backButtonTooltip: 'Back',
                  onDismiss: () {
                    debugPrint('on dismiss event');
                  },
                  onClose: () {
                    Navigator.pop(context);
                    debugPrint('on close event');
                  },
                  headerBuilder: (context) {
                    return Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [],
                      ),
                    );
                  },
                );
              },
              type: MaterialButtonType.commonbutton,
              lableText: 'Left Side Sheet',
              labelTextStyle: context.textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
          ),
          SizedBox(
            child: MaterialButton3(
              backgoundColor: AppColors.green,
              borderColor: AppColors.green,
              borderRadius: DeviceDimension.padding,
              shadowColor: AppColors.grey,
              textAlign: TextAlign.center,
              onTap: () async {
                showModalSideSheet(
                  // Required
                  context,
                  // Pass your content widget (required)
                  body: Container(
                    width: context.mediaQuery.size.width / 2,
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  direction: DirectionSideSheet.left,
                  alignment: Alignment.topLeft,
                  // Required
                  header: 'Edit user',
                  barrierDismissible: false,
                  addBackIconButton: false,
                  addCloseIconButton: true,
                  addActions: true,
                  addDivider: true,
                  confirmActionTitle: 'Update',
                  cancelActionTitle: 'Cancel',
                  confirmActionOnPressed: () {
                    Navigator.pop(context);
                    debugPrint('on confirm action');
                  },
                  cancelActionOnPressed: () {
                    Navigator.pop(context);
                    debugPrint('on cancel event');
                  },
                  transitionDuration: const Duration(milliseconds: 500),
                  closeButtonTooltip: 'Close',
                  backButtonTooltip: 'Back',
                  onDismiss: () {
                    debugPrint('on dismiss event');
                  },
                  onClose: () {
                    Navigator.pop(context);
                    debugPrint('on close event');
                  },
                  headerBuilder: (context) {
                    return Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [],
                      ),
                    );
                  },
                );
              },
              type: MaterialButtonType.commonbutton,
              lableText: 'LeftTop Side Sheet',
              labelTextStyle: context.textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
          ),
          SizedBox(
            child: MaterialButton3(
              backgoundColor: AppColors.green,
              borderColor: AppColors.green,
              borderRadius: DeviceDimension.padding,
              shadowColor: AppColors.grey,
              textAlign: TextAlign.center,
              onTap: () async {
                showModalSideSheet(
                  // Required
                  context,
                  // Pass your content widget (required)
                  body: Container(
                    width: context.mediaQuery.size.width / 2,
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  direction: DirectionSideSheet.right,
                  alignment: Alignment.topRight,
                  // Required
                  header: 'Edit user',
                  barrierDismissible: false,
                  addBackIconButton: false,
                  addCloseIconButton: true,
                  addActions: true,
                  addDivider: true,
                  confirmActionTitle: 'Update',
                  cancelActionTitle: 'Cancel',
                  confirmActionOnPressed: () {
                    Navigator.pop(context);
                    debugPrint('on confirm action');
                  },
                  cancelActionOnPressed: () {
                    Navigator.pop(context);
                    debugPrint('on cancel event');
                  },
                  transitionDuration: const Duration(milliseconds: 500),
                  closeButtonTooltip: 'Close',
                  backButtonTooltip: 'Back',
                  onDismiss: () {
                    debugPrint('on dismiss event');
                  },
                  onClose: () {
                    Navigator.pop(context);
                    debugPrint('on close event');
                  },
                  headerBuilder: (context) {
                    return Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [],
                      ),
                    );
                  },
                );
              },
              type: MaterialButtonType.commonbutton,
              lableText: 'TopRight Side Sheet',
              labelTextStyle: context.textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
          ),
          SizedBox(
            child: MaterialButton3(
              backgoundColor: AppColors.green,
              borderColor: AppColors.green,
              borderRadius: DeviceDimension.padding,
              shadowColor: AppColors.grey,
              textAlign: TextAlign.center,
              onTap: () async {
                showModalSideSheet(
                  // Required
                  context,
                  // Pass your content widget (required)
                  body: Container(
                    width: context.mediaQuery.size.width / 2,
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  direction: DirectionSideSheet.left,
                  alignment: Alignment.centerLeft,
                  // Required
                  header: 'Edit user',
                  barrierDismissible: false,
                  addBackIconButton: false,
                  addCloseIconButton: true,
                  addActions: true,
                  addDivider: true,
                  confirmActionTitle: 'Update',
                  cancelActionTitle: 'Cancel',
                  confirmActionOnPressed: () {
                    Navigator.pop(context);
                    debugPrint('on confirm action');
                  },
                  cancelActionOnPressed: () {
                    Navigator.pop(context);
                    debugPrint('on cancel event');
                  },
                  transitionDuration: const Duration(milliseconds: 500),
                  closeButtonTooltip: 'Close',
                  backButtonTooltip: 'Back',
                  onDismiss: () {
                    debugPrint('on dismiss event');
                  },
                  onClose: () {
                    Navigator.pop(context);
                    debugPrint('on close event');
                  },
                  headerBuilder: (context) {
                    return Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [],
                      ),
                    );
                  },
                );
              },
              type: MaterialButtonType.commonbutton,
              lableText: 'LeftCenter Side Sheet',
              labelTextStyle: context.textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
          ),
          SizedBox(
            child: MaterialButton3(
              backgoundColor: AppColors.green,
              borderColor: AppColors.green,
              borderRadius: DeviceDimension.padding,
              shadowColor: AppColors.grey,
              textAlign: TextAlign.center,
              onTap: () async {
                showModalSideSheet(
                  // Required
                  context,
                  // Pass your content widget (required)
                  body: Container(
                    width: context.mediaQuery.size.width / 2,
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  direction: DirectionSideSheet.right,
                  alignment: Alignment.centerRight,
                  // Required
                  header: 'Edit user',
                  barrierDismissible: false,
                  addBackIconButton: false,
                  addCloseIconButton: true,
                  addActions: true,
                  addDivider: true,
                  confirmActionTitle: 'Update',
                  cancelActionTitle: 'Cancel',
                  confirmActionOnPressed: () {
                    Navigator.pop(context);
                    debugPrint('on confirm action');
                  },
                  cancelActionOnPressed: () {
                    Navigator.pop(context);
                    debugPrint('on cancel event');
                  },
                  transitionDuration: const Duration(milliseconds: 500),
                  closeButtonTooltip: 'Close',
                  backButtonTooltip: 'Back',
                  onDismiss: () {
                    debugPrint('on dismiss event');
                  },
                  onClose: () {
                    Navigator.pop(context);
                    debugPrint('on close event');
                  },
                  headerBuilder: (context) {
                    return Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [],
                      ),
                    );
                  },
                );
              },
              type: MaterialButtonType.commonbutton,
              lableText: 'RightCenter Side Sheet',
              labelTextStyle: context.textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
