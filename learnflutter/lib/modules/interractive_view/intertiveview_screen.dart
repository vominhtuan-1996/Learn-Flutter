import 'package:flutter/material.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';

class InteractiveViewerExample extends StatelessWidget {
  const InteractiveViewerExample({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      child: Center(
        child: InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(20.0),
          minScale: 1,
          maxScale: 10,
          child: Container(
            child: Center(
                child: Image.network(
                    'https://images.unsplash.com/photo-1520342868574-5fa3804e551c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=6ff92caffcdd63681a35134a6770ed3b&auto=format&fit=crop&w=1951&q=80',
                    fit: BoxFit.cover,
                    height: double.infinity,
                    width: double.infinity)),
          ),
        ),
      ),
    );
  }
}
