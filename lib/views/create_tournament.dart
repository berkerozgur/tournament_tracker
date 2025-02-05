import 'package:flutter/material.dart';

import '../global_config.dart';
import '../models/team.dart';
import '../widgets/shared/add_to_list_dropdown.dart';
import '../widgets/shared/selected_objects_list.dart';
import '../widgets/custom_text_form_field.dart';

class CreateTournament extends StatefulWidget {
  const CreateTournament({super.key});

  @override
  State<CreateTournament> createState() => _CreateTournamentState();
}

class _CreateTournamentState extends State<CreateTournament> {
  var _availableTeams = <Team>[];
  final _selectedTeams = <Team>[];
  Team? _selectedTeam;

  @override
  void initState() {
    super.initState();
    _getAllTeams();
  }

  Future<void> _getAllTeams() async {
    final availableTeams = await GlobalConfig.connection?.getAllTeams();
    setState(() {
      _availableTeams = availableTeams!;
    });
  }

  void _selectTeam(Team? team) {
    setState(() {
      _selectedTeam = team;
    });
  }

  void _addTeamToSelectedList(Team? team) {
    if (team != null) {
      setState(() {
        _availableTeams.remove(team);
        _selectedTeams.add(team);
        _selectedTeam = null;
      });
    }
  }

  void _removeTeamFromSelectedList(Team team) {
    setState(() {
      _selectedTeams.remove(team);
      _availableTeams.add(team);
      _selectedTeam = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Create Tournament'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
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
                            label: Text('Tournament name'),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 13.6),
                        const CustomTextFormField(label: 'Entry fee'),
                        const SizedBox(height: 13.6),
                        Row(
                          children: [
                            AddToListDropdown<Team>(
                              availableObjects: _availableTeams,
                              selectedObject: _selectedTeam,
                              onObjectSelected: _selectTeam,
                              onObjectAdded: _addTeamToSelectedList,
                              entryLabelBuilder: (object) => object.name,
                              dropdownLabelText: 'Select team',
                              buttonText: 'Add team',
                            ),
                            const SizedBox(width: 13.6),
                            const Text('or'),
                            TextButton(
                              onPressed: () {},
                              child: const Text('Create new team'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 136),
                        FilledButton(
                          onPressed: () {},
                          child: const Text('Create prize'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 13.6),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: SelectedObjectsList<Team>(
                            selectedObjects: _selectedTeams,
                            listTitle: 'Selected teams',
                            listTileTitleBuilder: (team) => team.name,
                            onObjectRemoved: _removeTeamFromSelectedList,
                          ),
                        ),
                        const SizedBox(height: 13.6),
                        // TODO: dont forget to change this to prizes when the time comes
                        Expanded(
                          child: SelectedObjectsList<Team>(
                            selectedObjects: _selectedTeams,
                            listTitle: 'Prizes',
                            listTileTitleBuilder: (team) => team.name,
                            onObjectRemoved: _removeTeamFromSelectedList,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 13.6 * 3),
            FilledButton(
              onPressed: () {},
              child: const Text('Create tournament'),
            ),
          ],
        ),
      ),
    );
  }
}
