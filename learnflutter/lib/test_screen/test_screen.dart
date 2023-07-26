import 'package:flutter/material.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/nested_scroll_screen');
              },
              child: const Text('nested_scroll_screen'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/courasel_screen');
              },
              child: const Text('courasel_screen'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/MenuController');
              },
              child: const Text('Menu'),
            )
          ],
        ),
      ),
    );
  }
}
