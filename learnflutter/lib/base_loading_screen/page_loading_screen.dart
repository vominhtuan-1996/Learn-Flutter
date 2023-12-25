import 'package:flutter/material.dart';
import 'package:learnflutter/Helpper/utills_helpper.dart';
import 'package:learnflutter/base_loading_screen/base_loading.dart';
import 'package:learnflutter/matix/matix_screen.dart';
import 'package:learnflutter/src/app_box_decoration.dart';

class PageLoadingScreen extends StatefulWidget {
  PageLoadingScreen({
    super.key,
    this.isVisible = true,
    this.message = 'Loading...Loading...Loading...',
    this.styleMessage = const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
  });
  bool isVisible;
  String message;
  TextStyle? styleMessage;
  @override
  State<PageLoadingScreen> createState() => _PageLoadingScreenState();
}

class _PageLoadingScreenState extends State<PageLoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      isLoading: false, // widget.isVisible,
      message: widget.message,
      child: const MatrixScreen(),
    );
  }
}
