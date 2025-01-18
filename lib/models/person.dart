import 'package:flutter/material.dart';

@immutable
class Person {
  final String emailAddress;
  final String firstName;
  final String lastName;
  final String phoneNumber;

  const Person({
    required this.emailAddress,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
  });
}
