import 'package:flutter/material.dart';
import 'package:learnflutter/features/match_entry/cubit/match_entry_cubit.dart';
import 'package:learnflutter/features/match_entry/constants/match_entry_colors.dart';

class MatchPreviewCard extends StatelessWidget {
  final MatchEntryState state;

  const MatchPreviewCard({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MatchEntryColors.navyBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: MatchEntryColors.limePrimary.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Radial gradient background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: RadialGradient(
                  colors: [
                    MatchEntryColors.limePrimary.withOpacity(0.12),
                    Colors.transparent,
                  ],
                  center: const Alignment(0.9, 0),
                  radius: 0.5,
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${state.round} · ${state.disciplineLabel}',
                      style: const TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 10,
                        letterSpacing: 0.14,
                        color: Color.fromARGB(140, 243, 239, 230),
                      ),
                    ),
                    Text(
                      state.court.split(' · ')[0],
                      style: const TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 10,
                        letterSpacing: 0.14,
                        color: Color.fromARGB(140, 243, 239, 230),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                // Matchup
                Row(
                  children: [
                    // Player A
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SeedTag(
                            seed: state.playerA?.seed ?? 0,
                            country: state.playerA?.country ?? '---',
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.playerA?.name ?? 'Cầu thủ A',
                            style: const TextStyle(
                              fontFamily: 'Bebas Neue',
                              fontSize: 36,
                              height: 0.9,
                              letterSpacing: 0.02,
                              color: MatchEntryColors.creamText,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.playerA != null
                                ? '${state.playerA!.handedness} · ${state.playerA!.age}t'
                                : '—',
                            style: const TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 10,
                              letterSpacing: 0.08,
                              color: Color.fromARGB(140, 243, 239, 230),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // VS
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        'vs',
                        style: const TextStyle(
                          fontFamily: 'Fraunces',
                          fontStyle: FontStyle.italic,
                          fontSize: 44,
                          fontWeight: FontWeight.w500,
                          color: MatchEntryColors.limePrimary,
                          height: 1,
                        ),
                      ),
                    ),
                    // Player B
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _SeedTag(
                            seed: state.playerB?.seed ?? 0,
                            country: state.playerB?.country ?? '---',
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.playerB?.name ?? 'Cầu thủ B',
                            style: const TextStyle(
                              fontFamily: 'Bebas Neue',
                              fontSize: 36,
                              height: 0.9,
                              letterSpacing: 0.02,
                              color: MatchEntryColors.creamText,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.playerB != null
                                ? '${state.playerB!.handedness} · ${state.playerB!.age}t'
                                : '—',
                            style: const TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 10,
                              letterSpacing: 0.08,
                              color: Color.fromARGB(140, 243, 239, 230),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                // Stats strip
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: MatchEntryColors.creamText.withOpacity(0.12),
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCell(
                          label: 'Ngày',
                          value: _formatDate(state.matchDate),
                        ),
                      ),
                      Expanded(
                        child: _StatCell(
                          label: 'Giờ',
                          value: _formatTime(state.matchTime),
                        ),
                      ),
                      Expanded(
                        child: _StatCell(
                          label: 'Thể thức',
                          value: 'Bo${state.bestOf}',
                        ),
                      ),
                      Expanded(
                        child: _StatCell(
                          label: 'Dự tính',
                          value: state.estimatedDuration,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Th 1', 'Th 2', 'Th 3', 'Th 4', 'Th 5', 'Th 6',
      'Th 7', 'Th 8', 'Th 9', 'Th 10', 'Th 11', 'Th 12'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class _SeedTag extends StatelessWidget {
  final int seed;
  final String country;

  const _SeedTag({required this.seed, required this.country});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Hạt giống ${seed.toString().padLeft(2, '0')} · $country',
      style: const TextStyle(
        fontFamily: 'JetBrains Mono',
        fontSize: 10,
        letterSpacing: 0.14,
        color: MatchEntryColors.limePrimary,
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;

  const _StatCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Bebas Neue',
            fontSize: 20,
            height: 1,
            color: MatchEntryColors.creamText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 9.5,
            letterSpacing: 0.14,
            color: Color.fromARGB(128, 243, 239, 230),
          ),
        ),
      ],
    );
  }
}
