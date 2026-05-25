import 'package:flutter/material.dart';
import 'package:learnflutter/shared/components/luxury_card_stack/luxury_card_stack.dart';

/// Demo trực quan [LuxuryCardStackView] với 3 tab:
/// - Gradient: custom builder không phụ thuộc asset.
/// - Network: cardBuilder dùng `Image.network`.
/// - Controlled: dùng [LuxuryCardStackController] inject từ ngoài + nút auto-swipe.
class LuxuryCardStackTestScreen extends StatelessWidget {
  const LuxuryCardStackTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('LuxuryCardStack Demo'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Gradient'),
            Tab(text: 'Network'),
            Tab(text: 'Controlled'),
          ]),
        ),
        body: const TabBarView(
          children: [
            _GradientDemo(),
            _NetworkDemo(),
            _ControlledDemo(),
          ],
        ),
      ),
    );
  }
}

// ---------- Tab 1: Gradient cards ----------

class _GradientDemo extends StatefulWidget {
  const _GradientDemo();

  @override
  State<_GradientDemo> createState() => _GradientDemoState();
}

class _GradientDemoState extends State<_GradientDemo> {
  late final List<LuxuryCardItem> _items = [
    const LuxuryCardItem(image: '', title: 'Aurora', subtitle: 'Northern lights'),
    const LuxuryCardItem(image: '', title: 'Sunset', subtitle: 'Golden hour'),
    const LuxuryCardItem(image: '', title: 'Ocean', subtitle: 'Deep blue'),
    const LuxuryCardItem(image: '', title: 'Forest', subtitle: 'Evergreen'),
    const LuxuryCardItem(image: '', title: 'Magma', subtitle: 'Volcanic'),
  ];

  static const _palettes = <List<Color>>[
    [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    [Color(0xFFF59E0B), Color(0xFFEF4444)],
    [Color(0xFF06B6D4), Color(0xFF3B82F6)],
    [Color(0xFF10B981), Color(0xFF065F46)],
    [Color(0xFFEF4444), Color(0xFF7C2D12)],
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Kéo card ngang/dọc để swipe →',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),
            LuxuryCardStackView(
              items: _items,
              onSwipeEnd: (_) => setState(() {}),
              cardBuilder: (context, item, index) {
                final palette = _palettes[index % _palettes.length];
                final width = MediaQuery.of(context).size.width * 0.78;
                return Container(
                  width: width,
                  height: 260,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: LinearGradient(
                      colors: palette,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '#${index + 1}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            item.subtitle ?? '',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Tab 2: Network image ----------

class _NetworkDemo extends StatefulWidget {
  const _NetworkDemo();

  @override
  State<_NetworkDemo> createState() => _NetworkDemoState();
}

class _NetworkDemoState extends State<_NetworkDemo> {
  late final List<LuxuryCardItem> _items = [
    const LuxuryCardItem(
      image: 'https://picsum.photos/seed/luxe1/600/400',
      title: 'Mountain',
    ),
    const LuxuryCardItem(
      image: 'https://picsum.photos/seed/luxe2/600/400',
      title: 'River',
    ),
    const LuxuryCardItem(
      image: 'https://picsum.photos/seed/luxe3/600/400',
      title: 'City',
    ),
    const LuxuryCardItem(
      image: 'https://picsum.photos/seed/luxe4/600/400',
      title: 'Desert',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LuxuryCardStackView(
        items: _items,
        onSwipeEnd: (_) => setState(() {}),
        cardBuilder: (context, item, index) {
          final width = MediaQuery.of(context).size.width * 0.8;
          return Container(
            width: width,
            height: 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              image: DecorationImage(image: NetworkImage(item.image), fit: BoxFit.cover),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
                ),
              ),
              padding: const EdgeInsets.all(20),
              alignment: Alignment.bottomLeft,
              child: Text(
                item.title ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------- Tab 3: Controlled (external controller) ----------

class _ControlledDemo extends StatefulWidget {
  const _ControlledDemo();

  @override
  State<_ControlledDemo> createState() => _ControlledDemoState();
}

class _ControlledDemoState extends State<_ControlledDemo>
    with TickerProviderStateMixin {
  late final LuxuryCardStackController _controller =
      LuxuryCardStackController(vsync: this);

  late final List<LuxuryCardItem> _items = [
    for (var i = 1; i <= 6; i++) LuxuryCardItem(image: '', title: 'Card $i'),
  ];

  int _swipeCount = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _swipeNext() async {
    await _controller.dropDown();
    setState(() => _swipeCount++);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Đã swipe: $_swipeCount lần'),
          const SizedBox(height: 16),
          LuxuryCardStackView(
            controller: _controller,
            items: _items,
            cardBuilder: (context, item, index) {
              final colors = [
                Colors.indigo,
                Colors.deepOrange,
                Colors.teal,
                Colors.pink,
                Colors.amber.shade800,
                Colors.green.shade700,
              ];
              final width = MediaQuery.of(context).size.width * 0.8;
              return Container(
                width: width,
                height: 240,
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  borderRadius: BorderRadius.circular(28),
                ),
                alignment: Alignment.center,
                child: Text(
                  item.title ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _swipeNext,
            icon: const Icon(Icons.skip_next),
            label: const Text('Swipe next (controller.dropDown)'),
          ),
        ],
      ),
    );
  }
}
