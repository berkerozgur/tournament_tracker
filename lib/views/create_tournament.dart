import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../global_config.dart';
import '../models/prize.dart';
import '../models/team.dart';
import '../models/tournament.dart';
import '../tournament_logic.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_form_field.dart';
import '../widgets/headline_small_text.dart';
import 'create_prize_container.dart';
import 'create_team.dart';

class CreateTournament extends StatefulWidget {
  const CreateTournament({super.key});

  @override
  State<CreateTournament> createState() => _CreateTournamentState();
}

class _CreateTournamentState extends State<CreateTournament> {
  late final TextEditingController _entryFeeController;
  late final TextEditingController _tournamentNameController;
  final _formKey = GlobalKey<FormState>();
  final _selectedPrizes = <Prize>[];
  final _selectedTeams = <Team>[];
  List<Team> _availableTeams = [];
  Prize? _selectedPrize;
  Team? _selectedTeam;

  @override
  void initState() {
    super.initState();
    _entryFeeController = TextEditingController();
    _tournamentNameController = TextEditingController();
    _getAllTeams();
  }

  @override
  void dispose() {
    _entryFeeController.dispose();
    _tournamentNameController.dispose();
    super.dispose();
  }

  void _addPrize(Prize prize) {
    setState(() {
      _selectedPrize = prize;
      _selectedPrizes.add(_selectedPrize!);
    });
  }

  void _addTeam() {
    if (_selectedTeam != null) {
      setState(() {
        _availableTeams.remove(_selectedTeam);
        _selectedTeams.add(_selectedTeam!);
        _selectedTeam = null;
      });
    }
  }

