import 'package:flutter/material.dart';
import 'package:learnflutter/core/app/device_dimension.dart';
import 'package:learnflutter/component/tap_builder/tap_animated_button_builder.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';
import 'package:learnflutter/modules/material/component/component_material_mixi.dart';
import 'package:learnflutter/modules/material/component/metarial_card/horizontal_card_widget.dart';
import 'package:learnflutter/modules/material/component/meterial_button_3/material_button_3.dart';
import 'package:learnflutter/modules/material/material_screen.dart';
import 'package:learnflutter/modules/material/material_screen_detail.dart';
import 'package:learnflutter/core/app/app_colors.dart';

class MaterialCardDetail extends StatefulWidget {
  const MaterialCardDetail({super.key, required this.data});
  final RouterMaterialModel data;
  @override
  State<MaterialCardDetail> createState() => _MaterialCardDetailState();
}

class _MaterialCardDetailState extends State<MaterialCardDetail> with ComponentMaterialDetail {
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  3,
                  (index) {
                    return AnimatedTapButtonBuilder(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.purple, width: 2.0),
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFCFD4FF).withOpacity(0.06),
                              spreadRadius: 2,
                              blurRadius: 2,
                              offset: const Offset(-3, 3),
                            ),
                          ],
                        ),
                        width: context.mediaQuery.size.width - DeviceDimension.padding * 2,
                        // height: context.mediaQuery.size.width - DeviceDimension.padding * 2,
                        child: Column(
                          children: [
                            Container(
                              color: Colors.white,
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: DeviceDimension.padding,
                                    vertical: DeviceDimension.padding / 2),
                                leading: const CircleAvatar(
                                  backgroundColor: Colors.purple,
                                  child: Text(
                                    'A',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(
                                  'Header',
                                  style: context.textTheme.bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text('Subhead', style: context.textTheme.bodyMedium),
                                trailing: const Icon(Icons.more_vert_sharp),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFCFD4FF).withOpacity(0.06),
                                    spreadRadius: 2,
                                    blurRadius: 2,
                                    offset: const Offset(-3, 3),
                                  ),
                                ],
                              ),
                              child: SizedBox(
                                width: context.mediaQuery.size.width - DeviceDimension.padding * 2,
                                height:
                                    context.mediaQuery.size.width / 2 - DeviceDimension.padding * 2,
                              ),
                            ),
                            Container(
                              color: Colors.white,
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: DeviceDimension.padding,
                                    vertical: DeviceDimension.padding / 2),
                                title: Text(
                                  'Title',
                                  style: context.textTheme.bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text('Subhead', style: context.textTheme.bodyMedium),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: DeviceDimension.padding,
                                  vertical: DeviceDimension.padding / 2),
                              color: Colors.white,
                              child: const Text(
                                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor'),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: DeviceDimension.padding,
                                  vertical: DeviceDimension.padding / 2),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  MaterialButton3(
                                    disible: false,
                                    backgoundColor: Colors.white,
                                    borderColor: Colors.grey,
                                    borderRadius: DeviceDimension.padding,
                                    shadowColor: AppColors.grey,
                                    shadowOffset: Offset.zero,
                                    textAlign: TextAlign.center,
                                    onTap: () async {
                                      print('object');
                                    },
                                    type: MaterialButtonType.commonbutton,
                                    lableText: 'Enabled',
                                    labelTextStyle: context.textTheme.bodyMedium
                                        ?.copyWith(color: context.theme.colorScheme.onPrimary),
                                  ),
                                  SizedBox(
                                    width: DeviceDimension.padding,
                                  ),
                                  MaterialButton3(
                                    disible: false,
                                    backgoundColor: Colors.purple,
                                    borderColor: Colors.grey,
                                    borderRadius: DeviceDimension.padding,
                                    shadowColor: AppColors.grey,
                                    shadowOffset: Offset.zero,
                                    textAlign: TextAlign.center,
                                    onTap: () async {
                                      print('object');
                                    },
                                    type: MaterialButtonType.commonbutton,
                                    lableText: 'Enabled',
                                    labelTextStyle: context.textTheme.bodyMedium
                                        ?.copyWith(color: context.theme.colorScheme.primary),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  3,
                  (index) {
                    return const HozizantalCardWidget();
                  },
                ),
              ),
            ),
            SizedBox(
              height: DeviceDimension.padding,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: DeviceDimension.padding / 2),
              child: const Text('Building blocks'),
            ),
            SizedBox(
              height: context.mediaQuery.size.height / 2,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Số lượng cột trong grid
                  crossAxisSpacing: 10.0, // Khoảng cách ngang giữa các ô
                  mainAxisSpacing: 10.0, // Khoảng cách dọc giữa các ô
                ),
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      border: Border.all(color: Colors.grey, width: 1.0),
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFCFD4FF).withOpacity(0.06),
                          spreadRadius: 2,
                          blurRadius: 2,
                          offset: const Offset(-3, 3),
                        ),
                      ],
                    ),
                    child: const SizedBox.shrink(),
                  );
                },
              ),
            ),
            SizedBox(
              height: DeviceDimension.padding,
            ),
          ],
        ),
      ),
    );
  }
}
