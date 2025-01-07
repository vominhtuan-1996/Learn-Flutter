import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learnflutter/app/device_dimension.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';
import 'package:learnflutter/modules/material/component/component_material_mixi.dart';
import 'package:learnflutter/modules/material/component/material_checkbox/material_checkbox.dart';
import 'package:learnflutter/modules/material/component/metarial_card/horizontal_card_widget.dart';
import 'package:learnflutter/modules/material/component/meterial_button_3/material_button_3.dart';
import 'package:learnflutter/modules/material/material_screen.dart';
import 'package:learnflutter/modules/material/material_screen_detail.dart';
import 'package:learnflutter/app/app_colors.dart';

class MaterialCheckBoxDetail extends StatefulWidget {
  const MaterialCheckBoxDetail({super.key, required this.data});
  final RoouterMaterialModel data;
  @override
  State<MaterialCheckBoxDetail> createState() => _MaterialCheckBoxDetailState();
}

class _MaterialCheckBoxDetailState extends State<MaterialCheckBoxDetail> with ComponentMaterialDetail {
  bool value = false;
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
        child: Center(
          child: Container(
            height: 300,
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 5,
              children: List.generate(
                25,
                (index) {
                  if (index % 5 == 0) {
                    return MaterialCheckBox(
                      scale: 1.2,
                      isChecked: value,
                      onChangedCheck: (value) {
                        value = value;
                        setState(() {});
                      },
                      fillColor: Colors.red,
                      disible: false,
                      checkedColor: Colors.black, borderColor: Colors.transparent,

                      // value: value,
                      // onChanged: (bool? value) {
                      //   value = value;
                      //   setState(() {});
                      // },
                      // activeColor: Colors.red,
                      // checkColor: Colors.white,
                    );
                  } else if (index % 5 == 1) {
                    return Checkbox.adaptive(
                      value: value,
                      onChanged: (bool? value) {
                        setState(() {
                          value = value;
                        });
                      },
                      activeColor: Colors.grey,
                      checkColor: Colors.red,
                    );
                  } else if (index % 5 == 2) {
                    return Icon(
                      Icons.remove,
                      color: index % 10 == 2 ? Colors.purple : Colors.red,
                    );
                  } else if (index % 5 == 3) {
                    return Checkbox(
                      value: value,
                      onChanged: (bool? value) {
                        setState(() {
                          value = value;
                        });
                      },
                      activeColor: Colors.purple,
                      checkColor: Colors.white,
                    );
                  } else {
                    return Checkbox(
                      value: value,
                      onChanged: (bool? value) {
                        setState(() {
                          value = value;
                        });
                      },
                      activeColor: Colors.red[300],
                      checkColor: Colors.black,
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
