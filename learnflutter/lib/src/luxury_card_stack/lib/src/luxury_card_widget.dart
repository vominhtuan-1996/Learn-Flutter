import 'package:flutter/material.dart';
import 'package:learnflutter/src/luxury_card_stack/lib/src/luxury_card_item.dart';

class LuxuryCardWidget extends StatelessWidget {
  final LuxuryCardItem item;

  const LuxuryCardWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.of(context).size.width * 0.8;

    return SizedBox(
      width: cardWidth,
      child: AspectRatio(
        aspectRatio: 1.6, // 🔥 TỈ LỆ CHUẨN UI MẪU
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                blurRadius: 24,
                offset: const Offset(0, 14),
                color: Colors.black.withOpacity(0.12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: _CardContent(item: item),
          ),
        ),
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  final LuxuryCardItem item;

  const _CardContent({required this.item});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🚗 IMAGE – chiếm chiều ngang
        Positioned(
          right: -36,
          bottom: 0,
          top: 0,
          child: Image.asset(
            item.image,
            width: MediaQuery.of(context).size.width * 0.7,
            fit: BoxFit.contain,
          ),
        ),

        // 📝 TEXT
        Positioned(
          left: 24,
          top: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // if (item.tag != null) _LuxuryTag(item.tag!),
              const SizedBox(height: 12),
              Text(
                item.title ?? '',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                item.subtitle ?? '',
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
