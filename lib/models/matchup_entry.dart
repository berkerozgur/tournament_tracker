import 'matchup.dart';
import 'team.dart';

class MatchupEntry {
  int id;
  Team? teamCompeting;
  final Matchup? parent;
  double? score;

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
