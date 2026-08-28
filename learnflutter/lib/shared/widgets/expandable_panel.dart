import 'package:flutter/material.dart';
import 'package:learnflutter/shared/widgets/tap.dart';

class ExpandablePanel extends StatefulWidget {
  final Widget header;
  final Widget body;
  final bool initialExpanded;
  final ValueChanged<bool>? onExpansionChanged;
  final Duration duration;

  const ExpandablePanel({
    super.key,
    required this.header,
    required this.body,
    this.initialExpanded = false,
    this.onExpansionChanged,
    this.duration = const Duration(milliseconds: 250),
  });

  @override
  State<ExpandablePanel> createState() => _ExpandablePanelState();
}

class _ExpandablePanelState extends State<ExpandablePanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconTurn;
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initialExpanded;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: _expanded ? 1.0 : 0.0,
    );
    _iconTurn = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _controller.forward() : _controller.reverse();
    widget.onExpansionChanged?.call(_expanded);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Tap(
          onTap: _toggle,
          child: Row(
            children: [
              Expanded(child: widget.header),
              RotationTransition(
                turns: _iconTurn,
                child: const Icon(Icons.expand_more_rounded),
              ),
            ],
          ),
        ),
        SizeTransition(
          sizeFactor: CurvedAnimation(
            parent: _controller,
            curve: Curves.easeInOut,
          ),
          axisAlignment: -1,
          child: widget.body,
        ),
      ],
    );
  }
}
