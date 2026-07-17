import 'package:equatable/equatable.dart';

enum MatchStatus { draft, published, completed }

class MatchModel extends Equatable {
  final int id;
  final String playerAName;
  final String playerBName;
  final String round;
  final String discipline; // 'Đơn nam', 'Đơn nữ', etc.
  final String court;
  final DateTime matchDate;
  final String matchTime;
  final MatchStatus status;
  final String? result; // "2-1", "2-0", etc. for completed matches

  const MatchModel({
    required this.id,
    required this.playerAName,
    required this.playerBName,
    required this.round,
    required this.discipline,
    required this.court,
    required this.matchDate,
    required this.matchTime,
    this.status = MatchStatus.draft,
    this.result,
  });

  String get statusLabel {
    switch (status) {
      case MatchStatus.published:
        return 'Đã công bố';
      case MatchStatus.draft:
        return 'Nháp';
      case MatchStatus.completed:
        return 'Hoàn thành';
    }
  }

  @override
  List<Object?> get props => [
        id,
        playerAName,
        playerBName,
        round,
        discipline,
        court,
        matchDate,
        matchTime,
        status,
        result,
      ];
}
