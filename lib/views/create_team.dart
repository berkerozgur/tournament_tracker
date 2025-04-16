import 'dart:developer' as dev;

import 'package:flutter/material.dart';

import '../global_config.dart';
import '../models/person.dart';
import '../models/team.dart';
import '../widgets/add_new_member_container.dart';
import '../widgets/custom_text_form_field.dart';

class CreateTeam extends StatefulWidget {
  const CreateTeam({super.key});

  @override
  State<CreateTeam> createState() => _CreateTeamState();
}

class _CreateTeamState extends State<CreateTeam> {
  late final TextEditingController _teamName;
  final _formKey = GlobalKey<FormState>();
  final _selectedMembers = <Person>[];
  var _availableMembers = <Person>[];
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
        padding: const EdgeInsets.all(13.6),
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
                          // TODO: Prevent users from entering "," for the name
                          // Team name
                          CustomTextFormField(
                            controller: _teamName,
                            label: 'Team name',
                            validator: (value) {
                              if (value != null && value.isEmpty) {
                                return 'Please enter a team name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 13.6),
                          Row(
                            children: [
                              // Available members dropdown
                              DropdownMenu(
                                key: ValueKey(_availableMembers.length),
                                dropdownMenuEntries: _availableMembers
                                    .map(
                                      (member) => DropdownMenuEntry(
                                        value: member,
                                        label: member.fullName,
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
                              // Add member button
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Selected team members',
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                            ],
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: ListView.builder(
                                itemCount: _selectedMembers.length,
                                itemBuilder: (context, index) {
                                  final member = _selectedMembers[index];
                                  return ListTile(
                                    title: Text(member.fullName),
                                    trailing: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _selectedMember = member;
                                          _selectedMembers
                                              .remove(_selectedMember);
                                          _availableMembers
                                              .add(_selectedMember!);
                                          _selectedMember = null;
                                        });
                                      },
                                      icon: const Icon(Icons.remove_outlined),
                                    ),
                                  );
                                },
                              ),
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
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    if (_selectedMembers.isEmpty) {
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please select team members before creating a team',
                          ),
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
                    dev.log(createdTeam.toString());
                    if (!mounted) return;
                    Navigator.pop(context, createdTeam);
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
