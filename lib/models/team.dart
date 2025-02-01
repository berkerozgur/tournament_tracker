import 'person.dart';

/// Represents a team participating in a tournament.
///
/// A team consists of:
/// * A unique identifier for the team
/// * One or more team members
/// * A unique team name
class Team {
  /// The unique identifier for the team.
  int id;

  /// List of team members
  /// Must contain at least one person
  final List<Person> members;

  /// Unique name identifying the team
  final String name;

  Team({
    required this.id,
    required this.members,
    required this.name,
  });

  /// Returns a string representation of the `Team` object.
  ///
  /// The returned string includes the `id`, `name`, and `members` of the team.
  ///
  /// Example:
  /// ```dart
  /// Team{id: 1, name: "Team A", members: ["Alice", "Bob"]}
  /// ```
  @override
  String toString() {
    return 'Team{id: $id, name: $name, members: $members}';
  }
}
