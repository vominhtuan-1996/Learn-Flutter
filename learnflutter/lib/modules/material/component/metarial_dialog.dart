import 'package:flutter/material.dart';
import 'package:learnflutter/app/device_dimension.dart';
import 'package:learnflutter/core/global/func_global.dart';
import 'package:learnflutter/modules/material/component/metarial_radio_button/radio_item_model.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';
import 'package:learnflutter/modules/animation/widget/icon_animation_widget.dart';
import 'package:learnflutter/modules/material/component/component_material_mixi.dart';
import 'package:learnflutter/modules/material/component/meterial_button_3/material_button_3.dart';
import 'package:learnflutter/modules/material/material_screen.dart';
import 'package:learnflutter/modules/material/material_screen_detail.dart';
import 'package:learnflutter/app/app_colors.dart';
import 'package:learnflutter/utils_helper/dialog_utils.dart';

class MaterialDialog extends StatefulWidget {
  const MaterialDialog({super.key, required this.data});
  final RouterMaterialModel data;
  @override
  State<MaterialDialog> createState() => _MaterialDialogState();
}

class _MaterialDialogState extends State<MaterialDialog> with ComponentMaterialDetail {
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
            MaterialButton3(
              disible: false,
              backgoundColor: context.theme.colorScheme.onPrimary,
              borderColor: context.theme.colorScheme.onPrimary,
              borderRadius: DeviceDimension.padding,
              shadowColor: AppColors.grey,
              textAlign: TextAlign.center,
              onTap: () async {
                DialogUtils.showBasicDialog(
                  title: 'Basic dialog title',
                  context: context,
                  content: 'A dialog is a type of modal window that appears in front of app content to provide critical information, or prompt for a decision to be made.',
                );
              },
              type: MaterialButtonType.commonbutton,
              lableText: 'Basic dialog title',
              labelTextStyle: context.textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
            MaterialButton3(
              disible: false,
              backgoundColor: context.theme.colorScheme.onPrimary,
              borderColor: context.theme.colorScheme.onPrimary,
              borderRadius: DeviceDimension.padding,
              shadowColor: AppColors.grey,
              textAlign: TextAlign.center,
              onTap: () async {
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
              type: MaterialButtonType.commonbutton,
              lableText: 'dialog Title',
              labelTextStyle: context.textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
            MaterialButton3(
              disible: false,
              backgoundColor: context.theme.colorScheme.onPrimary,
              borderColor: context.theme.colorScheme.onPrimary,
              borderRadius: DeviceDimension.padding,
              shadowColor: AppColors.grey,
              textAlign: TextAlign.center,
              onTap: () async {
                DialogUtils.showDialogWithHeroIcon(
                    context: context,
                    type: TypeDialog.success,
                    content: 'A dialog is a type of modal window that appears in front of app content to provide critical information, or prompt for a decision to be made. ',
                    title: 'Dialog with hero icon');
              },
              type: MaterialButtonType.commonbutton,
              lableText: 'Dialog with hero icon',
              labelTextStyle: context.textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
            MaterialButton3(
              disible: false,
              backgoundColor: context.theme.colorScheme.onPrimary,
              borderColor: context.theme.colorScheme.onPrimary,
              borderRadius: DeviceDimension.padding,
              shadowColor: AppColors.grey,
              textAlign: TextAlign.center,
              onTap: () async {
                DialogUtils.showDialogWithHeroIcon(
                  context: context,
                  type: TypeDialog.success,
                  content: 'A dialog is a type of modal window that appears in front of app content to provide critical information, or prompt for a decision to be made. ',
                  title: 'Dialog with hero icon',
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
              type: MaterialButtonType.commonbutton,
              lableText: 'Dialog with hero icon',
              labelTextStyle: context.textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
            MaterialButton3(
              disible: false,
              backgoundColor: context.theme.colorScheme.onPrimary,
              borderColor: context.theme.colorScheme.onPrimary,
              borderRadius: DeviceDimension.padding,
              shadowColor: AppColors.grey,
              textAlign: TextAlign.center,
              onTap: () async {
                DialogUtils.showDownload(
                  contextDialog: context,
                  savePath: await downLoadFolder(),
                );
              },
              type: MaterialButtonType.commonbutton,
              lableText: 'Dialog Download File',
              labelTextStyle: context.textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
            MaterialButton3(
              disible: false,
              backgoundColor: context.theme.colorScheme.onPrimary,
              borderColor: context.theme.colorScheme.onPrimary,
              borderRadius: DeviceDimension.padding,
              shadowColor: AppColors.grey,
              textAlign: TextAlign.center,
              onTap: () async {
                List uploadList = [
                  RadioItemModel(id: 'id', title: 'start of 2320 libraries in 2,847ms (compile: 57 ms, reload: 1137 ms, reassemble: 1542 ms)'),
                  RadioItemModel(id: 'id', title: '2'),
                  RadioItemModel(id: 'id', title: 'of 2320 libraries in 2,847ms (compile: 57 ms, reload: 1137 ms, reassemble: 1542 ms)'),
                  RadioItemModel(id: 'id', title: '4'),
                  RadioItemModel(id: 'id', title: '5'),
                  RadioItemModel(
                      id: 'id',
                      title:
                          'of 2320 libraries in 2,847ms (compile: 57 ms, reload: 1137 ms, reassemble: 1542 ms)of 2320 libraries in 2,847ms (compile: 57 ms, reload: 1137 ms, reassemble: 1542 ms)of 2320 libraries in 2,847ms (compile: 57 ms, reload: 1137 ms, reassemble: 1542 ms)of 2320 libraries in 2,847ms (compile: 57 ms, reload: 1137 ms, reassemble: 1542 ms)of 2320 libraries in 2,847ms (compile: 57 ms, reload: 1137 ms, reassemble: 1542 ms)of 2320 libraries in 2,847ms (compile: 57 ms, reload: 1137 ms, reassemble: 1542 ms)of 2320 libraries in 2,847ms (compile: 57 ms, reload: 1137 ms, reassemble: 1542 ms)of 2320 libraries in 2,847ms (compile: 57 ms, reload: 1137 ms, reassemble: 1542 ms)'),
                  RadioItemModel(id: 'id', title: '7'),
                  RadioItemModel(id: 'id', title: '8'),
                  RadioItemModel(id: 'id', title: 'of 2320 libraries in 2,847ms (compile: 57 ms, reload: 1137 ms, reassemble: 1542 ms)'),
                  RadioItemModel(id: 'id', title: '10'),
                  RadioItemModel(id: 'id', title: 'end 11 of 2320 libraries in 2,847ms (compile: 57 ms, reload: 1137 ms, reassemble: 1542 ms)'),
                ];
                DialogUtils.showUploadProgress(
                  contextDialog: context,
                  function: (stream) async {
                    int index = 0;
                    await Future.forEach(uploadList, (element) async {
                      await Future.delayed(
                        const Duration(seconds: 2),
                        () {
                          stream.sink.add(index);
                        },
                      );
                      index++;
                    });
                  },
                  uploadList: uploadList,
                );
              },
              type: MaterialButtonType.commonbutton,
              lableText: 'Dialog upload File',
              labelTextStyle: context.textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
