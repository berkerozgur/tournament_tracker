import 'package:flutter/material.dart';

import 'person.dart';

/// Represents a team participating in a tournament.
///
/// A team consists of:
/// * A unique team name
/// * One or more team members
@immutable
class Team {
  /// List of team members
  /// Must contain at least one person
  final List<Person> members;

  /// Unique name identifying the team
  final String name;

  const Team({
    required this.members,
    required this.name,
  });
}
