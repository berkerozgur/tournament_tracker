import 'package:flutter/material.dart';

import 'matchup.dart';
import 'team.dart';

/// Represents a single entry in a tournament matchup, containing information
/// about a competing team, their score, and the parent matchup.
///
/// Used to track individual team performances within tournament brackets.
@immutable
class MatchupEntry {
  /// The team competing in this matchup entry
  final Team competing;

  /// Reference to the parent matchup this entry belongs to
  final Matchup parent;

  /// The score achieved by the team in this matchup
  /// Can be points, goals, or any numeric scoring metric
  final double score;

  const MatchupEntry({
    required this.competing,
    required this.parent,
    required this.score,
  });
}
