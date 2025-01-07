import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learnflutter/app/device_dimension.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';
import 'package:learnflutter/utils_helper/extension/extension_list.dart';
import 'package:learnflutter/modules/material/component/component_material_mixi.dart';
import 'package:learnflutter/modules/material/material_screen.dart';
import 'package:learnflutter/modules/material/material_screen_detail.dart';

class MaterialChipScreen extends StatefulWidget {
  const MaterialChipScreen({super.key, required this.data});
  final RoouterMaterialModel data;
  @override
  State<MaterialChipScreen> createState() => _MaterialChipScreenState();
}

class _MaterialChipScreenState extends State<MaterialChipScreen> with ComponentMaterialDetail {
  bool selected = true;
  List<bool> surfaceChoiceChip = [true, true, true, true];
  List<bool> primaryChoiceChip = [true, true, true, true];
  List<bool> secondaryChoiceChip = [true, true, true, true];
  List<bool> tertiaryChoiceChip = [true, true, true, true];
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
                      padding: EdgeInsets.only(bottom: DeviceDimension.padding / 2),
                      child: Text(
                        'Surface',
                        style: context.textTheme.labelMedium,
                      ),
                    ),
                    Wrap(
                      direction: Axis.horizontal,
                      runSpacing: DeviceDimension.padding / 2,
                      spacing: DeviceDimension.padding / 4,
                      children: List.generate(
                        4,
                        (index) {
                          return ChoiceChip.elevated(
                            label: Text('label'),
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            selected: surfaceChoiceChip[index],
                            tooltip: 'tooltip',
                            onSelected: (value) {
                              surfaceChoiceChip.update(index: index, item: value);
                              setState(() {});
                            },
                            selectedColor: context.colorScheme.surface,
                            elevation: 0.6,
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
                          return ChoiceChip.elevated(
                            label: Text('label'),
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            selected: primaryChoiceChip[index],
                            tooltip: 'tooltip',
                            onSelected: (value) {
                              primaryChoiceChip.update(index: index, item: value);
                              setState(() {});
                            },
                            selectedColor: context.colorScheme.primary,
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
                          return ChoiceChip(
                            label: Text('label'),
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            selected: secondaryChoiceChip[index],
                            tooltip: 'tooltip',
                            onSelected: (value) {
                              secondaryChoiceChip.update(index: index, item: value);
                              setState(() {});
                            },
                            selectedColor: context.colorScheme.secondary,
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
                          return ChoiceChip(
                            label: Text('label'),
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            selected: tertiaryChoiceChip[index],
                            tooltip: 'tooltip',
                            onSelected: (value) {
                              tertiaryChoiceChip.update(index: index, item: value);
                              setState(() {});
                            },
                            selectedColor: context.colorScheme.tertiary,
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
