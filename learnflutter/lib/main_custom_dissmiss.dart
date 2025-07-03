import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnimationDismissCupertinoModalPopupExample extends StatefulWidget {
  @override
  _AnimationDismissCupertinoModalPopupExampleState createState() =>
      _AnimationDismissCupertinoModalPopupExampleState();
}

class _AnimationDismissCupertinoModalPopupExampleState
    extends State<AnimationDismissCupertinoModalPopupExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize AnimationController
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // Animation duration
    );

    // Define scale animation (shrinking effect)
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Start the animation after a delay
    Future.delayed(const Duration(seconds: 10), () {
      _controller.forward(); // Start shrinking animation
    });

    // Dismiss modal when animation completes
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).pop(); // Close the modal
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Build the modal content
  Widget _buildModalContent() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: CupertinoActionSheet(
        title: const Text('Auto Dismiss with Animation'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              print("Action Clicked!");
            },
            child: const Text('Action 1'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cupertino Modal with Animation')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showCupertinoModalPopup(
              context: context,
              builder: (BuildContext context) {
                return _buildModalContent();
              },
            );
          },
          child: const Text('Show Animated Dismiss Popup'),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: AnimationDismissCupertinoModalPopupExample()));
}
