import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A single timeline entry data model.
class TimelineEntry {
  final String title;
  final String description;
  final DateTime date;

  const TimelineEntry({
    required this.title,
    required this.description,
    required this.date,
  });
}

/// A reusable sliver-based timeline view with optional date grouping.
class SliverTimelineView extends StatelessWidget {
  final List<TimelineEntry> entries;

  const SliverTimelineView({
    super.key,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final entry = entries[index];
          final isFirst = index == 0;
          final isLast = index == entries.length - 1;

          final bool showHeader = index == 0 || !_isSameDay(entry.date, entries[index - 1].date);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showHeader)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    DateFormat.yMMMMd().format(entry.date),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              TimelineItem(
                entry: entry,
                isFirst: isFirst,
                isLast: isLast,
              ),
            ],
          );
        },
        childCount: entries.length,
      ),
    );
  }
}

/// A single visual item in the timeline view.
class TimelineItem extends StatelessWidget {
  final TimelineEntry entry;
  final bool isFirst;
  final bool isLast;

  const TimelineItem({
    super.key,
    required this.entry,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline: dot + line
        SizedBox(
          width: 40,
          child: Column(
            children: [
              if (!isFirst) Container(height: 12, width: 2, color: Colors.grey),
              Icon(Icons.fiber_manual_record, size: 12, color: Colors.blue),
              if (!isLast) Container(height: 60, width: 2, color: Colors.grey),
            ],
          ),
        ),

        // Card content
        Expanded(
          child: Card(
            margin: const EdgeInsets.only(right: 16, bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(entry.description),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat.Hm().format(entry.date),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}

/// Check if two dates are on the same day.
bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
