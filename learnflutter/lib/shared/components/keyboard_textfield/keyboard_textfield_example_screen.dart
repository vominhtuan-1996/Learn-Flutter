import 'package:flutter/material.dart';

import 'package:learnflutter/shared/widgets/keyboard_textfield/keyboard_textfield.dart';

/// Demo các tính năng của [KeyboardTextField]:
/// - Toolbar trên keyboard có counter ký tự ở phải.
/// - Custom maxLength, multiline, obscure, custom toolbar.
class KeyboardTextFieldExampleScreen extends StatefulWidget {
  const KeyboardTextFieldExampleScreen({super.key});

  @override
  State<KeyboardTextFieldExampleScreen> createState() => _KeyboardTextFieldExampleScreenState();
}

class _KeyboardTextFieldExampleScreenState extends State<KeyboardTextFieldExampleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(title: const Text('KeyboardTextField Demo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _Section(
            title: '1. Mặc định — counter bên phải',
            description: 'Toolbar tự hiện trên keyboard khi focus, counter dạng "n".',
            child: KeyboardTextField(
              decoration: InputDecoration(
                hintText: 'Nhập gì đó...',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 16),
          _Section(
            title: '2. Có maxLength — counter "n/max"',
            description: 'Khi set maxLength, counter hiển thị dạng phân số.',
            child: KeyboardTextField(
              maxLength: 50,
              decoration: InputDecoration(
                hintText: 'Tối đa 50 ký tự',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                counterText: '',
              ),
              showNavigation: true,
            ),
          ),
          SizedBox(height: 16),
          _Section(
            title: '3. Multiline — bio / mô tả',
            description: 'minLines + maxLines, counter realtime trên toolbar.',
            child: KeyboardTextField(
              maxLength: 200,
              minLines: 3,
              maxLines: 6,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: 'Viết mô tả của bạn...',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                counterText: '',
              ),
            ),
          ),
          SizedBox(height: 16),
          _Section(
            title: '4. Số điện thoại — keyboard number',
            description: 'keyboardType + inputFormatters, toolbar vẫn show counter.',
            child: KeyboardTextField(
              keyboardType: TextInputType.phone,
              maxLength: 11,
              doneLabel: 'Xong',
              decoration: InputDecoration(
                hintText: '0xxx xxx xxx',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                counterText: '',
                prefixIcon: Icon(Icons.phone),
              ),
            ),
          ),
          SizedBox(height: 16),
          _ObscureExample(),
          SizedBox(height: 16),
          _CustomCounterExample(),
          SizedBox(height: 16),
          _CustomToolbarExample(),
        ],
      ),
    );
  }
}

class _ObscureExample extends StatefulWidget {
  const _ObscureExample();

  @override
  State<_ObscureExample> createState() => _ObscureExampleState();
}

class _ObscureExampleState extends State<_ObscureExample> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: '5. Password — obscure + toggle',
      description: 'obscureText, suffix toggle, counter vẫn đếm đúng.',
      child: KeyboardTextField(
        obscureText: _obscure,
        maxLength: 24,
        decoration: InputDecoration(
          hintText: 'Mật khẩu',
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
          counterText: '',
          suffixIcon: IconButton(
            icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
      ),
    );
  }
}

class _CustomCounterExample extends StatelessWidget {
  const _CustomCounterExample();

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: '6. Custom counter format',
      description: 'counterBuilder — tự render text "còn n ký tự".',
      child: KeyboardTextField(
        maxLength: 30,
        counterBuilder: (length, max) {
          final remain = (max ?? 0) - length;
          return 'còn $remain ký tự';
        },
        counterStyle: const TextStyle(
          color: Color(0xFFDC2626),
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        decoration: const InputDecoration(
          hintText: 'Tiêu đề ngắn',
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
          counterText: '',
        ),
      ),
    );
  }
}

class _CustomToolbarExample extends StatelessWidget {
  const _CustomToolbarExample();

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: '7. Custom toolbar hoàn toàn',
      description: 'toolbarBuilder — gradient + icon + counter tự bố trí.',
      child: KeyboardTextField(
        maxLength: 100,
        maxLines: 3,
        minLines: 1,
        keyboardType: TextInputType.multiline,
        decoration: const InputDecoration(
          hintText: 'Bình luận...',
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
          counterText: '',
        ),
        toolbarBuilder: (context, length, max, onDone) {
          return Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.edit, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Đang nhập...',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$length/${max ?? '∞'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onDone,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Icon(Icons.check_circle, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
