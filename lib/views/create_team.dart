import 'package:flutter/material.dart';

import '../global_config.dart';
import '../models/person.dart';
import '../models/team.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_form_field.dart';
import '../widgets/generic_dropdown.dart';
import '../widgets/generic_list_view.dart';
import 'create_new_member.dart';

class CreateTeam extends StatefulWidget {
  const CreateTeam({super.key});

  @override
  State<CreateTeam> createState() => _CreateTeamState();
}

class _CreateTeamState extends State<CreateTeam> {
  late final TextEditingController _teamNameController;
  final _formKey = GlobalKey<FormState>();
  final _selectedMembers = <Person>[];
  List<Person> _availableMembers = [];
  Person? _selectedMember;

  @override
  void initState() {
    super.initState();
    _teamNameController = TextEditingController();
    _getAllPeople();
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    super.dispose();
  }

  void _addMember() {
    setState(() {
      _selectedMember ??= _availableMembers.first;
      _availableMembers.remove(_selectedMember);
      _selectedMembers.add(_selectedMember!);
      _selectedMember = null;
    });
  }

  void _createTeamOnPressed() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedMembers.isEmpty) {
        _showEmptyTeamMembersError();
        return;
      }

      final team = Team(
        id: -1,
        members: _selectedMembers,
        name: _teamNameController.text,
      );

      final createdTeam = await GlobalConfig.connection.createTeam(team);
      if (!mounted) return;
      Navigator.pop(context, createdTeam);
    }
  }

  Future<void> _getAllPeople() async {
    final people = await GlobalConfig.connection.getAllPeople();
    setState(() {
      _availableMembers = people;
    });
  }

  void _removeMember(Person member) {
    setState(() {
      _selectedMember = member;
      _selectedMembers.remove(_selectedMember);
      _availableMembers.add(_selectedMember!);
    });
  }

  void _selectMember(Person? member) {
    setState(() {
      _selectedMember = member;
    });
  }

  void _showEmptyTeamMembersError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please select team members before creating a team'),
      ),
    );
  }

  String? _validateTeamName(String? value) {
    if (value != null && value.isEmpty) {
      return 'Please enter a team name';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Form(
                  key: _formKey,
                  child: CustomTextFormField(
                    controller: _teamNameController,
                    label: 'Team name',
                    validator: _validateTeamName,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  children: [
                    GenericDropdown<Person>(
                      onSelected: _selectMember,
                      models: _availableMembers,
                    ),
                    const SizedBox(width: 16),
                    CustomButton(
                      buttonType: ButtonType.filled,
                      enabled: _availableMembers.isNotEmpty,
                      onPressed: _addMember,
                      text: 'Add member',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: CreateNewMember(
                          onMemberCreated: (member) {
                            setState(() {
                              _selectedMembers.add(member);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: GenericListView<Person>(
                    iconButtonOnPressed: _removeMember,
                    models: _selectedMembers,
                    // selectedT: _selectedMember,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            buttonType: ButtonType.filled,
            onPressed: _createTeamOnPressed,
            text: 'Create team',
            width: MediaQuery.of(context).size.width * 0.3,
          ),
        ],
      ),
    );
  }
}
