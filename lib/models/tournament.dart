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

  @override
  String toString() => 'Tournament(id: $id, enteredTeams: $enteredTeams, '
      'entryFee: $entryFee, name: $name, prizes: $prizes, rounds: $rounds)';
}
