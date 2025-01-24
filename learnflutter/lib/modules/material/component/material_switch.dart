import 'package:flutter/material.dart';
import 'package:learnflutter/modules/material/component/component_material_mixi.dart';
import 'package:learnflutter/modules/material/material_screen.dart';
import 'package:learnflutter/modules/material/material_screen_detail.dart';

class MaterialSwitch extends StatefulWidget {
  const MaterialSwitch({super.key, required this.data});
  final RouterMaterialModel data;
  @override
  State<MaterialSwitch> createState() => _MaterialSwitchState();
}

class _MaterialSwitchState extends State<MaterialSwitch> with ComponentMaterialDetail {
  bool light = true;
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
              child: Wrap(
                children: List.generate(
                  16,
                  (index) {
                    return Switch(
                      value: light,
                      onChanged: (bool value) {
                        setState(() {
                          light = value;
                        });
                      },
                    );
                  },
                ),
              ),
            ),
            Card(
              child: Wrap(
                children: List.generate(
                  16,
                  (index) {
                    return AbsorbPointer(
                      absorbing: false,
                      child: Switch(
                        value: light,
                        onChanged: (bool value) {
                          setState(() {
                            light = value;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
