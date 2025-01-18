import 'package:flutter/material.dart';

import 'person.dart';

@immutable
class Team {
  final List<Person> members;
  final String name;

  const Team({
    required this.members,
    required this.name,
  });
}
