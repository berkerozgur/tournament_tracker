import 'package:flutter/material.dart';

import 'matchup_entry.dart';
import 'team.dart';

@immutable
class Matchup {
  final List<MatchupEntry> entries;
  final int round;
  final Team winner;

  const Matchup({
    required this.entries,
    required this.round,
    required this.winner,
  });
}
