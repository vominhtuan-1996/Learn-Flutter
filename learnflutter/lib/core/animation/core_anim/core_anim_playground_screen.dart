import 'package:flutter/material.dart';
import 'package:learnflutter/core/animation/core_anim/core_anim.dart';
import 'package:learnflutter/core/animation/core_anim/src/list/list_item_anim.dart';

/// Playground tổng hợp 3 nhóm demo của `core_anim` package:
/// - **Effects**: spring scale, composite, ripple (low-level effect builder).
/// - **Timeline**: preset `pressBounce`, `fadeInSlide`, `scaleOpacity`.
/// - **Full List**: list có swipe-to-delete + pin, collapse animation khi xoá.
class CoreAnimPlaygroundScreen extends StatefulWidget {
  const CoreAnimPlaygroundScreen({super.key});

  @override
  State<CoreAnimPlaygroundScreen> createState() => _CoreAnimPlaygroundScreenState();
}

class _CoreAnimPlaygroundScreenState extends State<CoreAnimPlaygroundScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    // Bật global ticker một lần duy nhất — dùng chung cho 3 tab.
    CoreTicker().start(this);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D1A),
        appBar: AppBar(
          title: const Text('Core Anim Playground', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            indicatorColor: Color(0xFF6C63FF),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: 'Effects'),
              Tab(text: 'Timeline'),
              Tab(text: 'Full List'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _EffectsTab(),
            _TimelineTab(),
            _FullListTab(),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TAB 1 — Effects
// ═══════════════════════════════════════════════════════════════════════════

class _EffectsTab extends StatelessWidget {
  const _EffectsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: const [
        _Label('Spring Scale (Tap & Hold)'),
        SizedBox(height: 12),
        _SpringScaleDemo(),
        SizedBox(height: 32),
        _Label('Composite (Scale + Translate + Opacity)'),
        SizedBox(height: 12),
        _CompositeDemo(),
        SizedBox(height: 32),
        _Label('Ripple Effect'),
        SizedBox(height: 12),
        _RippleDemo(),
      ],
    );
  }
}

class _SpringScaleDemo extends StatelessWidget {
  const _SpringScaleDemo();

  @override
  Widget build(BuildContext context) {
    final ctrl = CoreAnimController(value: 1.0, target: 1.0);
    return Center(
      child: GestureDetector(
        onTapDown: (_) => ctrl.press(),
        onTapUp: (_) => ctrl.release(),
        onTapCancel: () => ctrl.release(),
        child: AnimatedRepaint(
          controller: ctrl,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF3F8EFC)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Icon(Icons.touch_app, color: Colors.white, size: 48),
            ),
          ),
          builder: (t, child) => ScaleEffect(min: 0.88).build(t, child),
        ),
      ),
    );
  }
}

class _CompositeDemo extends StatelessWidget {
  const _CompositeDemo();

  @override
  Widget build(BuildContext context) {
    final ctrl = CoreAnimController(value: 1.0, target: 1.0);
    return Center(
      child: GestureDetector(
        onTapDown: (_) => ctrl.press(),
        onTapUp: (_) => ctrl.release(),
        onTapCancel: () => ctrl.release(),
        child: AnimatedRepaint(
          controller: ctrl,
          child: Container(
            width: 200,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6584), Color(0xFFFF9A44)],
              ),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Center(
              child: Text('Composite Effect',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          builder: (t, child) => CompositeEffect([
            ScaleEffect(min: 0.92),
            TranslateEffect(const Offset(0, 6), Offset.zero),
            OpacityEffect(min: 0.6),
          ]).build(t, child),
        ),
      ),
    );
  }
}

class _RippleDemo extends StatelessWidget {
  const _RippleDemo();

