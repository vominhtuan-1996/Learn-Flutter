import 'dart:ui';

import 'package:flutter/material.dart';

class DetailFileScreen extends StatefulWidget {
  const DetailFileScreen({super.key});

  @override
  State<DetailFileScreen> createState() => _DetailFileScreenState();
}

class _DetailFileScreenState extends State<DetailFileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(color: Colors.grey.shade200.withOpacity(0.5)),
            child: const Center(
              child: Text('Frosted'),
            ),
          ),
        ),
      ),
    );
  }
}
