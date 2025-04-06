import 'matchup.dart';
import 'team.dart';

class MatchupEntry {
  int id;
  final Team? teamCompeting;
  final Matchup? parent;
  final double? score;

  MatchupEntry({
    required this.id,
    this.teamCompeting,
    this.parent,
    this.score,
  });

  @override
  String toString() => 'MatchupEntry(id: $id, competing: $teamCompeting, '
      'parent: $parent, score: $score)';
}