  @override
  Widget build(BuildContext context) {
    final ctrl = CoreAnimController(value: 0.0, target: 0.0);
    return Center(
      child: GestureDetector(
        onTap: () {
          ctrl.value = 0.0;
          ctrl.velocity = 0.0;
          ctrl.animateTo(1.0);
        },
        child: AnimatedRepaint(
          controller: ctrl,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFF43D8C9),
              borderRadius: BorderRadius.circular(80),
            ),
            child: const Center(
              child: Icon(Icons.radio_button_unchecked, color: Colors.white, size: 32),
            ),
          ),
          builder: (t, child) => Stack(
            alignment: Alignment.center,
            children: [
              child,
              CustomPaint(
                painter: RipplePainter(
                  progress: t,
                  color: const Color(0xFF43D8C9),
                  maxRadius: 100,
                ),
                size: const Size(200, 200),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TAB 2 — Timeline presets
// ═══════════════════════════════════════════════════════════════════════════

class _TimelineTab extends StatelessWidget {
  const _TimelineTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: const [
        _Label('Preset: pressBounce'),
        SizedBox(height: 12),
        _PressBounceDemo(),
        SizedBox(height: 32),
        _Label('Preset: fadeInSlide (tap to play)'),
        SizedBox(height: 12),
        _FadeInSlideDemo(),
        SizedBox(height: 32),
        _Label('Multi-track: Scale + Opacity'),
        SizedBox(height: 12),
        _MultiTrackDemo(),
      ],
    );
  }
}

class _PressBounceDemo extends StatelessWidget {
  const _PressBounceDemo();

  @override
  Widget build(BuildContext context) {
    final ctrl = CoreAnimController(value: 1.0, target: 1.0);
    return Center(
      child: GestureDetector(
        onTapDown: (_) => ctrl.animateTo(0.0),
        onTapUp: (_) => ctrl.animateTo(1.0),
        onTapCancel: () => ctrl.animateTo(1.0),
        child: AnimatedRepaint(
          controller: ctrl,
          child: _presetCard(
            color: const Color(0xFF6C63FF),
            icon: Icons.touch_app,
            label: 'Hold Me',
          ),
          builder: (t, child) => AnimPresets.pressBounce().build(t, child),
        ),
      ),
    );
  }
}

class _FadeInSlideDemo extends StatelessWidget {
  const _FadeInSlideDemo();

  @override
  Widget build(BuildContext context) {
    final ctrl = CoreAnimController(value: 0.0, target: 0.0);
    return Center(
      child: GestureDetector(
        onTap: () {
          ctrl.value = 0.0;
          ctrl.velocity = 0.0;
          ctrl.animateTo(1.0);
        },
        child: AnimatedRepaint(
          controller: ctrl,
          child: _presetCard(
            color: const Color(0xFFFF6584),
            icon: Icons.play_arrow_rounded,
            label: 'Tap to Play',
          ),
          builder: (t, child) => AnimPresets.fadeInSlide().build(t, child),
        ),
      ),
    );
  }
}

class _MultiTrackDemo extends StatelessWidget {
  const _MultiTrackDemo();

  @override
  Widget build(BuildContext context) {
    final ctrl = CoreAnimController(value: 0.0, target: 0.0);
    return Center(
      child: GestureDetector(
        onTap: () {
          ctrl.value = 0.0;
          ctrl.velocity = 0.0;
          ctrl.animateTo(1.0);
        },
        child: AnimatedRepaint(
          controller: ctrl,
          child: _presetCard(
            color: const Color(0xFF43D8C9),
            icon: Icons.layers_rounded,
            label: 'Multi-track',
          ),
          builder: (t, child) => AnimPresets.scaleOpacity().build(t, child),
        ),
      ),
    );
  }
}

Widget _presetCard({required Color color, required IconData icon, required String label}) {
  return Container(
    width: 200,
    height: 100,
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white, size: 36),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// TAB 3 — Full List (delete + pin + collapse)
// ═══════════════════════════════════════════════════════════════════════════

class _FullListTab extends StatefulWidget {
  const _FullListTab();

  @override
  State<_FullListTab> createState() => _FullListTabState();
}

class _FullListTabState extends State<_FullListTab> {
  late List<_Item> _items = _generateItems();

  List<_Item> _generateItems() => List.generate(
        12,
        (i) => _Item(id: i, title: 'Item #${i + 1}', anim: ListItemAnim()),
      );

  void _removeItem(int index) {
    final item = _items[index];
    if (item.anim.removing) return;
    item.anim.remove();
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _items.removeAt(index));
    });
    setState(() {});
  }

  void _pinItem(int index, bool pinned) {
    setState(() {
      final item = _items.removeAt(index);
      item.pinned = pinned;
      if (pinned) {
        _items.insert(0, item);
      } else {
        _items.add(item);
      }
    });
  }

  void _resetList() => setState(() => _items = _generateItems());

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_items.isEmpty)
          const Center(
            child: Text(
              'List is empty!\nTap ↺ to reset',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 16),
            ),
          )
        else
          ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _items.length,
            itemBuilder: (_, i) {
              final item = _items[i];
              return _AnimatedListItem(
                key: ValueKey(item.id),
                anim: item.anim,
                child: _ItemCard(
                  title: item.title,
                  pinned: item.pinned,
                  onDelete: () => _removeItem(i),
                  onPin: (v) => _pinItem(i, v),
                ),
              );
            },
          ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.small(
            backgroundColor: const Color(0xFF6C63FF),
            onPressed: _resetList,
            child: const Icon(Icons.refresh, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _AnimatedListItem extends StatelessWidget {
  const _AnimatedListItem({super.key, required this.anim, required this.child});

  final ListItemAnim anim;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedRepaint(
      controller: anim.ctrl,
      child: child,
      builder: (t, child) {
        final fade = (t * 2).clamp(0.0, 1.0);
        final collapse = (t * 2 - 1).clamp(0.0, 1.0);
        return Align(
          heightFactor: collapse,
          child: Padding(
            padding: EdgeInsets.only(top: (1 - collapse) * 4),
            child: Opacity(
              opacity: fade,
              child: Transform.scale(scale: 0.88 + 0.12 * fade, child: child),
            ),
          ),
        );
      },
    );
  }
}

class _ItemCard extends StatefulWidget {
  const _ItemCard({
    required this.title,
    required this.pinned,
    required this.onDelete,
    required this.onPin,
  });

  final String title;
  final bool pinned;
  final VoidCallback onDelete;
  final ValueChanged<bool> onPin;

  @override
  State<_ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<_ItemCard> {
  double _dragX = 0;
  bool _pinRevealed = false;
  bool _deleteRevealed = false;

  static const double _pinThreshold = 72.0;
  static const double _pinSnapX = 84.0;
  static const double _deleteSnapX = -84.0;

  void _onDragUpdate(DragUpdateDetails d) {
    setState(() {
      if (_pinRevealed) {
        _dragX = (_dragX + d.delta.dx).clamp(0.0, _pinSnapX);
      } else if (_deleteRevealed) {
        _dragX = (_dragX + d.delta.dx).clamp(_deleteSnapX, 0.0);
      } else {
        _dragX = (_dragX + d.delta.dx).clamp(-400.0, 120.0);
      }
    });
  }

  void _onDragEnd(DragEndDetails _) {
    final screenHalf = MediaQuery.of(context).size.width / 2;
    if (_dragX < -screenHalf) {
      widget.onDelete();
    } else if (_dragX < -_pinThreshold) {
      setState(() {
        _dragX = _deleteSnapX;
        _deleteRevealed = true;
      });
    } else if (_dragX > _pinThreshold) {
      setState(() {
        _dragX = _pinSnapX;
        _pinRevealed = true;
      });
    } else {
      setState(() {
        _dragX = 0;
        _pinRevealed = false;
        _deleteRevealed = false;
      });
    }
  }

  void _closePanel() {
    setState(() {
      _dragX = 0;
      _pinRevealed = false;
      _deleteRevealed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final deleteProgress =
        _deleteRevealed ? 1.0 : (-_dragX / (screenWidth / 2)).clamp(0.0, 1.0);
    final pinProgress = _pinRevealed ? 1.0 : (_dragX / _pinThreshold).clamp(0.0, 1.0);

    return GestureDetector(
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      onTap: (_pinRevealed || _deleteRevealed) ? _closePanel : null,
      child: SizedBox(
        height: 76,
        child: Stack(
          children: [
            if (_dragX >= 0)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.lerp(
                        const Color(0xFF1A2030), const Color(0xFF3A7DFF), pinProgress),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 22),
                  child: Opacity(
                    opacity: pinProgress,
                    child: GestureDetector(
                      onTap: () {
                        widget.onPin(!widget.pinned);
                        setState(() {
                          _dragX = 0;
                          _pinRevealed = false;
                        });
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                            color: Colors.white,
                            size: 22 + 4 * pinProgress,
                          ),
                          const SizedBox(height: 2),
                          Text(widget.pinned ? 'Unpin' : 'Pin',
                              style:
                                  const TextStyle(color: Colors.white, fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (_dragX <= 0)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.lerp(
                        const Color(0xFF2A1A1A), const Color(0xFFFF3B30), deleteProgress),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: Opacity(
                    opacity: deleteProgress,
                    child: _deleteRevealed
                        ? GestureDetector(
                            onTap: widget.onDelete,
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.delete_forever_rounded,
                                    color: Colors.white, size: 26),
                                SizedBox(height: 2),
                                Text('Delete',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 10)),
                              ],
                            ),
                          )
                        : Icon(Icons.delete_sweep_rounded,
                            color: Colors.white, size: 24 + 10 * deleteProgress),
                  ),
                ),
              ),
            Transform.translate(
              offset: Offset(_dragX, 0),
              child: Container(
                height: 66,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: widget.pinned
                      ? const Color(0xFF1E2540)
                      : const Color(0xFF1E1E30),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: widget.pinned
                        ? const Color(0xFF3A7DFF).withValues(alpha: 0.4)
                        : Colors.white.withValues(alpha: 0.07),
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  leading: CircleAvatar(
                    backgroundColor: widget.pinned
                        ? const Color(0xFF3A7DFF)
                        : const Color(0xFF6C63FF),
                    child: Icon(
                      widget.pinned ? Icons.push_pin : Icons.inbox_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  title: Text(widget.title,
                      style: const TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: Text(
                    _deleteRevealed
                        ? 'Tap 🗑 to confirm  •  Tap card to cancel'
                        : _pinRevealed
                            ? 'Tap 📌 to confirm  •  Tap card to cancel'
                            : '← delete  |  pin →',
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Color(0xFFFF6584), size: 20),
                    onPressed: widget.onDelete,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Item {
  _Item({required this.id, required this.title, required this.anim}) : pinned = false;
  final int id;
  final String title;
  final ListItemAnim anim;
  bool pinned;
}

// ═══════════════════════════════════════════════════════════════════════════
// Shared
// ═══════════════════════════════════════════════════════════════════════════

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white60,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
