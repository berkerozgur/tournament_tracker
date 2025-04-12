class Person {
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

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] as int,
      emailAddress: json['emailAddress'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phoneNumber: json['phoneNumber'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'emailAddress': emailAddress,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
    };
  }

  @override
  String toString() =>
      'Person(id: $id, emailAddress: $emailAddress, firstName: $firstName, '
      'lastName: $lastName, phoneNumber: $phoneNumber)';
}
