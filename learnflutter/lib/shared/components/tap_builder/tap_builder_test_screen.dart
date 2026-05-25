import 'package:flutter/material.dart';
import 'package:learnflutter/shared/components/tap_builder/tap_animated_button_builder.dart';
import 'package:learnflutter/shared/components/tap_builder/tap_delayed_pressed_button_builder.dart';

/// Demo trực quan 2 component trong `tap_builder/`:
/// - [AnimatedTapButtonBuilder] (3D + haptic + glow)
/// - [TapDelayedPressedButton] (giữ pressed tối thiểu N ms)
///
/// Mỗi nút bấm sẽ show snackbar để xác nhận callback chạy.
class TapBuilderTestScreen extends StatelessWidget {
  const TapBuilderTestScreen({super.key});

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 1)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tap Builder Demo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle('AnimatedTapButtonBuilder'),
          const SizedBox(height: 8),
          const _SectionDesc(
              'Nghiêng 3D theo vị trí cursor, scale 0.94 khi pressed, kèm haptic + glow.'),
          const SizedBox(height: 16),

          AnimatedTapButtonBuilder(
            onTap: () => _toast(context, 'Default tapped'),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Text('Default — primaryContainer'),
            ),
          ),
          const SizedBox(height: 12),

          AnimatedTapButtonBuilder(
            background: Colors.indigo,
            onTap: () => _toast(context, 'Custom color tapped'),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Text(
                'Custom background',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 12),

          AnimatedTapButtonBuilder(
            background: Colors.amber,
            onTap: () => _toast(context, 'Tap'),
            onLongPress: () => _toast(context, 'Long press!'),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Text('Tap / Long press'),
            ),
          ),
          const SizedBox(height: 12),

          AnimatedTapButtonBuilder(
            isEnabled: false,
            background: Colors.grey,
            onTap: () => _toast(context, 'should not fire'),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Text(
                'Disabled (isEnabled: false)',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ),
          const SizedBox(height: 12),

          AnimatedTapButtonBuilder(
            background: Colors.deepPurple,
            padding: const EdgeInsets.all(24),
            onTap: () => _toast(context, 'Card tapped'),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'Card-style CTA',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),

          _SectionTitle('TapDelayedPressedButton'),
          const SizedBox(height: 8),
          const _SectionDesc(
              'Giữ trạng thái pressed tối thiểu N ms — tránh nhấp nháy, xác nhận touch rõ ràng.'),
          const SizedBox(height: 16),

          TapDelayedPressedButton(
            onPressed: () => _toast(context, 'Default 500ms'),
            child: const Text('Default (500ms)', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 12),

          TapDelayedPressedButton(
            minPressedDuration: const Duration(milliseconds: 200),
            onPressed: () => _toast(context, 'Fast 200ms'),
            child: const Text('Fast (200ms)', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 12),

          TapDelayedPressedButton(
            minPressedDuration: const Duration(milliseconds: 1200),
            pressedColor: Colors.deepOrange,
            onPressed: () => _toast(context, 'Slow 1.2s'),
            child: const Text('Slow (1.2s)', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 12),

          TapDelayedPressedButton(
            pressedColor: Colors.green,
            inactiveColor: Colors.green.shade200,
            onPressed: () => _toast(context, 'OTP sent'),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.message, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Gửi OTP', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          TapDelayedPressedButton(
            isEnabled: false,
            onPressed: () => _toast(context, 'should not fire'),
            child: const Text(
              'Disabled',
              style: TextStyle(color: Colors.white),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _SectionDesc extends StatelessWidget {
  const _SectionDesc(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
    );
  }
}
