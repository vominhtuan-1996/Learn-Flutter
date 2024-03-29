import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learnflutter/base_loading_screen/base_loading.dart';
import 'package:learnflutter/core/extension/extension_context.dart';
import 'package:learnflutter/modules/material/component/component_material_mixi.dart';
import 'package:learnflutter/modules/material/material_screen.dart';
import 'package:learnflutter/modules/material/material_screen_detail.dart';
import 'package:learnflutter/modules/shimmer/shimmer_utils/shimmer_utils.dart';
import 'package:learnflutter/modules/shimmer/widget/shimmer_loading_widget.dart';
import 'package:learnflutter/modules/shimmer/widget/shimmer_widget.dart';
import 'package:learnflutter/src/app_box_decoration.dart';

class MaterialBadge extends StatefulWidget {
  const MaterialBadge({super.key, required this.data});
  final RoouterMaterialModel data;
  @override
  State<MaterialBadge> createState() => MaterialBadgeState();
}

class MaterialBadgeState extends State<MaterialBadge> with ComponentMaterialDetail {
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ShimmerLoading(
                isLoading: true,
                child: Container(
                  decoration: AppBoxDecoration.boxDecorationBorderRadius(
                    borderRadiusValue: 16,
                    borderWidth: 1,
                    colorBackground: context.theme.colorScheme.secondary,
                    colorBorder: Colors.grey,
                  ),
                  width: context.mediaQuery.size.width / 3,
                  height: context.mediaQuery.size.height / 3,
                  child: const Center(
                    child: SizedBox(width: 12, height: 12, child: Badge()),
                  ),
                ),
              ),
              ShimmerLoading(
                isLoading: true,
                child: Container(
                  decoration: AppBoxDecoration.boxDecorationBorderRadius(
                    borderRadiusValue: 16,
                    borderWidth: 1,
                    colorBackground: context.theme.colorScheme.secondaryContainer,
                    colorBorder: Colors.grey,
                  ),
                  width: context.mediaQuery.size.width / 3,
                  height: context.mediaQuery.size.height / 3,
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: Badge.count(
                        count: 3,
                        textColor: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