  void _createPrizeOnPressed() async {
    // Call the CreatePrize
    // Get back a Prize
    final prize = await showDialog<Prize>(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text('Create prize'),
          content: CreatePrizeContainer(),
        );
      },
    );
    // Take the Prize and put it into selected prizes
    if (prize != null) {
      _addPrize(prize);
    }
  }

  void _createTeamOnPressed() async {
    final team = await showDialog<Team>(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text('Create team'),
          content: CreateTeam(),
        );
      },
    );
    if (team != null) {
      setState(() {
        _selectedTeams.add(team);
      });
    }
  }

  void _createTournamentOnPressed() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedTeams.isEmpty) {
        _showEmptyTeamsError();
        return;
      }

      final tournament = _createTournamentModel();

      // Wire matchups
      TournamentLogic.createRounds(tournament);

      // Create tournament entry
      // Create all of the prizes entries
      // Create all of the teams entries
      await GlobalConfig.connection.createTournament(tournament);
    }
  }

  Tournament _createTournamentModel() {
    final tournament = Tournament(
      id: -1,
      enteredTeams: _selectedTeams,
      entryFee: Decimal.parse(_entryFeeController.text),
      name: _tournamentNameController.text,
      prizes: _selectedPrizes,
      rounds: [],
    );
    return tournament;
  }

  Future<void> _getAllTeams() async {
    final teams = await GlobalConfig.connection.getAllTeams();
    setState(() {
      _availableTeams = teams;
    });
  }

  void _removePrize() {
    if (_selectedPrize != null) {
      setState(() {
        _selectedPrizes.remove(_selectedPrize);
      });
    }
  }

  void _removeTeam() {
    if (_selectedTeam != null) {
      setState(() {
        _selectedTeams.remove(_selectedTeam);
        _availableTeams.add(_selectedTeam!);
        _selectedTeam = null;
      });
    }
  }

  void _selectTeam(Team? team) {
    setState(() {
      _selectedTeam = team;
    });
  }

  void _showEmptyTeamsError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Please select teams before creating a tournament',
        ),
      ),
    );
  }

  String? _validateEntryFee(String? value) {
    if (value != null) {
      if (value.isEmpty) return null;
      final fee = Decimal.tryParse(value);
      if (fee != null && fee < Decimal.zero) {
        return 'Please enter a positive number or leave it empty';
      }
      return 'Please enter a number';
    }
    return null;
  }

  String? _validateTournamentName(String? value) {
    if (value != null && value.isEmpty) {
      return 'Please enter a tournament name';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Create Tournament'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tournament name and entry fee form
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextFormField(
                            controller: _tournamentNameController,
                            label: 'Tournament name',
                            validator: _validateTournamentName,
                          ),
                          const SizedBox(height: 16),
                          CustomTextFormField(
                            controller: _entryFeeController,
                            label: 'Entry fee',
                            validator: _validateEntryFee,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Team selection row
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            TeamsDropdown(
                              onSelected: _selectTeam,
                              teams: _availableTeams,
                            ),
                            const SizedBox(width: 16),
                            CustomButton(
                              buttonType: ButtonType.filled,
                              onPressed: _addTeam,
                              text: 'Add team',
                            ),
                            const SizedBox(width: 16),
                            const Text('or'),
                            const SizedBox(width: 8),
                            CustomButton(
                              buttonType: ButtonType.text,
                              onPressed: _createTeamOnPressed,
                              text: 'Create new team',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Teams and prizes section
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Selected teams section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const HeadlineSmallText(text: 'Selected teams'),
                          const SizedBox(height: 8),
                          Flexible(
                            child: SelectedTeams(
                              onPressed: _removeTeam,
                              teams: _selectedTeams,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Selected prizes section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const HeadlineSmallText(text: 'Selected prizes'),
                              CustomButton(
                                buttonType: ButtonType.text,
                                onPressed: _createPrizeOnPressed,
                                text: 'Create prize',
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Flexible(
                            child: SelectedPrizes(
                              onPressed: _removePrize,
                              prizes: _selectedPrizes,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Create tournament button
              CustomButton(
                buttonType: ButtonType.filled,
                onPressed: _createTournamentOnPressed,
                text: 'Create tournament',
                width: MediaQuery.of(context).size.width * 0.3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SelectedPrizes extends StatelessWidget {
  final VoidCallback? onPressed;
  final List<Prize> prizes;

  const SelectedPrizes({
    super.key,
    required this.onPressed,
    required this.prizes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: prizes.isEmpty
          ? const Center(
              child: Text('No prizes added'),
            )
          : ListView.builder(
              itemCount: prizes.length,
              itemBuilder: (context, index) {
                final prize = prizes[index];
                return ListTile(
                  title: Text(prize.placeName),
                  trailing: IconButton(
                    onPressed: onPressed,
                    icon: const Icon(Icons.remove_outlined),
                  ),
                );
              },
            ),
    );
  }
}

class SelectedTeams extends StatelessWidget {
  final VoidCallback? onPressed;
  final List<Team> teams;

  const SelectedTeams({
    super.key,
    required this.onPressed,
    required this.teams,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: teams.isEmpty
          ? const Center(
              child: Text('No teams selected'),
            )
          : ListView.builder(
              itemCount: teams.length,
              itemBuilder: (context, index) {
                final team = teams[index];
                return ListTile(
                  title: Text(team.name),
                  trailing: IconButton(
                    onPressed: onPressed,
                    icon: const Icon(Icons.remove_outlined),
                  ),
                );
              },
            ),
    );
  }
}

class TeamsDropdown extends StatelessWidget {
  final void Function(Team? team)? onSelected;
  final List<Team> teams;

  const TeamsDropdown({
    super.key,
    required this.onSelected,
    required this.teams,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownMenu(
      initialSelection: teams.isEmpty ? null : teams.first,
      dropdownMenuEntries: teams
          .map(
            (team) => DropdownMenuEntry(
              value: team,
              label: team.name,
            ),
          )
          .toList(),
      label: const Text('Select team'),
      onSelected: onSelected,
      width: MediaQuery.of(context).size.width * 0.25,
    );
  }
}
