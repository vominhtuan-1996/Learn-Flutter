import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learnflutter/features/match_entry/cubit/match_entry_cubit.dart';
import 'package:learnflutter/features/match_entry/widgets/player_slot_card.dart';
import 'package:learnflutter/features/match_entry/widgets/player_combo_dropdown.dart';
import 'package:learnflutter/features/match_entry/widgets/match_preview_card.dart';
import 'package:learnflutter/features/match_entry/widgets/validation_summary_card.dart';
import 'package:learnflutter/features/match_entry/widgets/mini_court_widget.dart';
import 'package:learnflutter/features/match_entry/constants/match_entry_colors.dart';
import 'package:learnflutter/app/theme/app_colors.dart';

const double kMobileBreak = 768;
const double kTabletBreak = 1100;

class MatchEntryScreen extends StatefulWidget {
  const MatchEntryScreen({Key? key}) : super(key: key);

  @override
  State<MatchEntryScreen> createState() => _MatchEntryScreenState();
}

class _MatchEntryScreenState extends State<MatchEntryScreen> {
  bool _showPreviewSheet = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MatchEntryCubit(),
      child: BlocBuilder<MatchEntryCubit, MatchEntryState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Lên lịch trận đấu'),
              centerTitle: false,
              elevation: 1,
            ),
            body: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth <= kMobileBreak;
                final isTablet =
                    constraints.maxWidth <= kTabletBreak && !isMobile;
                final isDesktop = !isMobile && !isTablet;

                if (isDesktop) {
                  return _DesktopLayout(state: state);
                } else if (isTablet) {
                  return _TabletLayout(state: state);
                } else {
                  return _MobileLayout(
                    state: state,
                    showPreviewSheet: _showPreviewSheet,
                    onTogglePreview: () =>
                        setState(() => _showPreviewSheet = !_showPreviewSheet),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  final MatchEntryState state;

  const _DesktopLayout({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Form column (left)
        Expanded(
          flex: 135,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: _FormContent(state: state),
          ),
        ),
        // Preview column (right, sticky)
        Expanded(
          flex: 85,
          child: Container(
            color: Colors.grey[50],
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PreviewHeader(),
                  const SizedBox(height: 16),
                  MatchPreviewCard(state: state),
                  const SizedBox(height: 20),
                  ValidationSummaryCard(state: state),
                  const SizedBox(height: 40),
                  MiniCourtWidget(label: state.court.split(' · ')[0]),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TabletLayout extends StatelessWidget {
  final MatchEntryState state;

  const _TabletLayout({required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          _FormContent(state: state),
          const SizedBox(height: 40),
          _PreviewHeader(),
          const SizedBox(height: 16),
          MatchPreviewCard(state: state),
          const SizedBox(height: 20),
          ValidationSummaryCard(state: state),
          const SizedBox(height: 40),
          MiniCourtWidget(label: state.court.split(' · ')[0]),
        ],
      ),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  final MatchEntryState state;
  final bool showPreviewSheet;
  final VoidCallback onTogglePreview;

  const _MobileLayout({
    required this.state,
    required this.showPreviewSheet,
    required this.onTogglePreview,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Form content
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _FormContent(state: state),
              const SizedBox(height: 120), // Space for bottom sheet
            ],
          ),
        ),
        // Bottom sheet preview
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          left: 0,
          right: 0,
          bottom: 0,
          height: showPreviewSheet ? MediaQuery.of(context).size.height * 0.7 : 56,
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              if (details.primaryDelta! < -10) {
                onTogglePreview();
              } else if (details.primaryDelta! > 10 && showPreviewSheet) {
                onTogglePreview();
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: MatchEntryColors.borderDefault,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Header
                  GestureDetector(
                    onTap: onTogglePreview,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Xem trước trực tiếp',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              letterSpacing: 0.16,
                              color: MatchEntryColors.textSecondary,
                              fontFeatures: const [
                                FontFeature.tabularFigures()
                              ],
                            ),
                          ),
                          Text(
                            showPreviewSheet ? '▾ tap để đóng' : '▴ tap để mở',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 9.5,
                              letterSpacing: 0.14,
                              color: MatchEntryColors.textTertiary,
                              fontFeatures: const [
                                FontFeature.tabularFigures()
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Content (scrollable)
                  if (showPreviewSheet)
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            MatchPreviewCard(state: state),
                            const SizedBox(height: 20),
                            ValidationSummaryCard(state: state),
                            const SizedBox(height: 20),
                            MiniCourtWidget(label: state.court.split(' · ')[0]),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        // Fixed submit bar
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: _SubmitBar(state: state),
            ),
          ),
        ),
      ],
    );
  }
}

class _FormContent extends StatelessWidget {
  final MatchEntryState state;

