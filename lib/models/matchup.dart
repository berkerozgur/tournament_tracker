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

  factory Matchup.fromJson(Map<String, dynamic> json) {
    return Matchup(
      id: json['id'] as int,
      entries: (json['entries'] as List<dynamic>)
          .map((entry) => MatchupEntry.fromJson(entry as Map<String, dynamic>))
          .toList(),
      round: json['round'] as int,
      winner: json['winner'] != null
          ? Team.fromJson(json['winner'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entries': entries.map((entry) => entry.toJson()).toList(),
      'round': round,
      'winner': winner?.toJson(),
    };
  }

  @override
  String toString() =>
      'Matchup(id: $id, entries: $entries, round: $round, winner: $winner)';
}
