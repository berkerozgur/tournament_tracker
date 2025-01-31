import 'dart:developer' as dev;

import 'package:flutter/material.dart';

import '../global_config.dart';
import '../models/person.dart';
import '../widgets/bordered_list_view.dart';

class CreateTeam extends StatefulWidget {
  const CreateTeam({super.key});

  @override
  State<CreateTeam> createState() => _CreateTeamState();
}

class _CreateTeamState extends State<CreateTeam> {
  var _availableMembers = <Person>[];
  final _selectedMembers = <Person>[];
  Person? _selectedMember;

  Future<void> _getAllPeople() async {
    final availableMembers = await GlobalConfig.connection!.getAllPeople();
    setState(() {
      _availableMembers = availableMembers;
    });
  }

  @override
  void initState() {
    super.initState();
    // _createSampleData();
    _getAllPeople();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Create Team'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const TextField(
                          decoration: InputDecoration(
                            label: Text('Team name'),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 13.6),
                        Row(
                          children: [
                            DropdownMenu(
                              key: ValueKey(_availableMembers.length),
                              dropdownMenuEntries: _availableMembers
                                  .map(
                                    (person) => DropdownMenuEntry<Person>(
                                      value: person,
                                      label: person.fullName,
                                    ),
                                  )
                                  .toList(),
                              label: const Text('Select team member'),
                              onSelected: (value) {
                                setState(() {
                                  _selectedMember = value;
                                });
                              },
                              width: 136.6 * 2,
                            ),
                            const SizedBox(width: 13.6),
                            FilledButton(
                              onPressed: () {
                                if (_selectedMember != null) {
                                  setState(() {
                                    _availableMembers.remove(_selectedMember);
                                    _selectedMembers.add(_selectedMember!);
                                    _selectedMember = null;
                                  });
                                }
                              },
                              child: const Text('Add member'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 13.6),
                        AddNewMemberContainer(
                            selectedMembers: _selectedMembers,
                            onMemberAdded: (person) {
                              setState(() {
                                _selectedMembers.add(person);
                              });
                            })
                      ],
                    ),
                  ),
                  const SizedBox(width: 13.6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Team members',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              BorderedListView(
                                onMemberSelected: (member) {
                                  setState(() {
                                    _selectedMember = member;
                                  });
                                },
                                selectedMembers: _selectedMembers,
                                selectedMember: _selectedMember,
                              ),
                              const SizedBox(width: 13.6),
                              FilledButton(
                                onPressed: () {
                                  if (_selectedMember != null) {
                                    setState(() {
                                      _selectedMembers.remove(_selectedMember);
                                      _availableMembers.add(_selectedMember!);
                                      _selectedMember = null;
                                    });
                                  }
                                },
                                child: const Text('Remove selected'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 13.6 * 3),
            FilledButton(
              onPressed: () {},
              child: const Text('Create team'),
            ),
          ],
        ),
      ),
    );
  }
}

// TODO: triggering all errors cause pixel overflow, fix it somehow
class AddNewMemberContainer extends StatefulWidget {
  final List<Person> selectedMembers;
  final void Function(Person person) onMemberAdded;

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
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      // TODO: need something better for the ids
                      var person = Person(
                        id: -1,
                        emailAddress: _email.text,
                        firstName: _firstName.text,
                        lastName: _lastName.text,
                        phoneNumber: _phoneNumber.text,
                      );

                      final createdPerson =
                          await GlobalConfig.connection?.createPerson(person);

                      if (!mounted) return;
                      scaffoldMessenger.showSnackBar(
                        SnackBar(content: Text('Person: $createdPerson')),
                      );

                      widget.onMemberAdded(createdPerson!);
                      dev.log(createdPerson.toString());

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
