import 'dart:developer' as dev;

import 'package:flutter/material.dart';

import '../global_config.dart';
import '../models/person.dart';
import '../models/team.dart';
import '../widgets/add_new_member_container.dart';
import '../widgets/shared/add_to_list_dropdown.dart';
import '../widgets/shared/selected_objects_list.dart';

class CreateTeam extends StatefulWidget {
  const CreateTeam({super.key});

  @override
  State<CreateTeam> createState() => _CreateTeamState();
}

class _CreateTeamState extends State<CreateTeam> {
  late final TextEditingController _teamName;
  final _formKey = GlobalKey<FormState>();
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
    _teamName = TextEditingController();
    _getAllPeople();
  }

  void _selectMember(Person? member) {
    setState(() {
      _selectedMember = member;
    });
  }

  void _addMemberToSelectedList(Person? member) {
    if (member != null) {
      setState(() {
        _availableMembers.remove(member);
        _selectedMembers.add(member);
        _selectedMember = null;
      });
    }
  }

  void _removeMemberFromSelectedList(Person member) {
    setState(() {
      _selectedMembers.remove(member);
      _availableMembers.add(member);
      _selectedMember = null;
    });
  }

  @override
  void dispose() {
    _teamName.dispose();
    super.dispose();
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
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _teamName,
                            decoration: const InputDecoration(
                              label: Text('Team name'),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value != null) {
                                if (_teamName.text.isEmpty) {
                                  return 'Please enter a team name';
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 13.6),
                          AddToListDropdown<Person>(
                            availableObjects: _availableMembers,
                            selectedObject: _selectedMember,
                            onObjectSelected: _selectMember,
                            onObjectAdded: _addMemberToSelectedList,
                            entryLabelBuilder: (object) => object.fullName,
                            dropdownLabelText: 'Select team member',
                            buttonText: 'Add member',
                          ),
                          const SizedBox(height: 13.6),
                          AddNewMemberContainer(
                            selectedMembers: _selectedMembers,
                            onMemberAdded: (member) {
                              setState(() {
                                _selectedMembers.add(member);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 13.6),
                    Expanded(
                      child: SelectedObjectsList<Person>(
                        selectedObjects: _selectedMembers,
                        listTitle: 'Selected team members',
                        listTileTitleBuilder: (person) => person.fullName,
                        onObjectRemoved: _removeMemberFromSelectedList,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 13.6 * 3),
              FilledButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    if (_selectedMembers.isEmpty) {
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Please select team members before creating the '
                              'team'),
                        ),
                      );
                      return;
                    }
                    final team = Team(
                      id: -1,
                      members: _selectedMembers,
                      name: _teamName.text,
                    );

                    final createdTeam =
                        await GlobalConfig.connection?.createTeam(team);

                    if (!mounted) return;
                    Navigator.pop(context, createdTeam);
                    // scaffoldMessenger.showSnackBar(
                    //   SnackBar(content: Text(createdTeam.toString())),
                    // );
                    dev.log(createdTeam.toString());
                  }
                },
                child: const Text('Create team'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
