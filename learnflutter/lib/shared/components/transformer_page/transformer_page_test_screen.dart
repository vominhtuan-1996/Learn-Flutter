import 'package:flutter/material.dart';
import 'package:learnflutter/shared/components/transformer_page/transformer_page.dart';

/// Màn hình test trực quan [TransformerPage] với 4 dạng nội dung ví dụ:
///
/// 1. Gradient pages — fullscreen, dễ thấy hiệu ứng vật lý.
/// 2. Photo-card carousel — mô phỏng coverflow / album.
/// 3. Onboarding pages — icon + title + description.
/// 4. Mini card row — kích thước nhỏ để xem nhiều hiệu ứng cùng lúc.
///
/// Chip ngang ở dưới cho phép đổi nhanh giữa các [TransformerType].
class TransformerPageTestScreen extends StatefulWidget {
  const TransformerPageTestScreen({super.key});

  @override
  State<TransformerPageTestScreen> createState() => _TransformerPageTestScreenState();
}

class _TransformerPageTestScreenState extends State<TransformerPageTestScreen>
    with SingleTickerProviderStateMixin {
  TransformerType _type = TransformerType.coverFlow;
  late final TabController _tab = TabController(length: 4, vsync: this);

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TransformerPage Demo'),
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Gradient'),
            Tab(text: 'Photo Cards'),
            Tab(text: 'Onboarding'),
            Tab(text: 'Mini Row'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                _GradientDemo(type: _type),
                _PhotoCardsDemo(type: _type),
                _OnboardingDemo(type: _type),
                _MiniRowDemo(type: _type),
              ],
            ),
          ),
          _TypeSelector(
            value: _type,
            onChanged: (t) => setState(() => _type = t),
          ),
        ],
      ),
    );
  }
}

// ---------- Demo 1: Gradient fullscreen ----------

class _GradientDemo extends StatelessWidget {
  const _GradientDemo({required this.type});
  final TransformerType type;

  static const _gradients = <List<Color>>[
    [Color(0xFF6366F1), Color(0xFFEC4899)],
    [Color(0xFF06B6D4), Color(0xFF3B82F6)],
    [Color(0xFFF97316), Color(0xFFEAB308)],
    [Color(0xFF10B981), Color(0xFF06B6D4)],
    [Color(0xFFEF4444), Color(0xFFF97316)],
  ];

  @override
  Widget build(BuildContext context) {
    return TransformerPage(
      type: type,
      loop: true,
      itemCount: _gradients.length,
      itemBuilder: (_, index) {
        final colors = _gradients[index];
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 120,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------- Demo 2: Photo cards ----------

class _PhotoCardsDemo extends StatelessWidget {
  const _PhotoCardsDemo({required this.type});
  final TransformerType type;

  static const _cards = [
    ('Tokyo', '🗼', Color(0xFFEF4444)),
    ('Paris', '🗼', Color(0xFF6366F1)),
    ('NYC', '🗽', Color(0xFF0EA5E9)),
    ('Rio', '🏖️', Color(0xFFF59E0B)),
    ('Cairo', '🐫', Color(0xFFA16207)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade900,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: TransformerPage(
        type: type,
        loop: true,
        itemCount: _cards.length,
        itemBuilder: (_, index) {
          final (name, emoji, color) = _cards[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                color: color,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 96)),
                    const SizedBox(height: 16),
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------- Demo 3: Onboarding ----------

class _OnboardingDemo extends StatelessWidget {
  const _OnboardingDemo({required this.type});
  final TransformerType type;

  static const _slides = [
    (Icons.flash_on, 'Nhanh', 'Hiệu ứng GPU mượt 60fps trên mọi trang.'),
    (Icons.brush, 'Đẹp', '25+ hiệu ứng vật lý sẵn sàng dùng.'),
    (Icons.tune, 'Tuỳ biến', 'API đơn giản, hỗ trợ controller & callback.'),
    (Icons.check_circle, 'Sẵn sàng', 'Plug vào onboarding/banner chỉ 1 dòng.'),
  ];

  @override
  Widget build(BuildContext context) {
    return TransformerPage(
      type: type,
      itemCount: _slides.length,
      itemBuilder: (context, index) {
        final (icon, title, desc) = _slides[index];
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 120, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 32),
              Text(
                title,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                desc,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------- Demo 4: Mini row ----------

class _MiniRowDemo extends StatelessWidget {
  const _MiniRowDemo({required this.type});
  final TransformerType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: SizedBox(
        height: 220,
        child: TransformerPage(
          type: type,
          loop: true,
          itemCount: 8,
          itemBuilder: (_, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                width: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.primaries[index % Colors.primaries.length],
                      Colors.primaries[index % Colors.primaries.length].shade900,
                    ],
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '#${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------- Type selector ----------

class _TypeSelector extends StatelessWidget {
  const _TypeSelector({required this.value, required this.onChanged});

  final TransformerType value;
  final ValueChanged<TransformerType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            itemCount: TransformerType.values.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, index) {
              final t = TransformerType.values[index];
              final selected = t == value;
              return ChoiceChip(
                label: Text(t.name),
                selected: selected,
                onSelected: (_) => onChanged(t),
              );
            },
          ),
        ),
      ),
    );
  }
}
