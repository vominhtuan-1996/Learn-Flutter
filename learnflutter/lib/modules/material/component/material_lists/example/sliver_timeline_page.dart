import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:learnflutter/modules/material/component/material_lists/widgets/sliver_timeline.dart';

class SliverTimelinePage extends StatelessWidget {
  const SliverTimelinePage();

  @override
  Widget build(BuildContext context) {
    final entries = _mockTimelineEntries();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Lịch sử sự kiện'),
            ),
          ),
          SliverTimelineView(entries: entries),
        ],
      ),
    );
  }

  List<TimelineEntry> _mockTimelineEntries() {
    final now = DateTime.now();
    return List.generate(12, (i) {
      final date = now.subtract(Duration(days: i ~/ 3, hours: i * 2));
      return TimelineEntry(
        title: 'Sự kiện ${i + 1}',
        description: 'Chi tiết cho sự kiện số ${i + 1} diễn ra vào ${DateFormat.Hm().format(date)}',
        date: date,
      );
    });
  }
}
