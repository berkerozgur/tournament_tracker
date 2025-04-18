import 'package:flutter/material.dart';

import '../global_config.dart';
import '../models/person.dart';
import '../models/team.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_form_field.dart';
import '../widgets/headline_small_text.dart';

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
    if (_selectedMember != null) {
      setState(() {
        _availableMembers.remove(_selectedMember);
        _selectedMembers.add(_selectedMember!);
        _selectedMember = null;
      });
    }
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

  void _removeMember() {
    if (_selectedMember != null) {
      setState(() {
        _selectedMembers.remove(_selectedMember);
        _availableMembers.add(_selectedMember!);
        _selectedMember = null;
      });
    }
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
              TeamMembersDropdown(
                onSelected: _selectMember,
                members: _availableMembers,
              ),
              const SizedBox(width: 16),
              CustomButton(
                buttonType: ButtonType.filled,
                onPressed: _addMember,
                text: 'Add member',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HeadlineSmallText(text: 'Create new member'),
                      Flexible(
                        child: CreateNewMember(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const HeadlineSmallText(text: 'Selected team members'),
                      Flexible(
                        child: SelectedTeamMembers(
                          onPressed: _removeMember,
                          members: _selectedMembers,
                        ),
                      ),
                    ],
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

class CreateNewMember extends StatefulWidget {
  const CreateNewMember({super.key});

  @override
  State<CreateNewMember> createState() => _CreateNewMemberState();
}

class _CreateNewMemberState extends State<CreateNewMember> {
  late final TextEditingController _emailController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _createNewMember() {}

  String? _validateEmailAddress(String? value) {
    return null;
  }

  String? _validateFirstName(String? value) {
    return null;
  }

  String? _validateLastName(String? value) {
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextFormField(
                controller: _firstNameController,
                isOutlined: false,
                label: 'First name',
                validator: _validateFirstName,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: _lastNameController,
                isOutlined: false,
                label: 'Last name',
                validator: _validateLastName,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: _phoneController,
                label: 'Phone number',
                validator: _validatePhoneNumber,
                isOutlined: false,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: _emailController,
                label: 'Email address',
                validator: _validateEmailAddress,
                isOutlined: false,
              ),
              const Spacer(),
              CustomButton(
                buttonType: ButtonType.filled,
                onPressed: _createNewMember,
                text: 'Create new member',
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class TeamMembersDropdown extends StatelessWidget {
  final void Function(Person? member)? onSelected;
  final List<Person> members;

  const TeamMembersDropdown({
    super.key,
    required this.onSelected,
    required this.members,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownMenu(
      initialSelection: members.isEmpty ? null : members.first,
      dropdownMenuEntries: members
          .map(
            (member) => DropdownMenuEntry(
              value: member,
              label: member.fullName,
            ),
          )
          .toList(),
      label: const Text('Select member'),
      onSelected: onSelected,
      width: MediaQuery.of(context).size.width * 0.25,
    );
  }
}

class SelectedTeamMembers extends StatelessWidget {
  final VoidCallback? onPressed;
  final List<Person> members;

  const SelectedTeamMembers({
    super.key,
    required this.onPressed,
    required this.members,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: members.isEmpty
          ? const Center(
              child: Text('No members selected'),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final member = members[index];
                  return ListTile(
                    title: Text(member.fullName),
                    trailing: IconButton(
                      onPressed: onPressed,
                      icon: const Icon(Icons.remove_outlined),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
