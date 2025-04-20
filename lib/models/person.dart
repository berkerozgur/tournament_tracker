import 'displayable.dart';

class Person with Displayable {
  int id;
  final String emailAddress;
  final String firstName;
  final String lastName;
  final String phoneNumber;

  String get fullName => '$firstName $lastName';

  Person({
    required this.id,
    required this.emailAddress,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
  });

  @override
  String toString() =>
      'Person(id: $id, emailAddress: $emailAddress, firstName: $firstName, '
      'lastName: $lastName, phoneNumber: $phoneNumber)';
}
