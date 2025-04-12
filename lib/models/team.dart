import 'person.dart';

class Team {
  int id;
  final List<Person> members;
  final String name;

  Team({
    required this.id,
    required this.members,
    required this.name,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] as int,
      members: (json['members'] as List<dynamic>)
          .map((member) => Person.fromJson(member as Map<String, dynamic>))
          .toList(),
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'members': members.map((member) => member.toJson()).toList(),
      'name': name,
    };
  }

  @override
  String toString() => 'Team(id: $id, members: $members, name: $name)';
}
