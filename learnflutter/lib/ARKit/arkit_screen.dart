// ignore_for_file: depend_on_referenced_packages, camel_case_types

import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math_64.dart';

class ARKitScreen extends StatefulWidget {
  const ARKitScreen({super.key});

  @override
  State<ARKitScreen> createState() => _aRKitScreenState();
}

class _aRKitScreenState extends State<ARKitScreen> {
  late ARKitController arkitController;

  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ARKitSceneView(onARKitViewCreated: onARKitViewCreated);
  }

  void onARKitViewCreated(ARKitController arkitController) {
    this.arkitController = arkitController;
    final node = ARKitNode(geometry: ARKitSphere(radius: 0.1), position: Vector3(0, 0, -0.5));
    final node1 = ARKitNode(geometry: ARKitSphere(radius: 0.2), position: Vector3(10, 10, -0.5));
    final node2 = ARKitNode(geometry: ARKitSphere(radius: 0.3), position: Vector3(20, 20, -0.5));
    final node3 = ARKitNode(geometry: ARKitSphere(radius: 0.4), position: Vector3(30, 30, -0.5));
    final node4 = ARKitNode(geometry: ARKitSphere(radius: 0.5), position: Vector3(40, 0, -0.5));
    final node5 = ARKitNode(geometry: ARKitSphere(radius: 0.6), position: Vector3(50, 0, -0.5));
    final node6 = ARKitNode(geometry: ARKitSphere(), position: Vector3(100, 100, -0.5));
    this.arkitController.add(node);
    this.arkitController.add(node1);
    this.arkitController.add(node2);
    this.arkitController.add(node3);
    this.arkitController.add(node4);
    this.arkitController.add(node5);
    this.arkitController.add(node6);
  }
}
