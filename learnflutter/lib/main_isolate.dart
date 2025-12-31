import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/component/shimmer/shimmer_utils/shimmer_utils.dart';
import 'package:learnflutter/component/shimmer/widget/shimmer_loading_widget.dart';
import 'package:learnflutter/component/shimmer/widget/shimmer_widget.dart';
import 'package:learnflutter/core/isolate/api_service.dart';
import 'package:learnflutter/core/isolate/json_parse.dart';
import 'package:learnflutter/modules/animation/widget/list_view_animation.dart';

class IsolateJsonParsingScreen extends StatefulWidget {
  @override
  _IsolateJsonParsingScreenState createState() => _IsolateJsonParsingScreenState();
}

class _IsolateJsonParsingScreenState extends State<IsolateJsonParsingScreen> {
  final ApiService apiService = ApiService('https://jsonplaceholder.typicode.com/posts');
  final StreamController<List<dynamic>> _controller = StreamController<List<dynamic>>.broadcast();
  Stream<dynamic> parsedItemsStream = Stream.empty();
  List receivedItems = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    // Gọi API và parse JSON bằng Isolate
    final rawJson = await apiService.fetchDataFromApi();
    parseJson(rawJson).listen(
      (event) async {
        // receivedItems.add(event); // Lưu lại item đã nhận
        _controller.add(event);
      },
    );
    isLoading = false;

    // int index = 0;
    // parsedItemsStream.listen((item) {
    //   // index++;
    //   print(index++);
    //   // Xử lý từng item nhận được từ stream
    //   log('Received item: $item');
    //   _controller.add(item);
    // }, onDone: () {
    //   // Khi stream hoàn thành
    //   log('Stream completed');
    // }, onError: (error) {
    //   // Xử lý lỗi nếu có
    //   log('Error: $error');
    // });
    // setState(() {
    //   parsedItemsStream = parseJson(rawJson);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Reload data when button is pressed
          loadData();
        },
        child: Icon(Icons.refresh),
      ),
      child: StreamBuilder<List<dynamic>>(
        stream: _controller.stream,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          // return ListViewAnimated(
          //   fullData: receivedItems,
          // );
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Đang tải dữ liệu
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Nếu có lỗi
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            // if (snapshot.hasData) {
            //   receivedItems.add(snapshot.data!); // Lưu lại item đã nhận
            // }
            return ListViewAnimated(
              fullData: snapshot.data,
            );
            // Nếu có dữ liệu
          } else {
            // Kết thúc stream
            return Center(child: Text('No more items'));
          }
        },
      ),
    );
  }
}
