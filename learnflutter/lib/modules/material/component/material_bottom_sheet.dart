import 'package:flutter/material.dart';
import 'package:learnflutter/core/app/device_dimension.dart';
import 'package:learnflutter/component/bottom_sheet/overlay_bottom_sheet.dart';
import 'package:learnflutter/custom_widget/advanced_bottom_sheet.dart';
import 'package:learnflutter/modules/scroll_physic/extension/scroll_physics/nobounce_scroll_physics.dart';
import 'package:learnflutter/modules/animation/widget/scale_translate.dart';
import 'package:learnflutter/modules/material/component/metarial_radio_button/metarial_radio_button.dart';
import 'package:learnflutter/modules/material/component/metarial_radio_button/radio_item_model.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';
import 'package:learnflutter/modules/animation/widget/icon_animation_widget.dart';
import 'package:learnflutter/modules/material/component/component_material_mixi.dart';
import 'package:learnflutter/modules/material/component/meterial_button_3/material_button_3.dart';
import 'package:learnflutter/modules/material/material_screen.dart';
import 'package:learnflutter/modules/material/material_screen_detail.dart';
import 'package:learnflutter/core/app/app_colors.dart';
import 'package:learnflutter/utils_helper/dialog_utils.dart';

class MaterialBottomSheet extends StatefulWidget {
  const MaterialBottomSheet({super.key, required this.data});
  final RouterMaterialModel data;
  @override
  State<MaterialBottomSheet> createState() => _MaterialBottomSheetState();
}

class _MaterialBottomSheetState extends State<MaterialBottomSheet> with ComponentMaterialDetail {
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
                DialogUtils.showBottomSheet(
                  context: context,
                  height: 500,
                  isDismissible: false,
                  // isScrollControlled: false,
                  contentWidget: Wrap(
                    spacing: DeviceDimension.padding / 2,
                    runSpacing: DeviceDimension.padding / 2,
                    children: List.generate(
                      12,
                      (index) {
                        return Card.outlined(
                          color: Colors.red,
                          child: FloatingActionButton.large(
                            onPressed: () async {
                              DialogUtils.dismissPopup(
                                context,
                                complete: () async {
                                  DialogUtils.showBasicDialog(
                                    title: 'Basic dialog title',
                                    context: context,
                                    content: 'A dialog is a type of modal window that appears in front of app content to provide critical information, or prompt for a decision to be made.',
                                    contentWidget: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const IconAnimationWidget(),
                                        SizedBox(height: DeviceDimension.padding),
                                        Text(
                                          'Success',
                                          style: context.textTheme.titleLarge?.copyWith(
                                            color: AppColors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: DeviceDimension.padding),
                                        Text(
                                          'Your action was successful!',
                                          style: context.textTheme.bodyMedium?.copyWith(
                                            color: AppColors.grey,
                                          ),
                                        ),
                                        const IconAnimationWidget(),
                                        SizedBox(height: DeviceDimension.padding),
                                        Text(
                                          'Success',
                                          style: context.textTheme.titleLarge?.copyWith(
                                            color: AppColors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: DeviceDimension.padding),
                                        Text(
                                          'Your action was successful!',
                                          style: context.textTheme.bodyMedium?.copyWith(
                                            color: AppColors.grey,
                                          ),
                                        ),
                                        const IconAnimationWidget(),
                                        SizedBox(height: DeviceDimension.padding),
                                        Text(
                                          'Success',
                                          style: context.textTheme.titleLarge?.copyWith(
                                            color: AppColors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: DeviceDimension.padding),
                                        Text(
                                          'Your action was successful!',
                                          style: context.textTheme.bodyMedium?.copyWith(
                                            color: AppColors.grey,
                                          ),
                                        ),
                                        const IconAnimationWidget(),
                                        SizedBox(height: DeviceDimension.padding),
                                        Text(
                                          'Success',
                                          style: context.textTheme.titleLarge?.copyWith(
                                            color: AppColors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: DeviceDimension.padding),
                                        Text(
                                          'Your action was successful!',
                                          style: context.textTheme.bodyMedium?.copyWith(
                                            color: AppColors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
              type: MaterialButtonType.commonbutton,
              lableText: 'Bottom Action Sheet',
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
                DialogUtils.openDraggableBottomSheet(
                  context: context,
                  backgroundColor: Colors.white,
                  initialSize: 0.5,
                  maxSize: 0.9,
                  // isScrollControlled: false,
                  child: PageView.builder(
                    physics: NoBounceScrollPhysics(),
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        child: Container(
                          color: Colors.primaries[index % Colors.primaries.length],
                        ),
                      );
                    },
                  ),
                );
              },
              type: MaterialButtonType.commonbutton,
              lableText: 'Bottom Action Sheet Draggable',
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
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const AdvancedBottomSheet(),
                );
              },
              type: MaterialButtonType.commonbutton,
              lableText: ' custom Bottom Action Sheet Draggable',
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
                BottomSheetOverlay.show(
                  context,
                  minHeight: 80,
                  initialHeight: 300,
                  maxHeight: context.mediaQuery.size.height * 0.9,
                  barrierDismissible: false,
                  builder: () {
                    return Column(
                      children: [
                        MetarialRadioButton.single(
                          enable: true,
                          data: [
                            RadioItemModel(title: "Radio 1", id: "1", isSelected: true),
                            RadioItemModel(title: "Radio 2", id: "2", isSelected: false),
                            RadioItemModel(title: "Radio 3", id: "3", isSelected: false),
                            RadioItemModel(title: "Radio 4", id: "4", isSelected: false),
                            RadioItemModel(title: "Radio 5", id: "5", isSelected: false),
                            RadioItemModel(title: "Radio 6", id: "6", isSelected: false),
                            RadioItemModel(title: "Radio 7", id: "7", isSelected: false),
                            RadioItemModel(title: "Radio 8", id: "8", isSelected: false),
                            RadioItemModel(title: "Radio 9", id: "9", isSelected: false),
                            RadioItemModel(title: "Radio 10", id: "10", isSelected: false),
                          ],
                          onChangeValue: (value) {
                            print(value?.title ?? "");
                          },
                        ),
                        MetarialRadioButton.single(
                          enable: true,
                          data: [
                            RadioItemModel(title: "Radio 1", id: "1", isSelected: true),
                            RadioItemModel(title: "Radio 2", id: "2", isSelected: false),
                            RadioItemModel(title: "Radio 3", id: "3", isSelected: false),
                            RadioItemModel(title: "Radio 4", id: "4", isSelected: false),
                            RadioItemModel(title: "Radio 5", id: "5", isSelected: false),
                            RadioItemModel(title: "Radio 6", id: "6", isSelected: false),
                            RadioItemModel(title: "Radio 7", id: "7", isSelected: false),
                            RadioItemModel(title: "Radio 8", id: "8", isSelected: false),
                            RadioItemModel(title: "Radio 9", id: "9", isSelected: false),
                            RadioItemModel(title: "Radio 10", id: "10", isSelected: false),
                          ],
                          onChangeValue: (value) {
                            print(value?.title ?? "");
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              type: MaterialButtonType.commonbutton,
              lableText: 'BottomSheet overlay builder',
              labelTextStyle: context.textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
