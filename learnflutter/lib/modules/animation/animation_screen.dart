// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:learnflutter/core/extension/extension_context.dart';
import 'package:learnflutter/modules/animation/widget/icon_animation_widget.dart';
import 'package:learnflutter/modules/animation/widget/ripple_animation_widget.dart';
import 'package:learnflutter/modules/draggbel_scroll/draggel_scroll_screen.dart';
import 'package:learnflutter/modules/material_segmented/material_segmented_screen.dart';
import 'package:learnflutter/modules/number_formart/number_format_screen.dart';
import 'package:learnflutter/modules/slider_vertical/slider_vertical_screen.dart';

class TransitionsHomePage extends StatefulWidget {
  @override
  TransitionsHomePageState createState() => TransitionsHomePageState();
}

class TransitionsHomePageState extends State<TransitionsHomePage> {
  bool _slowAnimations = false;
  double turns = 0.0;

  void _changeRotation() {
    setState(() => turns += 1.0 / 8.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Material Transitions'), actions: [
        GestureDetector(
          onTap: () {
            print('object');
          },
          child: const SizedBox(
              height: 50,
              width: 50,
              child: IconAnimationWidget(
                icon: Icons.shopping_cart_outlined,
              )),
        )
      ]),
      body: Column(
        children: <Widget>[
          const SizedBox(height: 50, width: 50, child: IconAnimationWidget()),
          const SizedBox(
              height: 50,
              width: 50,
              child: IconAnimationWidget(
                isRotate: true,
              )),
          const RippleAnimationWidget(),
          Draggable(
            data: 'colors',
            feedback: Container(
              width: context.mediaQuery.size.width / 2,
              height: 100,
              color: Colors.red,
            ),
            onDragStarted: () {},
            childWhenDragging: Container(),
            child: DragTarget(
              builder: (context, candidateData, rejectedData) {
                return Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    width: context.mediaQuery.size.width / 2,
                    height: 100,
                    color: Colors.red,
                  ),
                );
              },
              onWillAcceptWithDetails: (details) {
                return true;
              },
              onAcceptWithDetails: (details) {},
            ),
          ),
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  print('object');
                },
                child: Container(
                  width: context.mediaQuery.size.width / 2,
                  height: 100,
                  color: Colors.yellow,
                ),
              ),
              GestureDetector(
                onTap: () {
                  print('object');
                },
                child: Container(
                  width: context.mediaQuery.size.width / 2,
                  height: 50,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              children: <Widget>[
                _TransitionListTile(
                  title: 'Shared axis',
                  subtitle: 'SharedAxisTransition',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) {
                          return const SliderVerticalScreen();
                        },
                      ),
                    );
                  },
                ),
                _TransitionListTile(
                  title: 'Fade through',
                  subtitle: 'FadeThroughTransition',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) {
                          return const MaterialSegmentedScreen();
                        },
                      ),
                    );
                  },
                ),
                _TransitionListTile(
                  title: 'Fade',
                  subtitle: 'FadeScaleTransition',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) {
                          return const DraggbleScrollScreen();
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 0.0),
          SafeArea(
            child: SwitchListTile(
              value: _slowAnimations,
              onChanged: (bool value) async {
                setState(() {
                  _slowAnimations = value;
                });
                // Wait until the Switch is done animating before actually slowing
                // down time.
                if (_slowAnimations) {
                  await Future<void>.delayed(const Duration(milliseconds: 300));
                }
                timeDilation = _slowAnimations ? 20.0 : 1.0;
              },
              title: const Text('Slow animations'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransitionListTile extends StatelessWidget {
  const _TransitionListTile({
    this.onTap,
    required this.title,
    required this.subtitle,
  });

  final GestureTapCallback? onTap;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15.0,
      ),
      leading: Container(
        width: 40.0,
        height: 40.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: Colors.black54,
          ),
        ),
        child: const Icon(
          Icons.play_arrow,
          size: 35,
        ),
      ),
      onTap: onTap,
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}
