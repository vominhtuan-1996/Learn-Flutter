import 'package:flutter/material.dart';
import 'package:learnflutter/app/theme/app_colors.dart';

class RatingBar extends StatefulWidget {
  final double rating;
  final int maxRating;
  final ValueChanged<double>? onRatingChanged;
  final bool readOnly;
  final double size;
  final Color? color;
  final bool halfStarEnabled;

  const RatingBar({
    super.key,
    this.rating = 0,
    this.maxRating = 5,
    this.onRatingChanged,
    this.readOnly = false,
    this.size = 32,
    this.color,
    this.halfStarEnabled = false,
  });

  @override
  State<RatingBar> createState() => _RatingBarState();
}

class _RatingBarState extends State<RatingBar> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.rating;
  }

  @override
  void didUpdateWidget(RatingBar old) {
    super.didUpdateWidget(old);
    if (old.rating != widget.rating) _rating = widget.rating;
  }

  void _onTap(int index, Offset localPos, double starWidth) {
    if (widget.readOnly) return;
    double newRating;
    if (widget.halfStarEnabled && localPos.dx < starWidth / 2) {
      newRating = index + 0.5;
    } else {
      newRating = index + 1.0;
    }
    setState(() => _rating = newRating);
    widget.onRatingChanged?.call(newRating);
  }

  IconData _iconFor(int index) {
    final filled = _rating >= index + 1;
    final half = !filled && _rating >= index + 0.5;
    if (filled) return Icons.star_rounded;
    if (half) return Icons.star_half_rounded;
    return Icons.star_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final starColor = widget.color ?? AppColors.orange;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.maxRating, (i) {
        return GestureDetector(
          onTapUp: widget.readOnly
              ? null
              : (details) => _onTap(i, details.localPosition, widget.size),
          child: Icon(
            _iconFor(i),
            size: widget.size,
            color: starColor,
          ),
        );
      }),
    );
  }
}
