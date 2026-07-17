import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:learnflutter/core/cubit/base_cubit.dart';
import 'package:learnflutter/features/match_entry/models/player_model.dart';

part 'match_entry_state.dart';

class MatchEntryCubit extends BaseCubit<MatchEntryState> {
  static const List<PlayerModel> players = [
    PlayerModel(
      id: 1,
      name: 'Nguyễn Tiến Minh',
      seed: 1,
      country: 'VIE',
      side: 'R',
      age: 27,
      rank: 1,
      initials: 'NM',
    ),
    PlayerModel(
      id: 2,
      name: 'Mikkel Holst',
      seed: 2,
      country: 'DEN',
      side: 'L',
      age: 25,
      rank: 2,
      initials: 'MH',
    ),
    PlayerModel(
      id: 3,
      name: 'Ravi Singh',
      seed: 5,
      country: 'IND',
      side: 'R',
      age: 24,
      rank: 6,
      initials: 'RS',
    ),
    PlayerModel(
      id: 4,
      name: 'Vũ Thị Trang',
      seed: 1,
      country: 'VIE',
      side: 'R',
      age: 24,
      rank: 1,
      initials: 'VT',
    ),
    PlayerModel(
      id: 5,
      name: 'Lin Zhao',
      seed: 3,
      country: 'CHN',
      side: 'L',
      age: 26,
      rank: 3,
      initials: 'LZ',
    ),
    PlayerModel(
      id: 6,
      name: 'Helena Petersen',
      seed: 4,
      country: 'DEN',
      side: 'R',
      age: 23,
      rank: 5,
      initials: 'HP',
    ),
    PlayerModel(
      id: 7,
      name: 'Kenta Sato',
      seed: 7,
      country: 'JPN',
      side: 'R',
      age: 29,
      rank: 9,
      initials: 'KS',
    ),
    PlayerModel(
      id: 8,
      name: 'Liu Wei',
      seed: 6,
      country: 'CHN',
      side: 'R',
      age: 28,
      rank: 7,
      initials: 'LW',
    ),
    PlayerModel(
      id: 9,
      name: 'Lê Đức Phát',
      seed: 11,
      country: 'VIE',
      side: 'L',
      age: 25,
      rank: 14,
      initials: 'LP',
    ),
    PlayerModel(
      id: 10,
      name: 'Eun-ji Park',
      seed: 9,
      country: 'KOR',
      side: 'R',
      age: 22,
      rank: 11,
      initials: 'EP',
    ),
    PlayerModel(
      id: 11,
      name: 'Carlos Mendoza',
      seed: 14,
      country: 'ESP',
      side: 'R',
      age: 30,
      rank: 18,
      initials: 'CM',
    ),
    PlayerModel(
      id: 12,
      name: 'Pranav Iyer',
      seed: 18,
      country: 'IND',
      side: 'R',
      age: 21,
      rank: 24,
      initials: 'PI',
    ),
  ];

  MatchEntryCubit()
      : super(MatchEntryState(
          matchDate: DateTime.now().add(const Duration(days: 1)),
          matchTime: const TimeOfDay(hour: 20, minute: 0),
        ));

  // Player selection
  void selectPlayerA(PlayerModel player) {
    emit(state.copyWith(playerA: player));
  }

  void clearPlayerA() {
    emit(state.copyWith(playerA: null));
  }

  void selectPlayerB(PlayerModel player) {
    emit(state.copyWith(playerB: player));
  }

  void clearPlayerB() {
    emit(state.copyWith(playerB: null));
  }

  // Match details
  void setDiscipline(String discipline) {
    emit(state.copyWith(discipline: discipline));
  }

  void setRound(String round) {
    emit(state.copyWith(round: round));
  }

  void setBestOf(int bestOf) {
    emit(state.copyWith(bestOf: bestOf));
  }

  void setPointsPerSet(int pointsPerSet) {
    emit(state.copyWith(pointsPerSet: pointsPerSet));
  }

  void setCourt(String court) {
    emit(state.copyWith(court: court));
  }

  void setMatchDate(DateTime matchDate) {
    emit(state.copyWith(matchDate: matchDate));
  }

  void setMatchTime(TimeOfDay matchTime) {
    emit(state.copyWith(matchTime: matchTime));
  }

  void setEstimatedDuration(String estimatedDuration) {
    emit(state.copyWith(estimatedDuration: estimatedDuration));
  }

  // Settings
  void toggleLiveScoring() {
    emit(state.copyWith(liveScoring: !state.liveScoring));
  }

  void toggleMediaRequest() {
    emit(state.copyWith(mediaRequest: !state.mediaRequest));
  }

  void toggleScheduledNotification() {
    emit(state.copyWith(scheduledNotification: !state.scheduledNotification));
  }

  void setNotes(String notes) {
    emit(state.copyWith(notes: notes));
  }

  // Actions
  Future<void> publishMatch() async {
    emit(state.copyWith(isPublishing: true));
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      emit(state.copyWith(isPublishing: false, isPublished: true));
      await Future.delayed(const Duration(seconds: 2));
      // Reset if needed
    } catch (e) {
      emit(state.copyWith(isPublishing: false, publishError: 'Lỗi công bố'));
    }
  }

  void saveDraft() {
    // Save to local storage
  }

  void cancel() {
    // Reset state
    emit(MatchEntryState(
      matchDate: DateTime.now().add(const Duration(days: 1)),
      matchTime: const TimeOfDay(hour: 20, minute: 0),
    ));
  }
}
