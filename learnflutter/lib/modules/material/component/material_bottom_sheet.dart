import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/app/device_dimension.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';
import 'package:learnflutter/core/global/func_global.dart';
import 'package:learnflutter/component/drag.dart';
import 'package:learnflutter/modules/animation/widget/icon_animation_widget.dart';
import 'package:learnflutter/modules/animation/widget/position_ananimation.dart';
import 'package:learnflutter/modules/material/component/component_material_mixi.dart';
import 'package:learnflutter/modules/material/component/material_textfield/material_textfield.dart';
import 'package:learnflutter/modules/material/component/meterial_button_3/material_button_3.dart';
import 'package:learnflutter/modules/material/material_screen.dart';
import 'package:learnflutter/modules/material/material_screen_detail.dart';
import 'package:learnflutter/app/app_box_decoration.dart';
import 'package:learnflutter/app/app_colors.dart';
import 'package:learnflutter/modules/material/component/metarial_dialog/dialog_utils.dart';

class MaterialBottomSheet extends StatefulWidget {
  const MaterialBottomSheet({super.key, required this.data});
  final RoouterMaterialModel data;
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
        contentWidget: Container(
          color: context.theme.colorScheme.onSecondaryContainer,
          child: SizedBox(
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
                                        IconAnimationWidget(),
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
                                        IconAnimationWidget(),
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
                                        IconAnimationWidget(),
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
                                        IconAnimationWidget(),
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
        ));
  }
}
