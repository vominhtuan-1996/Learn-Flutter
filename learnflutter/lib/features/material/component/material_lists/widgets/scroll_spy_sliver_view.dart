import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ScrollSpySection {
  final String title;
  final Widget content;

  ScrollSpySection({required this.title, required this.content});
}

class ScrollSpySliverView extends StatefulWidget {
  final List<ScrollSpySection> sections;
  final double sectionPadding;
  final TextStyle? sidebarTextStyle;
  final TextStyle? activeTextStyle;

  const ScrollSpySliverView({
    super.key,
    required this.sections,
    this.sectionPadding = 32,
    this.sidebarTextStyle,
    this.activeTextStyle,
  });

  @override
  State<ScrollSpySliverView> createState() => _ScrollSpySliverViewState();
}

class _ScrollSpySliverViewState extends State<ScrollSpySliverView> {
  final ScrollController _scrollController = ScrollController();
  late final List<GlobalKey> _keys;
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    _keys = List.generate(widget.sections.length, (_) => GlobalKey());
  }

  void _scrollToSection(int index) {
    final context = _keys[index].currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        alignment: 0.1,
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Sidebar
        SizedBox(
          width: 160,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(widget.sections.length, (i) {
              final isActive = i == _activeIndex;
              return GestureDetector(
                onTap: () => _scrollToSection(i),
                child: Container(
                  color: isActive ? Colors.blue.shade50 : Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Text(
                    widget.sections[i].title,
                    style: isActive
                        ? widget.activeTextStyle ??
                            const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)
                        : widget.sidebarTextStyle ?? const TextStyle(color: Colors.black87),
                  ),
                ),
              );
            }),
          ),
        ),
        const VerticalDivider(width: 1),
        // Content
        Expanded(
          child: CustomScrollView(
            controller: _scrollController,
            slivers: List.generate(widget.sections.length, (i) {
              return SliverToBoxAdapter(
                child: VisibilityDetector(
                  key: _keys[i],
                  onVisibilityChanged: (info) {
                    if (info.visibleFraction > 0.6) {
                      setState(() => _activeIndex = i);
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: widget.sectionPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.sections[i].title,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        widget.sections[i].content,
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
