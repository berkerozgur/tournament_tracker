import 'matchup_entry.dart';
import 'team.dart';

class Matchup {
  int id;
  final List<MatchupEntry> entries;
  int round;
  final Team? winner;

  Matchup({
    required this.id,
    required this.entries,
    required this.round,
    this.winner,
  });

  Matchup.empty()
      : id = -1,
        entries = [],
        round = -1,
        winner = null;

  @override
  String toString() =>
      'Matchup(id: $id, entries: $entries, round: $round, winner: $winner)';
}
