import 'package:flutter/material.dart';

import 'matchup.dart';
import 'team.dart';

@immutable
class MatchupEntry {
  final Team competing;
  final Matchup parent;
  final double score;

  const MatchupEntry({
    required this.competing,
    required this.parent,
    required this.score,
  });
}
