import 'package:flutter/material.dart';
import 'package:learnflutter/features/match_entry/models/player_model.dart';
import 'package:learnflutter/features/match_entry/constants/match_entry_colors.dart';

class PlayerComboDropdown extends StatefulWidget {
  final List<PlayerModel> players;
  final int? excludePlayerId;
  final Function(PlayerModel) onSelect;

  const PlayerComboDropdown({
    Key? key,
    required this.players,
    this.excludePlayerId,
    required this.onSelect,
  }) : super(key: key);

  @override
  State<PlayerComboDropdown> createState() => _PlayerComboDropdownState();
}

class _PlayerComboDropdownState extends State<PlayerComboDropdown> {
  late TextEditingController _searchController;
  late FocusNode _focusNode;
  List<PlayerModel> _filteredPlayers = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _focusNode = FocusNode();
    _updateFiltered('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _updateFiltered(String query) {
    final q = query.toLowerCase().trim();
    setState(() {
      if (q.isEmpty) {
        _filteredPlayers = widget.players
            .where((p) => p.id != widget.excludePlayerId)
            .toList();
      } else {
        _filteredPlayers = widget.players
            .where((p) =>
                p.id != widget.excludePlayerId &&
                (p.name.toLowerCase().contains(q) ||
                    p.country.toLowerCase().contains(q) ||
                    p.seed.toString() == q))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search input
        TextField(
          controller: _searchController,
          focusNode: _focusNode,
          onChanged: _updateFiltered,
          decoration: InputDecoration(
            hintText: 'Tìm cầu thủ theo tên, quốc gia...',
            prefixIcon: Icon(
              Icons.search,
              color: MatchEntryColors.textTertiary,
              size: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Dropdown list
        Container(
          decoration: BoxDecoration(
            color: MatchEntryColors.surfaceElevated,
            border: Border.all(color: MatchEntryColors.borderDefault),
            borderRadius: BorderRadius.circular(8),
          ),
          constraints: const BoxConstraints(maxHeight: 280),
          child: _filteredPlayers.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      _searchController.text.isEmpty
                          ? 'Không có cầu thủ nào'
                          : 'Không tìm thấy khớp với "${_searchController.text}"',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: MatchEntryColors.textTertiary,
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(6),
                  itemCount: _filteredPlayers.length,
                  itemBuilder: (context, index) {
                    final player = _filteredPlayers[index];
                    return _PlayerOption(
                      player: player,
                      onTap: () {
                        widget.onSelect(player);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _PlayerOption extends StatelessWidget {
  final PlayerModel player;
  final VoidCallback onTap;

  const _PlayerOption({
    required this.player,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    MatchEntryColors.limePrimary,
                    MatchEntryColors.rustAccent,
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  player.initials,
                  style: const TextStyle(
                    fontFamily: 'Bebas Neue',
                    fontSize: 14,
                    color: Color(0xFF0A0C16),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Hạt giống ${_padSeed(player.seed)} · ${player.country} · Hạng TG №${player.rank}',
                    style: const TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 10,
                      letterSpacing: 0.1,
                      color: MatchEntryColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              player.handedness,
              style: const TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 10.5,
                color: MatchEntryColors.textSecondary,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _padSeed(int seed) => seed.toString().padLeft(2, '0');
}
