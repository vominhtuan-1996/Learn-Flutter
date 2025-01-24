import 'package:flutter/material.dart';
import 'package:learnflutter/app/device_dimension.dart';
import 'package:learnflutter/modules/material/component/component_material_mixi.dart';
import 'package:learnflutter/modules/material/component/metarial_radio_button/metarial_radio_button.dart';
import 'package:learnflutter/modules/material/component/metarial_radio_button/radio_item_model.dart';
import 'package:learnflutter/modules/material/material_screen.dart';
import 'package:learnflutter/modules/material/material_screen_detail.dart';
import 'package:learnflutter/utils_helper/extension/extension_list.dart';

class MaterialRaidoButtonScreen extends StatefulWidget {
  const MaterialRaidoButtonScreen({super.key, required this.data, this.enable = true});
  final RouterMaterialModel data;
  final bool enable;
  @override
  State<MaterialRaidoButtonScreen> createState() => _MaterialRaidoButtonScreenState();
}

class _MaterialRaidoButtonScreenState extends State<MaterialRaidoButtonScreen> with ComponentMaterialDetail {
  String initialValue = "";
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
          children: [
            Text("Radio Button Single"),
            MetarialRadioButton.single(
              enable: widget.enable,
              data: [
                RadioItemModel(title: "Radio 1", id: "1", isSelected: true),
                RadioItemModel(title: "Radio 2", id: "2", isSelected: false),
                RadioItemModel(title: "Radio 3", id: "3", isSelected: false),
                RadioItemModel(title: "Radio 4", id: "4", isSelected: false),
                RadioItemModel(title: "Radio 5", id: "5", isSelected: false),
                RadioItemModel(title: "Radio 6", id: "6", isSelected: false),
                RadioItemModel(title: "Radio 7", id: "7", isSelected: false),
                RadioItemModel(title: "Radio 8", id: "8", isSelected: false),
                RadioItemModel(title: "Radio 9", id: "9", isSelected: false),
                RadioItemModel(title: "Radio 10", id: "10", isSelected: false),
              ],
              onChangeValue: (value) {
                print(value?.title ?? "");
              },
            ),
            Text("Radio Button Multi"),
            MetarialRadioButton.mutiselect(
              enable: widget.enable,
              data: [
                RadioItemModel(title: "Radio 1", id: "1", isSelected: false),
                RadioItemModel(title: "Radio 2", id: "2", isSelected: false),
                RadioItemModel(title: "Radio 3", id: "3", isSelected: true),
                RadioItemModel(title: "Radio 4", id: "4", isSelected: false),
                RadioItemModel(title: "Radio 5", id: "5", isSelected: true),
                RadioItemModel(title: "Radio 6", id: "6", isSelected: false),
                RadioItemModel(title: "Radio 7", id: "7", isSelected: false),
                RadioItemModel(title: "Radio 8", id: "8", isSelected: true),
                RadioItemModel(title: "Radio 9", id: "9", isSelected: false),
                RadioItemModel(title: "Radio 10", id: "10", isSelected: false),
              ],
              onToggleValue: (items) {
                items?.forEachExtenstion((element) {
                  print(element.title);
                });
              },
            )
          ],
        ),
      ),
    );
  }
}
