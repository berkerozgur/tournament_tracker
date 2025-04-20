import 'displayable.dart';
import 'person.dart';

class Team with Displayable {
  int id;
  final List<Person> members;
  final String name;

  Team({
    required this.id,
    required this.members,
    required this.name,
  });

  @override
  String toString() => 'Team(id: $id, members: $members, name: $name)';
}
