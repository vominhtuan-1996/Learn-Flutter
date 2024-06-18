import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learnflutter/base_loading_screen/base_loading.dart';
import 'package:learnflutter/core/device_dimension.dart';
import 'package:learnflutter/core/extension/extension_context.dart';
import 'package:learnflutter/core/global/func_global.dart';
import 'package:learnflutter/helpper/drag.dart';
import 'package:learnflutter/modules/material/component/component_material_mixi.dart';
import 'package:learnflutter/modules/material/component/material_textfield.dart';
import 'package:learnflutter/modules/material/component/meterial_button_3/material_button_3.dart';
import 'package:learnflutter/modules/material/material_screen.dart';
import 'package:learnflutter/modules/material/material_screen_detail.dart';
import 'package:learnflutter/src/app_box_decoration.dart';
import 'package:learnflutter/src/app_colors.dart';
import 'package:learnflutter/utils_helper/dialog_utils.dart';

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
                    height: 200,
                    contentWidget: Container(
                      color: Colors.transparent,
                    ));
              },
              type: MaterialButtonType.commonbutton,
              lableText: 'Bottom Action Sheet',
              labelTextStyle: context.textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
          ),
        ));
  }
}
