import 'package:flutter/material.dart';
import 'package:learnflutter/features/match_entry/constants/match_entry_colors.dart';

class MiniCourtWidget extends StatelessWidget {
  final String? label;

  const MiniCourtWidget({
    Key? key,
    this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: MatchEntryColors.courtGreen,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: MatchEntryColors.borderDefault.withOpacity(0.3),
        ),
      ),
      child: Stack(
        children: [
          // Court lines
          Positioned(
            left: 10,
            top: 10,
            right: 10,
            bottom: 10,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: MatchEntryColors.creamText.withOpacity(0.7),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          // Center line
          Positioned(
            top: 10,
            bottom: 10,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: 1.5,
                color: MatchEntryColors.creamText.withOpacity(0.7),
              ),
            ),
          ),
          // Net
          Positioned(
            top: 8,
            bottom: 8,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: 3,
                color: MatchEntryColors.limePrimary.withOpacity(0.7),
              ),
            ),
          ),
          // Label
          if (label != null)
            Positioned(
              left: 14,
              bottom: 12,
              child: Text(
                label!,
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 10,
                  letterSpacing: 0.14,
                  color: Color.fromARGB(179, 243, 239, 230),
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
