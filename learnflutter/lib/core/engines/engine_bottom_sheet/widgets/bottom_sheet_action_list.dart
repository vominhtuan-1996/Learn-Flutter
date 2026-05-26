import 'package:flutter/material.dart';
import 'package:learnflutter/core/engines/engine_bottom_sheet/models/bottom_sheet_config.dart';

/// Widget chuyên dụng quản lý danh sách tùy chọn (action items) dạng dòng.
class BottomSheetActionList extends StatelessWidget {
  final List<AppBottomSheetActionItem> items;

  const BottomSheetActionList({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final titleColor = item.isDestructive 
            ? const Color(0xFFEF4444) 
            : (isDark ? Colors.white : const Color(0xFF374151));
        final iconColor = item.isDestructive 
            ? const Color(0xFFEF4444) 
            : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280));
        final hoverColor = isDark ? const Color(0xFF334155).withOpacity(0.5) : const Color(0xFFF9FAFB);

        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
                item.onTap();
              },
              borderRadius: BorderRadius.circular(12),
              hoverColor: hoverColor,
              splashColor: hoverColor,
              highlightColor: hoverColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  children: [
                    Icon(item.icon, color: iconColor, size: 20),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded, 
                      color: isDark ? const Color(0xFF475569) : const Color(0xFFD1D5DB), 
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
