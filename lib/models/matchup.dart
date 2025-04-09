import 'matchup_entry.dart';
import 'team.dart';

class Matchup {
  int id;
  final List<MatchupEntry> entries;
  int round;
  Team? winner;

  String get displayName {
    var displayName = '';
    for (var entry in entries) {
      if (entry.teamCompeting != null) {
        displayName = displayName.isEmpty
            ? entry.teamCompeting!.name
            : displayName += ' vs ${entry.teamCompeting!.name}';
      } else {
        displayName = 'Matchup not yet determined';
        break;
      }
    }
    return displayName;
  }

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
