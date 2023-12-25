// ignore_for_file: prefer_const_constructors

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MatrixScreen extends StatefulWidget {
  const MatrixScreen({super.key});

  @override
  State<MatrixScreen> createState() => _MatrixScreenState();
}

class _MatrixScreenState extends State<MatrixScreen> {
  int _couter = 0;
  double _rx = 0.0, _ry = 0.0, _rz = 0.0;
  void _incrementCouter() {
    setState(() {
      _couter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('rx : $_rx, ry : $_ry , rz:$_rz');
    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.white,
          child: GestureDetector(
            onPanUpdate: (details) {
              _rx += details.delta.dx * 0.01;
              _ry += details.delta.dy * 0.01;
              setState(() {
                _rx %= pi * 2;
                _ry %= pi * 2;
                _rz %= pi * 2;
              });
            },
            // onTap: () {
            //   setState(() {
            //     _rx = Random().nextDouble();
            //     _ry = Random().nextDouble();
            //     _rz = Random().nextDouble();
            //   });
            // },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateX(_ry)
                    ..rotateY(_rx)
                    ..rotateZ(_rz),
                  child: Center(child: Cube()),
                ),
                SizedBox(height: 32),
                Slider(
                  value: _rx,
                  min: pi * -2,
                  max: pi * 2,
                  onChanged: (value) {
                    setState(() {
                      _rx = value;
                    });
                  },
                ),
                Slider(
                  value: _ry,
                  min: pi * -2,
                  max: pi * 2,
                  onChanged: (value) {
                    setState(() {
                      _ry = value;
                    });
                  },
                ),
                Slider(
                  value: _rz,
                  min: pi * -2,
                  max: pi * 2,
                  onChanged: (value) {
                    setState(() {
                      _rz = value;
                    });
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Cube extends StatelessWidget {
  const Cube({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Transform(
          //PORT 3
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translate(-100.0, 0.0, 0.0)
            ..rotateY(-pi / 2),
          child: Container(
              width: 200,
              height: 200,
              color: Colors.purple,
              child: Center(
                child: Image(
                  image: NetworkImage('https://istorage.fpt.vn/v2/big-upload/istorage/Map/180/202308/image/0/Map_1693277203635_9d761d059fb99a5dcffaf5ea28eb0ee6_646793.jpg'),
                ),
              )),
        ),
        Transform(
          //starboard 2
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translate(100.0, 0.0, 0.0)
            ..rotateY(pi / 2),
          child: Container(
              width: 200,
              height: 200,
              color: Colors.orange,
              child: Center(
                child: Image(
                  image: NetworkImage('https://istorage.fpt.vn/v2/big-upload/istorage/Map/180/202308/image/0/Map_1693277203343_435385fa021573f31f986ad649309e43_428280.jpg'),
                ),
              )),
        ),
        Transform(
          // FORNT 1
          transform: Matrix4.identity()..translate(0.0, 0.0, -100.0),
          alignment: Alignment.center,
          child: Container(
              width: 200,
              height: 200,
              color: Colors.red,
              child: Center(
                child: Image(
                  image: NetworkImage('https://istorage.fpt.vn/v2/big-upload/istorage/Map/180/202308/image/0/Map_1693277202570_45c69497968fb655673fe5167863250d_763520.jpg'),
                ),
              )),
        ),
        Transform(
          //BACK 4
          alignment: Alignment.center,
          transform: Matrix4.identity()..translate(0.0, 0.0, 100.0),
          child: Container(
              width: 200,
              height: 200,
              color: Colors.blue,
              child: Center(
                child: Image(
                  image: NetworkImage('https://istorage.fpt.vn/v2/big-upload/istorage/Map/180/202308/image/0/Map_1693277206068_80075bbf7ff569987318b936c3034020_123463.jpg'),
                ),
              )),
        ),
        Transform(
          // 5
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translate(0.0, 100.0, 0.0)
            ..rotateX(pi / 2),
          child: Container(
              width: 200,
              height: 200,
              color: Colors.yellow,
              child: Center(
                child: Image(
                  image: NetworkImage('https://istorage.fpt.vn/v2/big-upload/istorage/Map/180/202308/image/0/Map_1693277205747_f6f22e36cd5ff81f644bbfd748824cf9_676080.jpg'),
                ),
              )),
        ),
        Transform(
          // TOP 6
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translate(0.0, -100.0, 0.0)
            ..rotateX(pi / 2),
          child: Container(
              width: 200,
              height: 200,
              color: Colors.pink,
              child: Center(
                child: Image(
                  image: NetworkImage('https://istorage.fpt.vn/v2/big-upload/istorage/Map/180/202308/image/0/Map_1693277205325_ba9d3b34ef5dcf40a3e338b032b63d17_654209.jpg'),
                ),
              )),
        ),
      ],
    );
  }
}
