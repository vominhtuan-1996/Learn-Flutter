import 'package:flutter/material.dart';
import 'package:learnflutter/app/device_dimension.dart';
import 'package:learnflutter/src/lib/tap_builder/src/animated_tap_builder.dart';

import 'package:learnflutter/src/lib/tap_builder/src/tap_builder.dart';

import 'package:learnflutter/src/lib/tap_builder/src/tap_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TapBuilder',
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: StateButton(),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: DelayedPressedStateButton(),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: AnimatedStateButton(),
            ),
          ],
        ),
      ),
    );
  }
}

class StateButton extends StatelessWidget {
  const StateButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TapBuilder(
      onTap: () {},
      builder: (context, state, isFocused) => AnimatedContainer(
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 28,
        ),
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: Colors.white.withOpacity(isFocused ? 0.2 : 0.0),
            width: 2,
          ),
          color: () {
            switch (state) {
              case TapState.disabled:
                return Colors.grey;
              case TapState.hover:
                return const Color(0xFF0AAF97);
              case TapState.inactive:
                return const Color(0xFF00d1b2);
              case TapState.pressed:
                return const Color(0xFF0AAF97);
            }
          }(),
        ),
        child: const Text(
          'TapBuilder',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class AnimatedStateButton extends StatelessWidget {
  const AnimatedStateButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedTapBuilder(
      onTap: () {},
      builder: (context, state, isFocused, cursorLocation, cursorAlignment) {
        cursorAlignment = state == TapState.pressed ? Alignment(-cursorAlignment.x, -cursorAlignment.y) : Alignment.center;
        return Padding(
          padding: EdgeInsets.all(8),
          child: AnimatedContainer(
            transformAlignment: Alignment.center,
            transform: Matrix4.rotationX(-cursorAlignment.y * 0.2)
              ..rotateY(cursorAlignment.x * 0.2)
              ..scale(
                state == TapState.pressed ? 0.94 : 1.0,
              ),
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.black,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Stack(
                fit: StackFit.passthrough,
                children: [
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: state == TapState.pressed ? 0.6 : 0.8,
                    child: Image.network(
                      'https://images.unsplash.com/photo-1607030298395-ed979957b555?ixid=MXwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHwzMXx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60',
                      fit: BoxFit.contain,
                    ),
                  ),
                  // AnimatedContainer(
                  //   transformAlignment: Alignment.center,
                  //   transform: Matrix4.translationValues(
                  //     cursorAlignment.x * 3,
                  //     cursorAlignment.y * 3,
                  //     0,
                  //   ),
                  //   duration: const Duration(milliseconds: 200),
                  //   child: const Center(
                  //     child: Text(
                  //       'AnimatedTapBuilder',
                  //       style: TextStyle(
                  //         color: Colors.white,
                  //         fontWeight: FontWeight.bold,
                  //         fontSize: 30,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  Positioned.fill(
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      alignment: Alignment(-cursorAlignment.x, -cursorAlignment.y),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.01),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(state == TapState.pressed ? 0.5 : 0.0),
                              blurRadius: 200,
                              spreadRadius: 130,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class DelayedPressedStateButton extends StatelessWidget {
  const DelayedPressedStateButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TapBuilder(
      onTap: () {},
      minPressedDuration: const Duration(milliseconds: 500),
      hitTestBehavior: HitTestBehavior.translucent,
      builder: (context, state, isFocused) => AnimatedContainer(
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 28,
        ),
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: Colors.white.withOpacity(isFocused ? 0.2 : 0.0),
            width: 2,
          ),
          color: () {
            switch (state) {
              case TapState.disabled:
                return Colors.grey;
              case TapState.hover:
                return const Color(0xFF0AAF97);
              case TapState.inactive:
                return const Color(0xFF00d1b2);
              case TapState.pressed:
                return const Color(0xFF0AAF97);
            }
          }(),
        ),
        child: const Text(
          'TapBuilder with delayed press',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
