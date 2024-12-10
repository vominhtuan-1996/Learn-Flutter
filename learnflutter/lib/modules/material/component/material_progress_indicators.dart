import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learnflutter/core/device_dimension.dart';
import 'package:learnflutter/core/extension/extension_context.dart';
import 'package:learnflutter/modules/material/component/component_material_mixi.dart';
import 'package:learnflutter/modules/material/component/meterial_button_3/material_button_3.dart';
import 'package:learnflutter/modules/material/material_screen.dart';
import 'package:learnflutter/modules/material/material_screen_detail.dart';
import 'package:learnflutter/modules/slider_vertical/progess_bar_custom.dart';
import 'package:learnflutter/src/app_colors.dart';

class MaterialProgressIndicators extends StatefulWidget {
  const MaterialProgressIndicators({super.key, required this.data});
  final RoouterMaterialModel data;
  @override
  State<MaterialProgressIndicators> createState() => _MaterialProgressIndicatorsState();
}

class _MaterialProgressIndicatorsState extends State<MaterialProgressIndicators> with ComponentMaterialDetail, TickerProviderStateMixin {
  late AnimationController controllerLiner;
  bool stopAnimationLiner = false;
  late AnimationController controllerDeterminate;
  bool determinate = false;

  late AnimationController controllerCircle;
  bool stopAnimationCircle = false;
  @override
  void initState() {
    controllerLiner = AnimationController(
      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
        setState(() {});
      });
    controllerLiner.repeat(reverse: true);

    controllerDeterminate = AnimationController(
      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        setState(() {});
      });
    controllerDeterminate.repeat();

    controllerCircle = AnimationController(
      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
        setState(() {});
      });
    controllerCircle.repeat(reverse: true);
    super.initState();
  }

  @override
  void dispose() {
    controllerLiner.dispose();
    controllerCircle.dispose();
    controllerDeterminate.dispose();
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
            Text(
              'Liner',
              style: context.textTheme.headlineMedium,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: DeviceDimension.padding, horizontal: DeviceDimension.padding),
              child: LinearProgressIndicator(
                minHeight: 20,
                value: controllerLiner.value,
                semanticsLabel: 'Liner',
                borderRadius: BorderRadius.all(Radius.circular(DeviceDimension.padding / 2)),
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Liner Progress',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                CupertinoSwitch(
                  value: stopAnimationLiner,
                  onChanged: (bool value) {
                    setState(() {
                      stopAnimationLiner = value;
                      if (stopAnimationLiner) {
                        controllerLiner.stop();
                      } else {
                        controllerLiner
                          ..forward(from: controllerLiner.value)
                          ..repeat();
                      }
                    });
                  },
                ),
              ],
            ),
            Text(
              'Determinate',
              style: context.textTheme.headlineMedium,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: DeviceDimension.padding, horizontal: DeviceDimension.padding),
              child: LinearProgressIndicator(
                minHeight: 30,
                value: controllerDeterminate.value,
                borderRadius: BorderRadius.all(Radius.circular(DeviceDimension.padding / 2)),
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Determinate Model',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                CupertinoSwitch(
                  value: determinate,
                  onChanged: (bool value) {
                    setState(() {
                      determinate = value;
                      if (determinate) {
                        controllerDeterminate.stop();
                      } else {
                        controllerDeterminate
                          ..forward(from: controllerDeterminate.value)
                          ..repeat();
                      }
                    });
                  },
                ),
              ],
            ),
            Text(
              'Circular',
              style: context.textTheme.headlineMedium,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: DeviceDimension.padding, horizontal: DeviceDimension.padding),
              child: CircularProgressIndicator(
                value: controllerCircle.value,
                strokeCap: StrokeCap.round,
                strokeWidth: 20,
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Determinate Model',
                    style: context.textTheme.titleSmall,
                  ),
                ),
                CupertinoSwitch(
                  value: stopAnimationCircle,
                  onChanged: (bool value) {
                    setState(() {
                      stopAnimationCircle = value;
                      if (stopAnimationCircle) {
                        controllerCircle.stop();
                      } else {
                        controllerCircle
                          ..forward(from: controllerCircle.value)
                          ..repeat();
                      }
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
