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

class MaterialDividerDetail extends StatefulWidget {
  const MaterialDividerDetail({super.key, required this.data});
  final RoouterMaterialModel data;
  @override
  State<MaterialDividerDetail> createState() => _MaterialDividerDetailState();
}

class _MaterialDividerDetailState extends State<MaterialDividerDetail> with ComponentMaterialDetail {
  final double thickness = 1.2;
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
              padding: EdgeInsets.symmetric(vertical: DeviceDimension.padding / 2),
              child: Text(
                'Horizontal',
                style: context.textTheme.headlineMedium,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                4,
                (index) {
                  return Divider();
                },
              ),
            ),
            SizedBox(
              height: DeviceDimension.padding,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: DeviceDimension.padding / 2),
              child: Text(
                'Vertical',
                style: context.textTheme.headlineMedium,
              ),
            ),
            Container(
              width: context.mediaQuery.size.width,
              height: 100,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Container(
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                    VerticalDivider(
                      width: 10,
                      thickness: thickness,
                      indent: 0,
                      endIndent: 0,
                      color: Colors.grey,
                    ),
                    Container(
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.deepOrangeAccent,
                      ),
                    ),
                    VerticalDivider(
                      width: 10,
                      thickness: thickness,
                      indent: 0,
                      endIndent: 0,
                      color: Colors.grey,
                    ),
                    Container(
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                    VerticalDivider(
                      width: 10,
                      thickness: thickness,
                      indent: 0,
                      endIndent: 0,
                      color: Colors.grey,
                    ),
                    Container(
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.deepOrangeAccent,
                      ),
                    ),
                    VerticalDivider(
                      width: 10,
                      thickness: thickness,
                      indent: 0,
                      endIndent: 0,
                      color: Colors.grey,
                    ),
                    Container(
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                    VerticalDivider(
                      width: 10,
                      thickness: thickness,
                      indent: 0,
                      endIndent: 0,
                      color: Colors.grey,
                    ),
                    Container(
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.deepOrangeAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Transform.translate(
            //   offset: Offset(-60, 150),
            //   child: Container(
            //     padding: EdgeInsets.all(DeviceDimension.padding),
            //     child: Transform(
            //       // Transform
            //       alignment: FractionalOffset.center,
            //       // Rotate sliders by 90 degrees
            //       transform: Matrix4.identity()..rotateZ(270 * pi / 180),
            //       child: Divider(),
            //     ),
            //   ),
            // ),
            // Transform.translate(
            //   offset: Offset(-50, 150),
            //   child: Container(
            //     padding: EdgeInsets.all(DeviceDimension.padding),
            //     child: Transform(
            //       // Transform
            //       alignment: FractionalOffset.center,
            //       // Rotate sliders by 90 degrees
            //       transform: Matrix4.identity()..rotateZ(270 * pi / 180),
            //       child: Divider(),
            //     ),
            //   ),
            // ),
            // Transform.translate(
            //   offset: Offset(-40, 160),
            //   child: Container(
            //     padding: EdgeInsets.all(DeviceDimension.padding),
            //     child: Transform(
            //       // Transform
            //       alignment: FractionalOffset.center,
            //       // Rotate sliders by 90 degrees
            //       transform: Matrix4.identity()..rotateZ(270 * pi / 180),
            //       child: Divider(),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
