import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learnflutter/app/device_dimension.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';
import 'package:learnflutter/modules/material/component/component_material_mixi.dart';
import 'package:learnflutter/modules/material/component/meterial_button_3/material_button_3.dart';
import 'package:learnflutter/modules/material/material_screen.dart';
import 'package:learnflutter/modules/material/material_screen_detail.dart';
import 'package:learnflutter/app/app_colors.dart';

class MaterialFloatingButtonDetail extends StatefulWidget {
  const MaterialFloatingButtonDetail({super.key, required this.data});
  final RoouterMaterialModel data;
  @override
  State<MaterialFloatingButtonDetail> createState() => _MaterialFloatingButtonDetailState();
}

class _MaterialFloatingButtonDetailState extends State<MaterialFloatingButtonDetail> with ComponentMaterialDetail {
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
            Card(
              child: Padding(
                padding: EdgeInsets.all(DeviceDimension.padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: DeviceDimension.padding / 2),
                      child: Text(
                        'Small FABs',
                        style: context.textTheme.displayMedium,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: DeviceDimension.padding / 2),
                      child: Text(
                        'Surface',
                        style: context.textTheme.labelMedium,
                      ),
                    ),
                    Wrap(
                      direction: Axis.horizontal,
                      runSpacing: DeviceDimension.padding / 2,
                      spacing: DeviceDimension.padding / 2,
                      children: List.generate(
                        4,
                        (index) {
                          return FloatingActionButton(
                            mini: true,
                            child: Icon(Icons.edit),
                            backgroundColor: context.colorScheme.onSurface,
                            onPressed: () {},
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: DeviceDimension.padding / 2),
                      child: Text(
                        'Primary',
                        style: context.textTheme.labelMedium,
                      ),
                    ),
                    Wrap(
                      direction: Axis.horizontal,
                      runSpacing: DeviceDimension.padding / 2,
                      spacing: DeviceDimension.padding / 2,
                      children: List.generate(
                        4,
                        (index) {
                          return FloatingActionButton(
                            mini: true,
                            child: Icon(Icons.edit),
                            backgroundColor: context.colorScheme.primary,
                            onPressed: () {},
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: DeviceDimension.padding / 2),
                      child: Text(
                        'Secondary',
                        style: context.textTheme.labelMedium,
                      ),
                    ),
                    Wrap(
                      direction: Axis.horizontal,
                      runSpacing: DeviceDimension.padding / 2,
                      spacing: DeviceDimension.padding / 2,
                      children: List.generate(
                        4,
                        (index) {
                          return FloatingActionButton(
                            mini: true,
                            child: Icon(Icons.edit),
                            backgroundColor: context.colorScheme.secondary,
                            onPressed: () {},
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: DeviceDimension.padding / 2),
                      child: Text(
                        'Tertiary',
                        style: context.textTheme.labelMedium,
                      ),
                    ),
                    Wrap(
                      direction: Axis.horizontal,
                      runSpacing: DeviceDimension.padding / 2,
                      spacing: DeviceDimension.padding / 2,
                      children: List.generate(
                        4,
                        (index) {
                          return FloatingActionButton(
                            mini: true,
                            child: Icon(Icons.edit),
                            backgroundColor: context.colorScheme.tertiary,
                            onPressed: () {},
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: EdgeInsets.all(DeviceDimension.padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: DeviceDimension.padding / 2),
                      child: Text(
                        'FABs',
                        style: context.textTheme.displayMedium,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: DeviceDimension.padding / 2),
                      child: Text(
                        'Surface',
                        style: context.textTheme.labelMedium,
                      ),
                    ),
                    Wrap(
                      direction: Axis.horizontal,
                      runSpacing: DeviceDimension.padding / 2,
                      spacing: DeviceDimension.padding / 2,
                      children: List.generate(
                        4,
                        (index) {
                          return FloatingActionButton(
                            child: Icon(Icons.edit),
                            backgroundColor: context.colorScheme.onSurface,
                            onPressed: () {},
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: DeviceDimension.padding / 2),
                      child: Text(
                        'Primary',
                        style: context.textTheme.labelMedium,
                      ),
                    ),
                    Wrap(
                      direction: Axis.horizontal,
                      runSpacing: DeviceDimension.padding / 2,
                      spacing: DeviceDimension.padding / 2,
                      children: List.generate(
                        4,
                        (index) {
                          return FloatingActionButton(
                            child: Icon(Icons.edit),
                            backgroundColor: context.colorScheme.primary,
                            onPressed: () {},
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: DeviceDimension.padding / 2),
                      child: Text(
                        'Secondary',
                        style: context.textTheme.labelMedium,
                      ),
                    ),
                    Wrap(
                      direction: Axis.horizontal,
                      runSpacing: DeviceDimension.padding / 2,
                      spacing: DeviceDimension.padding / 2,
                      children: List.generate(
                        4,
                        (index) {
                          return FloatingActionButton(
                            child: Icon(Icons.edit),
                            backgroundColor: context.colorScheme.secondary,
                            onPressed: () {},
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: DeviceDimension.padding / 2),
                      child: Text(
                        'Tertiary',
                        style: context.textTheme.labelMedium,
                      ),
                    ),
                    Wrap(
                      direction: Axis.horizontal,
                      runSpacing: DeviceDimension.padding / 2,
                      spacing: DeviceDimension.padding / 2,
                      children: List.generate(
                        4,
                        (index) {
                          return FloatingActionButton(
                            child: Icon(Icons.edit),
                            backgroundColor: context.colorScheme.tertiary,
                            onPressed: () {},
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: EdgeInsets.all(DeviceDimension.padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: DeviceDimension.padding / 2),
                      child: Text(
                        'Large FABs',
                        style: context.textTheme.displayMedium,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: DeviceDimension.padding / 2),
                      child: Text(
                        'Surface',
                        style: context.textTheme.labelMedium,
                      ),
                    ),
                    Wrap(
                      direction: Axis.horizontal,
                      runSpacing: DeviceDimension.padding / 2,
                      spacing: DeviceDimension.padding / 2,
                      children: List.generate(
                        4,
                        (index) {
                          return FloatingActionButton.large(
                            child: Icon(Icons.edit),
                            backgroundColor: context.colorScheme.onSurface,
                            onPressed: () {},
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: DeviceDimension.padding / 2),
                      child: Text(
                        'Primary',
                        style: context.textTheme.labelMedium,
                      ),
                    ),
                    Wrap(
                      direction: Axis.horizontal,
                      runSpacing: DeviceDimension.padding / 2,
                      spacing: DeviceDimension.padding / 2,
                      children: List.generate(
                        4,
                        (index) {
                          return FloatingActionButton.large(
                            child: Icon(Icons.edit),
                            backgroundColor: context.colorScheme.primary,
                            onPressed: () {},
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: DeviceDimension.padding / 2),
                      child: Text(
                        'Secondary',
                        style: context.textTheme.labelMedium,
                      ),
                    ),
                    Wrap(
                      direction: Axis.horizontal,
                      runSpacing: DeviceDimension.padding / 2,
                      spacing: DeviceDimension.padding / 2,
                      children: List.generate(
                        4,
                        (index) {
                          return FloatingActionButton.large(
                            child: Icon(Icons.edit),
                            backgroundColor: context.colorScheme.secondary,
                            onPressed: () {},
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: DeviceDimension.padding / 2),
                      child: Text(
                        'Tertiary',
                        style: context.textTheme.labelMedium,
                      ),
                    ),
                    Wrap(
                      direction: Axis.horizontal,
                      runSpacing: DeviceDimension.padding / 2,
                      spacing: DeviceDimension.padding / 2,
                      children: List.generate(
                        4,
                        (index) {
                          return FloatingActionButton.large(
                            child: Icon(Icons.edit),
                            backgroundColor: context.colorScheme.tertiary,
                            onPressed: () {},
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: EdgeInsets.all(DeviceDimension.padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: DeviceDimension.padding / 2),
                      child: Text(
                        'Extended FABs',
                        style: context.textTheme.displayMedium,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: DeviceDimension.padding / 2),
                      child: Text(
                        'Surface',
                        style: context.textTheme.labelMedium,
                      ),
                    ),
                    Wrap(
                      direction: Axis.horizontal,
                      runSpacing: DeviceDimension.padding / 2,
                      spacing: DeviceDimension.padding / 2,
                      children: List.generate(
                        4,
                        (index) {
                          return FloatingActionButton.extended(
                            label: Text('Label'),
                            icon: Icon(Icons.edit),
                            backgroundColor: context.colorScheme.onSurface,
                            onPressed: () {},
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: DeviceDimension.padding / 2),
                      child: Text(
                        'Primary',
                        style: context.textTheme.labelMedium,
                      ),
                    ),
                    Wrap(
                      direction: Axis.horizontal,
                      runSpacing: DeviceDimension.padding / 2,
                      spacing: DeviceDimension.padding / 2,
                      children: List.generate(
                        4,
                        (index) {
                          return FloatingActionButton.extended(
                            label: Text('Label'),
                            icon: Icon(Icons.edit),
                            backgroundColor: context.colorScheme.primary,
                            onPressed: () {},
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: DeviceDimension.padding / 2),
                      child: Text(
                        'Secondary',
                        style: context.textTheme.labelMedium,
                      ),
                    ),
                    Wrap(
                      direction: Axis.horizontal,
                      runSpacing: DeviceDimension.padding / 2,
                      spacing: DeviceDimension.padding / 2,
                      children: List.generate(
                        4,
                        (index) {
                          return FloatingActionButton.extended(
                            label: Text('Label'),
                            icon: Icon(Icons.edit),
                            backgroundColor: context.colorScheme.secondary,
                            onPressed: () {},
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: DeviceDimension.padding / 2),
                      child: Text(
                        'Tertiary',
                        style: context.textTheme.labelMedium,
                      ),
                    ),
                    Wrap(
                      direction: Axis.horizontal,
                      runSpacing: DeviceDimension.padding / 2,
                      spacing: DeviceDimension.padding / 2,
                      children: List.generate(
                        4,
                        (index) {
                          return FloatingActionButton.extended(
                            label: Text('Label'),
                            icon: Icon(Icons.edit),
                            backgroundColor: context.colorScheme.tertiary,
                            onPressed: () {},
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
