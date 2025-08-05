import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';

class Flutter3dScreen extends StatefulWidget {
  const Flutter3dScreen({super.key});

  @override
  State<Flutter3dScreen> createState() => _Flutter3dScreenState();
}

class _Flutter3dScreenState extends State<Flutter3dScreen> {
  Flutter3DController controller = Flutter3DController();
  String? chosenAnimation;
  String? chosenTexture;
  bool changeModel = false;
  String srcObj = 'assets/flutter_dash.obj';
  String srcGlb = 'assets/3d/business_man.glb';

  @override
  void initState() {
    super.initState();
    controller.onModelLoaded.addListener(() {
      debugPrint('model is loaded : ${controller.onModelLoaded.value}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      child: Flutter3DViewer(
        //If you pass 'true' the flutter_3d_controller will add gesture interceptor layer
        //to prevent gesture recognizers from malfunctioning on iOS and some Android devices.
        // the default value is true.
        activeGestureInterceptor: true,
        //If you don't pass progressBarColor, the color of defaultLoadingProgressBar will be grey.
        //You can set your custom color or use [Colors.transparent] for hiding loadingProgressBar.
        progressBarColor: Colors.orange,
        //You can disable viewer touch response by setting 'enableTouch' to 'false'
        enableTouch: true,
        //This callBack will return the loading progress value between 0 and 1.0
        onProgress: (double progressValue) {
          debugPrint('model loading progress : $progressValue');
        },
        //This callBack will call after model loaded successfully and will return model address
        onLoad: (String modelAddress) {
          debugPrint('model loaded : $modelAddress');
          controller.playAnimation();
        },
        //this callBack will call when model failed to load and will return failure error
        onError: (String error) {
          debugPrint('model failed to load : $error');
        },

        //You can have full control of 3d model animations, textures and camera
        controller: controller,
        src: srcGlb,
        //src: 'assets/business_man.glb', //3D model with different animations
        //src: 'assets/sheen_chair.glb', //3D model with different textures
        //src: 'https://modelviewer.dev/shared-assets/models/Astronaut.glb', // 3D model from URL
      ),
    );
  }
}
