part of 'match_entry_cubit.dart';

class MatchEntryState extends Equatable {
  final PlayerModel? playerA;
  final PlayerModel? playerB;

  // Match details
  final String discipline; // 'MS', 'WS', 'MD', 'WD', 'XD'
  final String round;
  final int bestOf; // 3 or 5
  final int pointsPerSet; // 21 or 30
  final String court;
  final DateTime matchDate;
  final TimeOfDay matchTime;
  final String estimatedDuration;

  // Settings
  final bool liveScoring;
  final bool mediaRequest;
  final bool scheduledNotification;
  final String notes;

  // Publish state
  final bool isPublishing;
  final bool isPublished;
  final String? publishError;

  const MatchEntryState({
    this.playerA,
    this.playerB,
    this.discipline = 'MS',
    this.round = 'Vòng 16',
    this.bestOf = 3,
    this.pointsPerSet = 21,
    this.court = 'Sân Trung tâm · 7.200',
    required this.matchDate,
    required this.matchTime,
    this.estimatedDuration = '1g 15ph',
    this.liveScoring = false,
    this.mediaRequest = false,
    this.scheduledNotification = false,
    this.notes = '',
    this.isPublishing = false,
    this.isPublished = false,
    this.publishError,
  });

  // Computed properties
  bool get isFormValid =>
      playerA != null && playerB != null && playerA!.id != playerB!.id;

  List<String> get validationIssues {
    final issues = <String>[];
    if (playerA == null) issues.add('Chọn cầu thủ A');
    if (playerB == null) issues.add('Chọn cầu thủ B');
    if (playerA != null &&
        playerB != null &&
        playerA!.id == playerB!.id) {
      issues.add('Hai cầu thủ phải khác nhau');
    }
    return issues;
  }

  String get disciplineLabel {
    switch (discipline) {
      case 'MS':
        return 'Đơn nam';
      case 'WS':
        return 'Đơn nữ';
      case 'MD':
        return 'Đôi nam';
      case 'WD':
        return 'Đôi nữ';
      case 'XD':
        return 'Đôi nam nữ';
      default:
        return discipline;
    }
  }

  MatchEntryState copyWith({
    PlayerModel? playerA,
    PlayerModel? playerB,
    String? discipline,
    String? round,
    int? bestOf,
    int? pointsPerSet,
    String? court,
    DateTime? matchDate,
    TimeOfDay? matchTime,
    String? estimatedDuration,
    bool? liveScoring,
    bool? mediaRequest,
    bool? scheduledNotification,
    String? notes,
    bool? isPublishing,
    bool? isPublished,
    String? publishError,
  }) {
    return MatchEntryState(
      playerA: playerA ?? this.playerA,
      playerB: playerB ?? this.playerB,
      discipline: discipline ?? this.discipline,
      round: round ?? this.round,
      bestOf: bestOf ?? this.bestOf,
      pointsPerSet: pointsPerSet ?? this.pointsPerSet,
      court: court ?? this.court,
      matchDate: matchDate ?? this.matchDate,
      matchTime: matchTime ?? this.matchTime,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      liveScoring: liveScoring ?? this.liveScoring,
      mediaRequest: mediaRequest ?? this.mediaRequest,
      scheduledNotification: scheduledNotification ?? this.scheduledNotification,
      notes: notes ?? this.notes,
      isPublishing: isPublishing ?? this.isPublishing,
      isPublished: isPublished ?? this.isPublished,
      publishError: publishError ?? this.publishError,
    );
  }

  @override
  List<Object?> get props => [
        playerA,
        playerB,
        discipline,
        round,
        bestOf,
        pointsPerSet,
        court,
        matchDate,
        matchTime,
        estimatedDuration,
        liveScoring,
        mediaRequest,
        scheduledNotification,
        notes,
        isPublishing,
        isPublished,
        publishError,
      ];
}
