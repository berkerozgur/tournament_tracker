import 'package:decimal/decimal.dart' show Decimal;

import 'matchup.dart';
import 'prize.dart';
import 'team.dart';

class Tournament {
  int id;
  final List<Team> enteredTeams;
  final Decimal entryFee;
  final String name;
  final List<Prize> prizes;
  final List<List<Matchup>> rounds;

  Tournament({
    required this.id,
    required this.enteredTeams,
    required this.entryFee,
    required this.name,
    required this.prizes,
    required this.rounds,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'] as int,
      enteredTeams: (json['enteredTeams'] as List<dynamic>)
          .map((team) => Team.fromJson(team as Map<String, dynamic>))
          .toList(),
      entryFee: Decimal.parse(json['entryFee'] as String),
      name: json['name'] as String,
      prizes: (json['prizes'] as List<dynamic>)
          .map((prize) => Prize.fromJson(prize as Map<String, dynamic>))
          .toList(),
      rounds: (json['rounds'] as List<dynamic>)
          .map((round) => (round as List<dynamic>)
              .map((matchup) =>
                  Matchup.fromJson(matchup as Map<String, dynamic>))
              .toList())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'enteredTeams': enteredTeams.map((team) => team.toJson()).toList(),
      'entryFee': entryFee.toString(),
      'name': name,
      'prizes': prizes.map((prize) => prize.toJson()).toList(),
      'rounds': rounds
          .map((round) => round.map((matchup) => matchup.toJson()).toList())
          .toList(),
    };
  }

  @override
  String toString() => 'Tournament(id: $id, enteredTeams: $enteredTeams, '
      'entryFee: $entryFee, name: $name, prizes: $prizes, rounds: $rounds)';
}
