import 'package:flutter/material.dart';

/// Represents a person in the tournament tracking system with their contact details.
///
/// This immutable class stores basic personal information and contact details
/// for tournament participants, organizers, or other system users.
@immutable
class Person {
  /// Email address of the person
  /// Should be a valid email format
  final String emailAddress;

  /// First/given name of the person
  final String firstName;

  /// Last/family name of the person
  final String lastName;

  /// Contact phone number
  /// Should include country code and be properly formatted
  final String phoneNumber;

  const Person({
    required this.emailAddress,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
  });
}
