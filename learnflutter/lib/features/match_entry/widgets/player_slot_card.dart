import 'package:flutter/material.dart';
import 'package:learnflutter/features/match_entry/models/player_model.dart';
import 'package:learnflutter/features/match_entry/constants/match_entry_colors.dart';

class PlayerSlotCard extends StatelessWidget {
  final PlayerModel? player;
  final VoidCallback onEmpty;
  final Function(PlayerModel) onRemove;
  final bool isRightSlot;

  const PlayerSlotCard({
    Key? key,
    this.player,
    required this.onEmpty,
    required this.onRemove,
    this.isRightSlot = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isFilled = player != null;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isFilled
              ? MatchEntryColors.borderDefault
              : MatchEntryColors.borderDefault.withOpacity(0.5),
          width: isFilled ? 1.5 : 1.5,
          style: isFilled ? BorderStyle.solid : BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isFilled ? MatchEntryColors.surfaceElevated : Colors.transparent,
      ),
      child: InkWell(
        onTap: !isFilled ? onEmpty : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: isFilled
              ? _FilledSlot(
                  player: player!,
                  isRight: isRightSlot,
                  onRemove: onRemove,
                )
              : _EmptySlot(isRight: isRightSlot),
        ),
      ),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  final bool isRight;

  const _EmptySlot({required this.isRight});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment:
          isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: MatchEntryColors.surfaceElevated,
            border: Border.all(color: MatchEntryColors.borderDefault),
          ),
          child: const Icon(
            Icons.add,
            color: MatchEntryColors.textSecondary,
            size: 18,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Chọn cầu thủ',
          style: TextStyle(
            fontSize: 13,
            color: MatchEntryColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _FilledSlot extends StatelessWidget {
  final PlayerModel player;
  final bool isRight;
  final Function(PlayerModel) onRemove;

  const _FilledSlot({
    required this.player,
    required this.isRight,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          textDirection: isRight ? TextDirection.rtl : TextDirection.ltr,
          children: [
            // Avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    MatchEntryColors.limePrimary,
                    MatchEntryColors.rustAccent,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(
                  player.initials,
                  style: const TextStyle(
                    fontFamily: 'Bebas Neue',
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A0C16),
                    letterSpacing: 0.02,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Player info
            Expanded(
              child: Column(
                crossAxisAlignment: isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    player.name,
                    style: const TextStyle(
                      fontFamily: 'Bebas Neue',
                      fontSize: 30,
                      height: 0.95,
                      letterSpacing: 0.01,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 10,
                    direction: Axis.horizontal,
                    runAlignment: isRight ? WrapAlignment.end : WrapAlignment.start,
                    children: [
                      _MetaTag('Hạt giống ${_padSeed(player.seed)}'),
                      _MetaTag(player.country),
                      _MetaTag(player.handedness),
                      _MetaTag('${player.age}t'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        // Remove button
        Positioned(
          top: 10,
          right: isRight ? 10 : null,
          left: isRight ? null : 10,
          child: GestureDetector(
            onTap: () => onRemove(player),
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: MatchEntryColors.surfaceElevated,
                border: Border.all(color: MatchEntryColors.borderDefault),
              ),
              child: Center(
                child: Text(
                  '×',
                  style: TextStyle(
                    fontSize: 14,
                    color: MatchEntryColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _padSeed(int seed) => seed.toString().padLeft(2, '0');
}

class _MetaTag extends StatelessWidget {
  final String text;

  const _MetaTag(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'JetBrains Mono',
        fontSize: 10.5,
        letterSpacing: 0.1,
        color: MatchEntryColors.textSecondary,
      ),
    );
  }
}
