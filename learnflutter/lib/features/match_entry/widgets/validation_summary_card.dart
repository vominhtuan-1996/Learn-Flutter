import 'package:flutter/material.dart';
import 'package:learnflutter/features/match_entry/cubit/match_entry_cubit.dart';
import 'package:learnflutter/features/match_entry/constants/match_entry_colors.dart';

class ValidationSummaryCard extends StatelessWidget {
  final MatchEntryState state;

  const ValidationSummaryCard({Key? key, required this.state}) : super(key: key);

  bool get _isValid => state.validationIssues.isEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isValid
            ? MatchEntryColors.successGreen.withOpacity(0.12)
            : MatchEntryColors.warningYellow.withOpacity(0.12),
        border: Border.all(
          color: _isValid
              ? MatchEntryColors.successGreen.withOpacity(0.35)
              : MatchEntryColors.warningYellow.withOpacity(0.35),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isValid
                  ? MatchEntryColors.successGreen
                  : MatchEntryColors.warningYellow,
            ),
            child: Center(
              child: Text(
                _isValid ? '✓' : '!',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isValid ? 'Sẵn sàng công bố.' : 'Chưa thể công bố.',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _isValid
                      ? 'Mọi trường bắt buộc đã được điền. Công bố sẽ hiển thị trận đấu trên lịch công khai.'
                      : 'Vui lòng xử lý các mục dưới để kích hoạt nút Công bố:',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: MatchEntryColors.textSecondary,
                  ),
                ),
                if (state.validationIssues.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  ...state.validationIssues
                      .map((issue) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              '• $issue',
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: MatchEntryColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ))
                      .toList(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
