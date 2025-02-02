import 'package:flutter/material.dart';

import '../global_config.dart';
import '../models/prize.dart';
import '../models/team.dart';
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

  void _removeMemberFromSelectedList(Team team) {
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
                            AddToTeamsRow(
                              selectedTeam: _selectedTeam,
                              availableTeams: _availableTeams,
                              onTeamSelected: _selectTeam,
                              onTeamAdded: _addTeamToSelectedList,
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
                          child: SelectedTeamsList(
                            selectedTeams: _selectedTeams,
                            selectedTeam: _selectedTeam,
                            onTeamSelected: _selectTeam,
                            onTeamRemoved: _removeMemberFromSelectedList,
                          ),
                        ),
                        const SizedBox(height: 13.6),
                        Text(
                          'Prizes',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              const BorderedPrizesListView(),
                              const SizedBox(width: 13.6),
                              // TODO: Replace delete buttons with ListTile trailing remove icon for better UX
                              FilledButton(
                                onPressed: () {},
                                child: const Text('Delete selected'),
                              ),
                            ],
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

class AddToTeamsRow extends StatelessWidget {
  final Team? selectedTeam;
  final List<Team> availableTeams;
  final void Function(Team? team) onTeamSelected;
  final void Function(Team? team) onTeamAdded;
  const AddToTeamsRow({
    super.key,
    required this.selectedTeam,
    required this.availableTeams,
    required this.onTeamSelected,
    required this.onTeamAdded,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DropdownMenu(
          key: ValueKey(availableTeams.length),
          dropdownMenuEntries: availableTeams
              .map(
                (team) => DropdownMenuEntry<Team>(
                  value: team,
                  label: team.name,
                ),
              )
              .toList(),
          label: const Text('Select team'),
          onSelected: onTeamSelected,
          width: 136.6 * 2,
        ),
        const SizedBox(width: 13.6),
        FilledButton(
          onPressed: () {
            if (selectedTeam != null) {
              onTeamAdded(selectedTeam);
            }
          },
          child: const Text('Add team'),
        ),
      ],
    );
  }
}

class BorderedTeamsListView extends StatelessWidget {
  final List<Team>? selectedTeams;
  final Team? selectedTeam;
  final void Function(Team team)? onTeamSelected;

  const BorderedTeamsListView({
    super.key,
    required this.selectedTeams,
    required this.selectedTeam,
    required this.onTeamSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.3,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(4),
        ),
        child: ListView.builder(
          itemCount: selectedTeams?.length ?? 0,
          itemBuilder: (context, index) {
            final team = selectedTeams![index];
            return ListTile(
              onTap: () {
                onTeamSelected?.call(team);
              },
              selected: selectedTeam == team,
              title: Text(team.name),
            );
          },
        ),
      ),
    );
  }
}

class BorderedPrizesListView extends StatelessWidget {
  final List<Prize>? selectedPrizes;
  final Prize? selectedPrize;
  final void Function(Prize prize)? onPrizeSelected;

  const BorderedPrizesListView({
    super.key,
    this.selectedPrizes,
    this.selectedPrize,
    this.onPrizeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.3,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(4),
        ),
        child: ListView.builder(
          itemCount: selectedPrizes?.length ?? 0,
          itemBuilder: (context, index) {
            final prize = selectedPrizes![index];
            return ListTile(
              onTap: () {
                onPrizeSelected?.call(prize);
              },
              selected: selectedPrize == prize,
              title: Text(prize.placeName),
            );
          },
        ),
      ),
    );
  }
}

class SelectedTeamsList extends StatelessWidget {
  final List<Team> selectedTeams;
  final Team? selectedTeam;
  final void Function(Team member) onTeamSelected;
  final void Function(Team member) onTeamRemoved;

  const SelectedTeamsList({
    super.key,
    required this.selectedTeams,
    required this.selectedTeam,
    required this.onTeamSelected,
    required this.onTeamRemoved,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Teams',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Expanded(
          child: Row(
            children: [
              BorderedTeamsListView(
                selectedTeams: selectedTeams,
                selectedTeam: selectedTeam,
                onTeamSelected: onTeamSelected,
              ),
              const SizedBox(width: 13.6),
              FilledButton(
                onPressed: () {
                  if (selectedTeam != null) {
                    onTeamRemoved(selectedTeam!);
                  }
                },
                child: const Text('Delete selected'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
