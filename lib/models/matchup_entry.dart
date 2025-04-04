import 'matchup.dart';
import 'team.dart';

class MatchupEntry {
  int id;
  final Team? competing;
  final Matchup? parent;
  final double? score;

  MatchupEntry({
    required this.id,
    this.competing,
    this.parent,
    this.score,
  });

  @override
  String toString() => 'MatchupEntry(id: $id, competing: $competing, '
      'parent: $parent, score: $score)';
}
