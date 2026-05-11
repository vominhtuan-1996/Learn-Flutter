import 'package:flutter/material.dart';
import 'package:learnflutter/core/animation/core_anim/core_anim.dart';
import 'package:learnflutter/core/animation/core_anim/src/list/list_item_anim.dart';

class FullListDemoScreen extends StatefulWidget {
  const FullListDemoScreen({super.key});

  @override
  State<FullListDemoScreen> createState() => _FullListDemoScreenState();
}

class _FullListDemoScreenState extends State<FullListDemoScreen>
    with SingleTickerProviderStateMixin {
  late List<_Item> _items;

  @override
  void initState() {
    super.initState();
    CoreTicker().start(this);
    _items = _generateItems();
  }

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
        _items.insert(0, item); // Di chuyển lên đầu
      } else {
        _items.add(item);
      }
    });
  }

  void _resetList() => setState(() => _items = _generateItems());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        title: const Text('Full List Animation', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _resetList,
          ),
        ],
      ),
      body: _items.isEmpty
          ? const Center(
              child: Text('List is empty!\nTap ↺ to reset',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, fontSize: 16)),
            )
          : ListView.builder(
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
    );
  }
}

// ── Collapse animation wrapper ───────────────────────────────────────────────
class _AnimatedListItem extends StatelessWidget {
  final ListItemAnim anim;
  final Widget child;

  const _AnimatedListItem({super.key, required this.anim, required this.child});

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

// ── Bi-directional Swipe Card ────────────────────────────────────────────────
class _ItemCard extends StatefulWidget {
  final String title;
  final bool pinned;
  final VoidCallback onDelete;
  final ValueChanged<bool> onPin;

  const _ItemCard({
    required this.title,
    required this.pinned,
    required this.onDelete,
    required this.onPin,
  });

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
      // Swipe quá 1/2 màn hình → xoá ngay
      widget.onDelete();
    } else if (_dragX < -_pinThreshold) {
      // Swipe nhẹ sang trái → snap open delete panel
      setState(() { _dragX = _deleteSnapX; _deleteRevealed = true; });
    } else if (_dragX > _pinThreshold) {
      // Swipe sang phải → snap open pin panel
      setState(() { _dragX = _pinSnapX; _pinRevealed = true; });
    } else {
      // Chưa đủ ngưỡng → snap back
      setState(() { _dragX = 0; _pinRevealed = false; _deleteRevealed = false; });
    }
  }

  void _onDeleteConfirm() => widget.onDelete();

  void _onPinTap() {
    widget.onPin(!widget.pinned);
    setState(() { _dragX = 0; _pinRevealed = false; });
  }

  void _closePanel() {
    setState(() { _dragX = 0; _pinRevealed = false; _deleteRevealed = false; });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Khi đang kéo tự do: progress theo drag. Khi snap: progress = 1.
    final deleteProgress = _deleteRevealed
        ? 1.0
        : (-_dragX / (screenWidth / 2)).clamp(0.0, 1.0);
    final pinProgress = _pinRevealed
        ? 1.0
        : (_dragX / _pinThreshold).clamp(0.0, 1.0);

    return GestureDetector(
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      onTap: (_pinRevealed || _deleteRevealed) ? _closePanel : null,
      child: SizedBox(
        height: 76,
        child: Stack(
          children: [
            // ── Left bg: PIN (swipe right) ──────────────────────────────────
            if (_dragX >= 0)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.lerp(const Color(0xFF1A2030), const Color(0xFF3A7DFF), pinProgress),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 22),
                  child: Opacity(
                    opacity: pinProgress,
                    child: GestureDetector(
                      onTap: _onPinTap,
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
                              style: const TextStyle(color: Colors.white, fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // ── Right bg: DELETE (swipe left) ───────────────────────────────
            if (_dragX <= 0)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.lerp(const Color(0xFF2A1A1A), const Color(0xFFFF3B30), deleteProgress),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: Opacity(
                    opacity: deleteProgress,
                    child: _deleteRevealed
                        // Snap mode: nút xác nhận xoá
                        ? GestureDetector(
                            onTap: _onDeleteConfirm,
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.delete_forever_rounded, color: Colors.white, size: 26),
                                SizedBox(height: 2),
                                Text('Delete', style: TextStyle(color: Colors.white, fontSize: 10)),
                              ],
                            ),
                          )
                        // Drag mode: icon to dần theo progress
                        : Icon(Icons.delete_sweep_rounded,
                            color: Colors.white, size: 24 + 10 * deleteProgress),
                  ),
                ),
              ),

            // ── Foreground card ─────────────────────────────────────────────
            Transform.translate(
              offset: Offset(_dragX, 0),
              child: Container(
                height: 66,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: widget.pinned ? const Color(0xFF1E2540) : const Color(0xFF1E1E30),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: widget.pinned
                        ? const Color(0xFF3A7DFF).withOpacity(0.4)
                        : Colors.white.withOpacity(0.07),
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  leading: CircleAvatar(
                    backgroundColor: widget.pinned ? const Color(0xFF3A7DFF) : const Color(0xFF6C63FF),
                    child: Icon(
                      widget.pinned ? Icons.push_pin : Icons.inbox_rounded,
                      color: Colors.white, size: 16,
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
                    icon: const Icon(Icons.delete_outline, color: Color(0xFFFF6584), size: 20),
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

// ── Data model ────────────────────────────────────────────────────────────────
class _Item {
  final int id;
  final String title;
  final ListItemAnim anim;
  bool pinned;

  _Item({required this.id, required this.title, required this.anim, this.pinned = false});
}
