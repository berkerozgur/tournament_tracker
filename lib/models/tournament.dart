import 'package:decimal/decimal.dart' show Decimal;

import 'matchup.dart';
import 'prize.dart';
import 'team.dart';

/// Represents a tournament with teams, matchups, and prize structure.
///
/// A tournament contains:
/// * List of participating teams
/// * Entry fee per team
/// * Tournament name
/// * Prize structure
/// * Tournament rounds and matchups
///
/// The [rounds] field is a nested list where:
/// * Outer list represents tournament rounds (1st round, 2nd round, etc.)
/// * Inner list contains matchups within each round
class Tournament {
  /// The unique identifier for the tournament.
  int id;

  /// List of teams participating in the tournament
  /// Must have at least 2 teams for a valid tournament
  final List<Team> enteredTeams;

  /// Entry fee per team in decimal format for precise monetary calculations
  final Decimal entryFee;

  /// Unique name identifying the tournament
  final String name;

  /// List of prizes to be awarded
  /// Should correspond to final placements
  final List<Prize> prizes;

  /// Nested list representing tournament rounds and their matchups
  /// rounds[0] represents first round matchups
  /// rounds[1] represents second round matchups, etc.
  final List<List<Matchup>> rounds;

  Tournament({
    required this.id,
    required this.enteredTeams,
    required this.entryFee,
    required this.name,
    required this.prizes,
    required this.rounds,
  });
}
