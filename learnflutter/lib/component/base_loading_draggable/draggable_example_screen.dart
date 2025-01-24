import 'package:flutter/material.dart';
import 'package:learnflutter/app/device_dimension.dart';
import 'package:learnflutter/component/base_loading_draggable/base_draggable_loading.dart';
import 'package:learnflutter/core/global/func_global.dart';
import 'package:learnflutter/modules/material/component/meterial_button_3/material_button_3.dart';
import 'package:learnflutter/modules/popover/popover_scren.dart';

class DraggableExampleScreen extends StatefulWidget {
  const DraggableExampleScreen({super.key});
  @override
  State<DraggableExampleScreen> createState() => DraggableExampleScreenState();
}

class DraggableExampleScreenState extends State<DraggableExampleScreen> {
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
    return BaseDraggableLoading(
      floatSize: Size(128, 48),
      floatingActionButton: MaterialButton3.extended(
        prefixIcon: Icons.add,
        lableText: 'Dragg',
        // fabIcon: Icons.close,
        onPressed: () {
          showLoading(context: context, message: 'floatingActionButton: MaterialButton3.extended(');
        },
        // borderRadius: 72 / 2,
      ),
      hasDeletedWidget: true,
      autoAlign: false,
      isLoading: true,
      child: Container(color: Colors.white),
    );
  }
}
