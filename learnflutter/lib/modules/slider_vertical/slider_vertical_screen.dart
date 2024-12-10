import 'package:flutter/material.dart';
import 'package:learnflutter/base_loading_screen/base_loading.dart';
import 'package:learnflutter/modules/slider_vertical/progess_bar_custom.dart';
import 'package:learnflutter/modules/slider_vertical/tab_render_widget.dart';

class SliderVerticalScreen extends StatefulWidget {
  const SliderVerticalScreen({super.key});
  @override
  State<SliderVerticalScreen> createState() => SliderVerticalScreenState();
}

class SliderVerticalScreenState extends State<SliderVerticalScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _sizeAnimation;
  var val = 5;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      lowerBound: 0.5,
      duration: Duration(milliseconds: 1500),
    )..reverse();

    _colorAnimation = ColorTween(begin: Colors.grey[400], end: Colors.red).animate(_controller);

    _sizeAnimation = TweenSequence(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween(begin: 50, end: 30),
          weight: 50,
        ),
        TweenSequenceItem<double>(
          tween: Tween(begin: 30, end: 50),
          weight: 50,
        )
      ],
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      appBar: AppBar(
        title: Text('Slider Vertical'),
      ),
      isLoading: false,
      child: Container(
        child: Transform(
          // Transform
          alignment: FractionalOffset.center,
          // Rotate sliders by 90 degrees
          transform: Matrix4.identity()..rotateZ(90 * 3.1415927 / 180),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: CurvedAnimation(parent: _controller, curve: Curves.decelerate),
                builder: (context, child) {
                  return ProgressBar(
                    barColor: Colors.blue,
                    thumbColor: Colors.red,
                    thumbSize: 20.0,
                  );
                },
              ),
              SizedBox(height: 50),
              Slider(
                value: val.toDouble(),
                min: 1.0,
                max: 50.0,
                divisions: 50,
                label: val.toString(),
                activeColor: Colors.blue,
                onChanged: (double newValue) {
                  setState(() {
                    val = newValue.round();
                  });
                },
              ),
              const TabRenderWidget(
                tabColor: Colors.yellow,
                thumbColor: Colors.red,
                thumbSize: 20.0,
              ),

              // Slider(
              //   value: val.toDouble(),
              //   min: 1.0,
              //   max: 50.0,
              //   divisions: 50,
              //   label: '$val',
              //   onChanged: (double newValue) {
              //     setState(() {
              //       val = newValue.round();
              //     });
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