  const _FormContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MatchEntryCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section 1: Player Picker
        _FormSection(
          title: 'Chọn Cầu Thủ',
          children: [
            Row(
              children: [
                Expanded(
                  child: PlayerSlotCard(
                    player: state.playerA,
                    onEmpty: () => _showPlayerPicker(context, cubit, 'A'),
                    onRemove: (_) => cubit.clearPlayerA(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'vs',
                    style: GoogleFonts.fraunces(
                      fontSize: 48,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                      color: MatchEntryColors.limePrimary,
                      height: 0.9,
                    ),
                  ),
                ),
                Expanded(
                  child: PlayerSlotCard(
                    player: state.playerB,
                    onEmpty: () => _showPlayerPicker(context, cubit, 'B'),
                    onRemove: (_) => cubit.clearPlayerB(),
                    isRightSlot: true,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Section 2: Match Details
        _FormSection(
          title: 'Chi Tiết Trận',
          children: [
            // Discipline
            Text(
              'Nội Dung',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            _SegmentedControl(
              options: [
                ('MS', 'Đơn nam'),
                ('WS', 'Đơn nữ'),
                ('MD', 'Đôi nam'),
                ('WD', 'Đôi nữ'),
                ('XD', 'Đôi nam nữ'),
              ],
              selected: state.discipline,
              onSelected: (value) => cubit.setDiscipline(value),
            ),
            const SizedBox(height: 20),
            // Best-of & Points
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Best Of',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 8),
                      _SegmentedControl(
                        options: [
                          ('3', 'Bo3'),
                          ('5', 'Bo5'),
                        ],
                        selected: state.bestOf.toString(),
                        onSelected: (value) =>
                            cubit.setBestOf(int.parse(value)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Điểm/Hiệp',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 8),
                      _SegmentedControl(
                        options: [
                          ('21', '21'),
                          ('30', '30'),
                        ],
                        selected: state.pointsPerSet.toString(),
                        onSelected: (value) =>
                            cubit.setPointsPerSet(int.parse(value)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Round & Court
            Row(
              children: [
                Expanded(
                  child: _FormField(
                    label: 'Vòng Đấu',
                    value: state.round,
                    onChanged: (v) => cubit.setRound(v),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _FormField(
                    label: 'Sân',
                    value: state.court,
                    onChanged: (v) => cubit.setCourt(v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Date, Time, Duration
            Row(
              children: [
                Expanded(
                  child: _FormField(
                    label: 'Ngày',
                    value: state.matchDate.toString().split(' ')[0],
                    onChanged: (v) {},
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _FormField(
                    label: 'Giờ',
                    value: _formatTime(state.matchTime),
                    onChanged: (v) {},
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _FormField(
                    label: 'Dự Tính',
                    value: state.estimatedDuration,
                    onChanged: (v) => cubit.setEstimatedDuration(v),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Section 3: Settings
        _FormSection(
          title: 'Cài Đặt',
          children: [
            _ToggleRow(
              label: 'Tính điểm trực tiếp',
              value: state.liveScoring,
              onChanged: (_) => context.read<MatchEntryCubit>().toggleLiveScoring(),
            ),
            _ToggleRow(
              label: 'Yêu cầu media',
              value: state.mediaRequest,
              onChanged: (_) => context.read<MatchEntryCubit>().toggleMediaRequest(),
            ),
            _ToggleRow(
              label: 'Thông báo lên lịch',
              value: state.scheduledNotification,
              onChanged: (_) =>
                  context.read<MatchEntryCubit>().toggleScheduledNotification(),
            ),
            const SizedBox(height: 20),
            TextField(
              maxLines: 3,
              onChanged: (v) => cubit.setNotes(v),
              decoration: InputDecoration(
                labelText: 'Ghi chú (tuỳ chọn)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showPlayerPicker(
    BuildContext context,
    MatchEntryCubit cubit,
    String side,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: PlayerComboDropdown(
          players: MatchEntryCubit.players,
          excludePlayerId: side == 'A' ? state.playerB?.id : state.playerA?.id,
          onSelect: (player) {
            if (side == 'A') {
              cubit.selectPlayerA(player);
            } else {
              cubit.selectPlayerB(player);
            }
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}

class _FormSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _FormSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: MatchEntryColors.surfaceElevated,
            border: Border.all(color: MatchEntryColors.borderDefault),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final String value;
  final Function(String) onChanged;

  const _FormField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        TextField(
          onChanged: onChanged,
          controller: TextEditingController(text: value),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}

class _SegmentedControl extends StatelessWidget {
  final List<(String, String)> options;
  final String selected;
  final Function(String) onSelected;

  const _SegmentedControl({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MatchEntryColors.borderSubtle,
        border: Border.all(color: MatchEntryColors.borderDefault),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: options.map((option) {
          final (value, label) = option;
          final isSelected = selected == value;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelected(value),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? MatchEntryColors.surfaceElevated
                      : Colors.transparent,
                  border: isSelected
                      ? Border.all(color: MatchEntryColors.borderDefault)
                      : null,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? MatchEntryColors.navyBg
                          : MatchEntryColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final Function(bool) onChanged;

  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmitBar extends StatelessWidget {
  final MatchEntryState state;

  const _SubmitBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MatchEntryCubit>();
    final isValid = state.isFormValid;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: MatchEntryColors.surfaceElevated,
        border: Border.all(color: MatchEntryColors.borderDefault),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isValid
                        ? MatchEntryColors.successGreen
                        : MatchEntryColors.warningYellow,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isValid ? 'Đã sẵn sàng' : 'Thiếu ${state.validationIssues.length} trường',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Đã lưu tự động',
                        style: const TextStyle(
                          fontSize: 10,
                          color: MatchEntryColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () => cubit.cancel(),
                child: const Text('Huỷ'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => cubit.saveDraft(),
                child: const Text('Lưu nháp'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: isValid
                    ? () => cubit.publishMatch()
                    : null,
                child: state.isPublishing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Công bố →'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Xem trước trực tiếp',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            letterSpacing: 0.16,
            color: MatchEntryColors.textSecondary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: MatchEntryColors.limePrimary,
                boxShadow: [
                  BoxShadow(
                    color: MatchEntryColors.limePrimary.withOpacity(0.25),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Cập nhật theo thao tác',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9.5,
                letterSpacing: 0.16,
                color: MatchEntryColors.limePrimary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
