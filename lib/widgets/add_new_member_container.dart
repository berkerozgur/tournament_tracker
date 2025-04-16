import 'dart:developer' as dev;

import 'package:flutter/material.dart';

import '../global_config.dart';
import '../models/person.dart';

// TODO: triggering all errors cause pixel overflow, fix it somehow
class AddNewMemberContainer extends StatefulWidget {
  final List<Person> selectedMembers;
  final void Function(Person member) onMemberAdded;

  const AddNewMemberContainer({
    super.key,
    required this.selectedMembers,
    required this.onMemberAdded,
  });

  @override
  State<AddNewMemberContainer> createState() => _AddNewMemberContainerState();
}

class _AddNewMemberContainerState extends State<AddNewMemberContainer> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _email;
  late final TextEditingController _phoneNumber;

  @override
  void initState() {
    super.initState();
    _firstName = TextEditingController();
    _lastName = TextEditingController();
    _email = TextEditingController();
    _phoneNumber = TextEditingController();
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phoneNumber.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add new member',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              // TODO: custom textformfield, custom validator maybe? this looks long
              TextFormField(
                controller: _firstName,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text('First name'),
                ),
                validator: (value) {
                  if (value != null) {
                    if (_firstName.text.isEmpty) {
                      return 'Please enter your first name';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 13.6),
              TextFormField(
                controller: _lastName,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text('Last name'),
                ),
                validator: (value) {
                  if (value != null) {
                    if (_lastName.text.isEmpty) {
                      return 'Please enter your last name';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 13.6),
              // TODO: Validate email using regex
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text('Email'),
                ),
                validator: (value) {
                  if (value != null) {
                    if (_email.text.isEmpty) {
                      return 'Please enter your email';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 13.6),
              TextFormField(
                controller: _phoneNumber,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text('Phone number'),
                ),
                validator: (value) {
                  if (value != null) {
                    if (_phoneNumber.text.isEmpty) {
                      return 'Please enter your phone number';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 13.6),
              Align(
                alignment: Alignment.center,
                child: FilledButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      // TODO: need something better for the ids
                      var person = Person(
                        id: -1,
                        emailAddress: _email.text,
                        firstName: _firstName.text,
                        lastName: _lastName.text,
                        phoneNumber: _phoneNumber.text,
                      );

                      final createdPerson =
                          await GlobalConfig.connection.createPerson(person);
                      dev.log(createdPerson.toString());
                      widget.onMemberAdded(createdPerson);

                      _email.clear();
                      _firstName.clear();
                      _lastName.clear();
                      _phoneNumber.clear();
                    }
                  },
                  child: const Text('Create member'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
