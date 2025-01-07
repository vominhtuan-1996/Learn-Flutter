import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/app/device_dimension.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';
import 'package:learnflutter/modules/material/component/component_material_mixi.dart';
import 'package:learnflutter/modules/material/material_screen.dart';
import 'package:learnflutter/modules/material/material_screen_detail.dart';
import 'package:learnflutter/app/app_box_decoration.dart';

class MaterialBottomAppBar extends StatefulWidget {
  const MaterialBottomAppBar({super.key, required this.data});
  final RoouterMaterialModel data;
  @override
  State<MaterialBottomAppBar> createState() => _MaterialBottomAppBarState();
}

class _MaterialBottomAppBarState extends State<MaterialBottomAppBar> with ComponentMaterialDetail {
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              BottomAppBar(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          color: Colors.transparent,
                          padding: EdgeInsets.all(DeviceDimension.padding / 2),
                        ),
                        Positioned(
                          left: 10,
                          right: 10,
                          bottom: 6,
                          top: 6,
                          child: Container(
                            decoration: AppBoxDecoration.boxDecorationBorderRadius(
                              borderRadiusValue: 4,
                              borderWidth: 1,
                              colorBackground: context.theme.colorScheme.secondaryContainer,
                              colorBorder: Colors.grey,
                            ),
                            width: 32,
                            height: 32,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Badge(
                            backgroundColor: Colors.blueAccent,
                          ),
                        )
                      ],
                    ),
                    Stack(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          color: Colors.transparent,
                          padding: EdgeInsets.all(DeviceDimension.padding / 2),
                        ),
                        Positioned(
                          left: 10,
                          right: 10,
                          bottom: 6,
                          top: 6,
                          child: Container(
                            decoration: AppBoxDecoration.boxDecorationBorderRadius(
                              borderRadiusValue: 4,
                              borderWidth: 1,
                              colorBackground: context.theme.colorScheme.secondaryContainer,
                              colorBorder: Colors.grey,
                            ),
                            width: 32,
                            height: 32,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Badge(
                            backgroundColor: Colors.blueAccent,
                          ),
                        )
                      ],
                    ),
                    Stack(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          color: Colors.transparent,
                          padding: EdgeInsets.all(DeviceDimension.padding / 2),
                        ),
                        Positioned(
                          left: 10,
                          right: 10,
                          bottom: 6,
                          top: 6,
                          child: Container(
                            decoration: AppBoxDecoration.boxDecorationBorderRadius(
                              borderRadiusValue: 4,
                              borderWidth: 1,
                              colorBackground: context.theme.colorScheme.secondaryContainer,
                              colorBorder: Colors.grey,
                            ),
                            width: 32,
                            height: 32,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Badge(
                            backgroundColor: Colors.blueAccent,
                          ),
                        )
                      ],
                    ),
                    Stack(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          color: Colors.transparent,
                          padding: EdgeInsets.all(DeviceDimension.padding / 2),
                        ),
                        Positioned(
                          left: 10,
                          right: 10,
                          bottom: 6,
                          top: 6,
                          child: Container(
                            decoration: AppBoxDecoration.boxDecorationBorderRadius(
                              borderRadiusValue: 4,
                              borderWidth: 1,
                              colorBackground: context.theme.colorScheme.secondaryContainer,
                              colorBorder: Colors.grey,
                            ),
                            width: 32,
                            height: 32,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Badge(
                            backgroundColor: Colors.blueAccent,
                          ),
                        )
                      ],
                    ),
                    Stack(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          color: Colors.transparent,
                          padding: EdgeInsets.all(DeviceDimension.padding / 2),
                        ),
                        Positioned(
                          left: 10,
                          right: 10,
                          bottom: 6,
                          top: 6,
                          child: Container(
                            decoration: AppBoxDecoration.boxDecorationBorderRadius(
                              borderRadiusValue: 4,
                              borderWidth: 1,
                              colorBackground: context.theme.colorScheme.secondaryContainer,
                              colorBorder: Colors.grey,
                            ),
                            width: 32,
                            height: 32,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: Badge.count(
                              count: 3,
                              textColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                child: const BottomAppBar(
                  child: Badge(),
                ),
              ),
              Container(
                child: const BottomAppBar(
                  child: Badge(),
                ),
              ),
              Container(
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
              )
            ],
          ),
        ));
  }
}
