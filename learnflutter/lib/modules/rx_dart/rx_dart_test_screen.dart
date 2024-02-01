import 'package:flutter/material.dart';

class RxDartScreen extends StatefulWidget {
  const RxDartScreen({super.key});
  @override
  State<RxDartScreen> createState() => RxDartScreenState();
}

class RxDartScreenState extends State<RxDartScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Stream<int> firstStream() async* {
    await Future.delayed(Duration(seconds: 1)); // 1s sau sẽ emit event đầu tiên
    yield 20; // emit 20 vào giây thứ 1
    await Future.delayed(Duration(seconds: 1)); // nghỉ 1 giây
    yield 40; // emit 40 vào giây thứ 2
    await Future.delayed(Duration(seconds: 2));
    yield 60; // emit 60 vào giây thứ 4
    await Future.delayed(Duration(seconds: 6));
    yield 80; // emit 80 vào giây thứ 10
    await Future.delayed(Duration(seconds: 3));
    yield 100; // emit 100 vào giây thứ 13
  }

// stream 2
  Stream<int> secondStream() async* {
    await Future.delayed(Duration(seconds: 7)); // sau 7s sẽ emit event đầu tiên
    yield 1;
    await Future.delayed(Duration(seconds: 9));
    yield 1;
  }

// mình sử dụng hàm println này để in kèm thời điểm emit event cho dễ quan sát output
  void println(Object value, DateTime currentTime) {
    print('Emit $value vào giây thứ ${DateTime.now().difference(currentTime).inSeconds}');
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
