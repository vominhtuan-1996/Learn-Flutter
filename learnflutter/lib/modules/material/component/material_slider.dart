import 'package:flutter/material.dart';
import 'package:learnflutter/app/device_dimension.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';
import 'package:learnflutter/modules/material/component/component_material_mixi.dart';
import 'package:learnflutter/modules/material/component/meterial_button_3/material_button_3.dart';
import 'package:learnflutter/modules/material/material_screen.dart';
import 'package:learnflutter/modules/material/material_screen_detail.dart';
import 'package:learnflutter/modules/slider_vertical/progess_bar_custom.dart';
import 'package:learnflutter/app/app_colors.dart';

class MaterialSlider extends StatefulWidget {
  const MaterialSlider({super.key, required this.data});
  final RoouterMaterialModel data;
  @override
  State<MaterialSlider> createState() => _MaterialSliderState();
}

class _MaterialSliderState extends State<MaterialSlider> with ComponentMaterialDetail {
  double valueSlider = 50;
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
            Padding(
              padding: EdgeInsets.only(left: 100),
              child: SizedBox(
                width: 200,
                height: 50,
                child: ProgressBar(
                  barColor: Color(0xFF6750A4),
                  thumbColor: Color(0xFF6750A4),
                  thumbSize: 30.0,
                  strokeWidth: 10,
                  strokeCap: StrokeCap.round,
                  min: 0,
                  max: 100,
                  showLabel: true,
                  initValue: valueSlider,
                  backGroundLabel: Colors.yellow,
                  onChanged: (value) {
                    valueSlider = value;
                    // setState(() {});
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: DeviceDimension.padding, horizontal: DeviceDimension.padding),
              child: ProgressBar(
                barColor: Color(0xFF6750A4),
                thumbColor: Color(0xFF6750A4),
                thumbSize: 30.0,
                strokeWidth: 10,
                strokeCap: StrokeCap.round,
                min: 0,
                max: 50,
                showLabel: false,
                initValue: valueSlider,
                backGroundLabel: Colors.yellow,
                onChanged: (value) {
                  valueSlider = value;
                  // setState(() {});
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(DeviceDimension.padding),
              child: ProgressBar(
                barColor: Color(0xFF6750A4),
                thumbColor: Color(0xFF6750A4),
                thumbSize: 30.0,
                strokeWidth: 10,
                strokeCap: StrokeCap.round,
                min: 0,
                max: 80,
                showLabel: true,
                backGroundLabel: Colors.blue,
                initValue: valueSlider,
                styleLabel: const TextStyle(
                  color: Colors.red,
                  fontSize: 24,
                ),
                onChanged: (value) {
                  valueSlider = value;
                  // setState(() {});
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
