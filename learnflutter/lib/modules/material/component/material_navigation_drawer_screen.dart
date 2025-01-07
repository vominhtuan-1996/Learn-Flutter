import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learnflutter/app/device_dimension.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';
import 'package:learnflutter/modules/material/component/component_material_mixi.dart';
import 'package:learnflutter/modules/material/component/metarial_dialog/dialog_utils.dart';
import 'package:learnflutter/modules/material/component/meterial_button_3/material_button_3.dart';
import 'package:learnflutter/modules/material/material_screen.dart';
import 'package:learnflutter/modules/material/material_screen_detail.dart';
import 'package:learnflutter/modules/slider_vertical/progess_bar_custom.dart';
import 'package:learnflutter/app/app_colors.dart';

class MaterialNavigationDrawerScreen extends StatefulWidget {
  const MaterialNavigationDrawerScreen({super.key, required this.data});
  final RoouterMaterialModel data;
  @override
  State<MaterialNavigationDrawerScreen> createState() => _MaterialProgressIndicatorsState();
}

class _MaterialProgressIndicatorsState extends State<MaterialNavigationDrawerScreen> with ComponentMaterialDetail {
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
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: List.generate(
              20,
              (index) {
                return FloatingActionButton.extended(
                  label: Text('Label'),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ),
      ),
      contentWidget: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Liner',
              style: context.textTheme.headlineMedium,
            ),
            Text(
              'Determinate',
              style: context.textTheme.headlineMedium,
            ),
            Text(
              'Circular',
              style: context.textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}
