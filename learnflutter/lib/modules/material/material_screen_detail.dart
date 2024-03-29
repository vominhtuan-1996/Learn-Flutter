import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learnflutter/base_loading_screen/base_loading.dart';
import 'package:learnflutter/modules/material/component/component_material_mixi.dart';
import 'package:learnflutter/modules/shimmer/shimmer_utils/shimmer_utils.dart';
import 'package:learnflutter/modules/shimmer/widget/shimmer_loading_widget.dart';
import 'package:learnflutter/modules/shimmer/widget/shimmer_widget.dart';

class MaterialScreenDetail extends StatefulWidget {
  const MaterialScreenDetail({super.key, required this.contentWidget, this.title, this.description});
  final Widget contentWidget;
  final String? title;
  final String? description;
  @override
  State<MaterialScreenDetail> createState() => MaterialScreenDetailState();
}

class MaterialScreenDetailState extends State<MaterialScreenDetail> with ComponentMaterialDetail {
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
    return BaseLoading(
        child: SingleChildScrollView(
      child: Column(
        children: [
          headerContentView(
            context: context,
            title: widget.title,
            description: widget.description,
          ),
          widget.contentWidget,
        ],
      ),
    ));
  }
}
