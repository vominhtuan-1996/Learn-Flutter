import 'package:equatable/equatable.dart';

class PlayerModel extends Equatable {
  final int id;
  final String name;
  final int seed;
  final String country;
  final String side; // 'L' (tay trái) | 'R' (tay phải)
  final int age;
  final int rank;
  final String initials;

  const PlayerModel({
    required this.id,
    required this.name,
    required this.seed,
    required this.country,
    required this.side,
    required this.age,
    required this.rank,
    required this.initials,
  });

  String get handedness => side == 'L' ? 'Tay trái' : 'Tay phải';

  @override
  List<Object?> get props => [id, name, seed, country, side, age, rank, initials];
}
