/// Represents a person in the tournament tracking system with their contact details.
///
/// This immutable class stores basic personal information and contact details
/// for tournament participants, organizers, or other system users.
class Person {
  /// Unique identifier for the person.
  int id;

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

  Person({
    required this.id,
    required this.emailAddress,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
  });

  @override
  String toString() {
    return 'Person(id: $id, firstName: $firstName, lastName: $lastName, '
        'emailAddress: $emailAddress, phoneNumber: $phoneNumber)';
  }
}
