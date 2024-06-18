import 'package:flutter/material.dart';
import 'package:learnflutter/core/device_dimension.dart';
import 'package:learnflutter/core/extension/extension_context.dart';

class HozizantalCardWidget extends StatelessWidget {
  const HozizantalCardWidget({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.mediaQuery.size.width - DeviceDimension.padding * 2,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: DeviceDimension.padding, vertical: DeviceDimension.padding / 2),
          leading: const CircleAvatar(
            backgroundColor: Colors.purple,
            child: Text(
              'A',
              style: TextStyle(color: Colors.white),
            ),
          ),
          title: Text(
            'Header',
            style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('Subhead', style: context.textTheme.bodyMedium),
          trailing: Icon(Icons.more_vert_sharp),
        ),
      ),
    );
  }
}
