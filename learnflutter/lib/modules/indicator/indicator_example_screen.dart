import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/component/routes/route.dart';
import 'package:learnflutter/modules/material/component/material_lists/model/router_model.dart';
import 'package:learnflutter/src/lib/src/utils/utils.dart';

class IndicatorExampleScreen extends StatefulWidget {
  const IndicatorExampleScreen({super.key});

  @override
  State<IndicatorExampleScreen> createState() => _IndicatorExampleScreenState();
}

class _IndicatorExampleScreenState extends State<IndicatorExampleScreen> {
  final List<RouterModel> _indicatorsExampleRouter = [
    RouterModel(
      title: "dropWaterIndicator",
      router: Routes.dropWaterIndicator,
    ),
    RouterModel(
      title: "iceCreamIndicator",
      router: Routes.iceCreamIndicator,
    ),
    RouterModel(
      title: "fetchMoreIndicator",
      router: Routes.fetchMoreIndicator,
    ),
    RouterModel(
      title: "dropWaterLottieRefreshIndicator",
      router: Routes.dropWaterLottieRefreshIndicator,
    ),
    RouterModel(
      title: "arrowDownIndicator",
      router: Routes.arrowDownIndicator,
    ),
    RouterModel(
      title: "homeRefreshIndicator",
      router: Routes.homeRefreshIndicator,
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return BaseLoading(
        child: Column(
      children: List.generate(
        _indicatorsExampleRouter.length,
        (index) {
          return TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, _indicatorsExampleRouter[index].router);
                  },
                  child: Text(_indicatorsExampleRouter[index].title))
              .paddingSymmetric(vertical: 5);
        },
      ),
    ));
  }
}
