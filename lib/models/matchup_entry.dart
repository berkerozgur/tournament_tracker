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

  factory MatchupEntry.fromJson(Map<String, dynamic> json) {
    return MatchupEntry(
      id: json['id'] as int,
      teamCompeting: json['teamCompeting'] != null
          ? Team.fromJson(json['teamCompeting'] as Map<String, dynamic>)
          : null,
      parent: json['parent'] != null
          ? Matchup.fromJson(json['parent'] as Map<String, dynamic>)
          : null,
      score: json['score'] != null ? (json['score'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teamCompeting': teamCompeting?.toJson(),
      'parent': parent?.toJson(),
      'score': score,
    };
  }

  @override
  String toString() => 'MatchupEntry(id: $id, competing: $teamCompeting, '
      'parent: $parent, score: $score)';
}
