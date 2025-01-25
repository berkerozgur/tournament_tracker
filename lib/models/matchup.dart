import 'package:flutter/material.dart';

import 'matchup_entry.dart';
import 'team.dart';

/// Represents a single matchup/game in a tournament bracket between two teams.
///
/// A matchup contains:
/// * List of competing teams ([entries])
/// * Tournament round number ([round])
/// * Winning team ([winner])
@immutable
class Matchup {
  /// The competing teams in this matchup, typically 2 entries for standard tournaments
  final List<MatchupEntry> entries;

  /// The tournament round number this matchup belongs to
  /// Round 1 represents first matches, increases as tournament progresses
  final int round;

  /// The team that won this matchup and advances to next round
  final Team winner;

  const Matchup({
    required this.entries,
    required this.round,
    required this.winner,
  });
}
