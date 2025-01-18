import 'package:decimal/decimal.dart' show Decimal;
import 'package:flutter/material.dart';

import 'matchup.dart';
import 'prize.dart';
import 'team.dart';

@immutable
class Tournament {
  final List<Team> enteredTeams;
  final Decimal entryFee;
  final String name;
  final List<Prize> prizes;
  final List<List<Matchup>> rounds;

  const Tournament({
    required this.enteredTeams,
    required this.entryFee,
    required this.name,
    required this.prizes,
    required this.rounds,
  });
}
