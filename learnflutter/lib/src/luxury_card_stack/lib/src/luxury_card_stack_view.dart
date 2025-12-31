import 'package:flutter/material.dart';
import 'package:learnflutter/src/luxury_card_stack/lib/src/luxury_card_controller.dart';
import 'package:learnflutter/src/luxury_card_stack/lib/src/luxury_card_item.dart';

class LuxuryCardStackView extends StatefulWidget {
  final List<LuxuryCardItem> items;
  final LuxuryCardStackController? controller;
  final int visibleCount;
  final Widget Function(
    BuildContext context,
    LuxuryCardItem item,
    int index,
  ) cardBuilder;
  final ValueChanged<int>? onSwipeEnd;

  const LuxuryCardStackView({
    super.key,
    required this.items,
    required this.cardBuilder,
    this.controller,
    this.visibleCount = 3,
    this.onSwipeEnd,
  });

  @override
  State<LuxuryCardStackView> createState() => _LuxuryCardStackViewState();
}

class _LuxuryCardStackViewState extends State<LuxuryCardStackView> with TickerProviderStateMixin {
  late final LuxuryCardStackController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? LuxuryCardStackController(vsync: this);
  }

  Widget _buildCard(int index) {
    if (index >= widget.items.length) return const SizedBox();

    final isTop = index == 0;
    final dragX = controller.dragX;
    final progress = (dragX.abs() / 140).clamp(0.0, 1.0);

    final scale = isTop ? controller.dropScale : 1.0 - index * 0.06 + progress * 0.04;

    final offsetX = index * 26 + (isTop ? dragX : dragX * 0.12);

    final offsetY = isTop ? controller.dropY : 0.0;

    return Transform.translate(
      offset: Offset(offsetX, offsetY),
      child: Transform.scale(
        alignment: Alignment.centerRight,
        scale: scale,
        child: _CardShadowWrapper(
          intensity: isTop ? controller.dropShadow : 1.0,
          child: widget.cardBuilder(
            context,
            widget.items[index],
            index,
          ),
        ),
      ),
    );
  }

  void _sendTopItemToBack() {
    if (widget.items.length < 2) return;

    setState(() {
      final first = widget.items.removeAt(0);
      widget.items.add(first);
    });

    widget.onSwipeEnd?.call(0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (d) {
        controller.updateDrag(d.delta.dx);
      },
      onHorizontalDragEnd: (d) async {
        final velocity = d.velocity.pixelsPerSecond.dx;
        final shouldSendToBack = controller.dragX.abs() > 120 || velocity.abs() > 900;

        if (shouldSendToBack) {
          await controller.dropDown();
          _sendTopItemToBack();
        } else {
          await controller.snapBack(velocity);
        }
      },
      onVerticalDragUpdate: (details) {
        controller.updateVerticalDrag(details.delta.dy);
      },
      onVerticalDragEnd: (details) async {
        final velocityY = details.velocity.pixelsPerSecond.dy;

        final shouldSendToBack = controller.dropY > 100 || velocityY > 900;

        if (shouldSendToBack) {
          await controller.dropDown();
          _sendTopItemToBack();
        } else {
          await controller.snapBackVertical(velocityY);
        }
      },
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          return SizedBox(
            height: 300,
            child: Stack(
              children: List.generate(
                widget.visibleCount,
                (index) => _buildCard(index),
              ).reversed.toList(),
            ),
          );
        },
      ),
    );
  }
}

class _CardShadowWrapper extends StatelessWidget {
  final Widget child;
  final double intensity;

  const _CardShadowWrapper({
    required this.child,
    required this.intensity,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            blurRadius: 24 * intensity,
            offset: Offset(0, 14 * intensity),
            color: Colors.black.withOpacity(0.12 * intensity),
          ),
        ],
      ),
      child: child,
    );
  }
}
