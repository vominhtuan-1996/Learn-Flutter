// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:learnflutter/core/custom_shape/custom_shape.dart';
import 'package:learnflutter/helpper/hero_animation/hero_utils/hero_animation_utils.dart';

class Page1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      alignment: Alignment.bottomCenter,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Page2()),
          );
        },
        child: Hero(
            tag: "profile-image",
            child: CircleAvatar(
              maxRadius: 100.0,
            )),
      ),
    ));
  }
}

class Page2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Hero(
      createRectTween: (begin, end) {
        // return MaterialRectArcTween(begin: begin, end: end);
        return CustomRectTween(begin: begin, end: end);
      },
      transitionOnUserGestures: true,
      tag: "profile-image",
      child: Container(
        margin: EdgeInsets.only(top: 80),
        height: 50,
        width: double.infinity,
        decoration: ShapeDecoration(
          shape: CustomShapeBorder(),
          //color: Colors.orange,
          gradient: LinearGradient(colors: [Colors.blue, Colors.orange]),
          shadows: [
            BoxShadow(color: Colors.black, offset: Offset(3, -3), blurRadius: 3),
          ],
        ),
      ),
    ));
  }
}
