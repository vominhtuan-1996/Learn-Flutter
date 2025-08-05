import 'package:flutter/material.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/component/routes/route.dart';
import 'package:learnflutter/modules/material/component/material_lists/model/router_model.dart';
import 'package:learnflutter/utils_helper/extension/extension_string.dart';
import 'package:learnflutter/utils_helper/extension/extension_widget.dart';

class ScrollPhysicScreen extends StatefulWidget {
  const ScrollPhysicScreen({super.key});

  @override
  State<ScrollPhysicScreen> createState() => _ScrollPhysicScreenState();
}

class _ScrollPhysicScreenState extends State<ScrollPhysicScreen> {
  final List<RouterModel> _scrollPhysicExampleRouter = [
    RouterModel(
      title: "Luôn bật bounce kể cả khi không cần thiết",
      router: Routes.alwaysBounceScrollPhysicsExample,
    ),
    RouterModel(
      title: "  Vô hiệu hóa scroll hoàn toàn",
      router: Routes.noScrollPhysicExample,
    ),
    RouterModel(
      title: "noBounceScrollPhysicsExample",
      router: Routes.noBounceScrollPhysicsExample,
    ),
    RouterModel(
      title: "Cuộn ngược lại so với direction gốc",
      router: Routes.reversedScrollPhysicsExample,
    ),
    RouterModel(
      title: "RubberBandScrollPhysics",
      router: Routes.rubberBandScrollPhysicsExample,
    ),
    RouterModel(
      title: "slow down the scroll speed in a ListView.",
      router: Routes.slowDownScrollPhysicsExample,
    ),
    RouterModel(
      title: "Cuộn và snap lại theo 1 đơn vị chiều cao cố định (ví dụ item height)",
      router: Routes.snappingScrollPhysicsExample,
    ),
    RouterModel(
      title: "Tạo hiệu ứng bật về khi kéo quá giới hạn cuộn",
      router: Routes.rubberSpringBackPhysicsExample,
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return BaseLoading(
        child: Column(
      children: List.generate(
        _scrollPhysicExampleRouter.length,
        (index) {
          return TextButton(
            onPressed: () {
              Navigator.pushNamed(context, _scrollPhysicExampleRouter[index].router);
            },
            child: Text(_scrollPhysicExampleRouter[index].title).highlightText(
              texthighlight: "Cuộn",
              highlightStyle: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                backgroundColor: Colors.yellow.withOpacity(0.3),
              ),
            ),
          );
        },
      ),
    ));
  }
}
