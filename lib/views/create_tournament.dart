import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../global_config.dart';
import '../models/prize.dart';
import '../models/team.dart';
import '../models/tournament.dart';
import '../tournament_logic.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_form_field.dart';
import '../widgets/generic_list_view.dart';
import 'create_prize.dart';
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

  void _addTeam() {
    if (_selectedTeam != null) {
      setState(() {
        _availableTeams.remove(_selectedTeam);
        _selectedTeams.add(_selectedTeam!);
        _selectedTeam = null;
      });
    }
  }

  void _showCreatePrizeDialog() async {
    // Call the CreatePrize
    // Get back a Prize
    final prize = await showDialog<Prize>(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text('Create prize'),
          content: CreatePrize(),
        );
      },
    );
    // Take the Prize and put it into selected prizes
    if (prize != null) {
      setState(() {
        _selectedPrizes.add(prize);
      });
    }
  }

  void _showCreateTeamDialog() async {
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

  void _removePrize(Prize prize) {
    setState(() {
      _selectedPrize = prize;
      _selectedPrizes.remove(_selectedPrize);
    });
  }

  void _removeTeam(Team team) {
    setState(() {
      _selectedTeam = team;
      _selectedTeams.remove(_selectedTeam);
      _availableTeams.add(_selectedTeam!);
    });
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
                          const SizedBox(height: 8),
                          Flexible(
                            child: GenericListView<Team>(
                              headlineButtonOnPressed: _showCreateTeamDialog,
                              iconButtonOnPressed: _removeTeam,
                              models: _selectedTeams,
                              // selectedTeam: _selectedTeam,
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
                          const SizedBox(height: 8),
                          Flexible(
                            child: GenericListView<Prize>(
                              headlineButtonOnPressed: _showCreatePrizeDialog,
                              iconButtonOnPressed: _removePrize,
                              models: _selectedPrizes,
                              // selectedPrize: _selectedPrize,
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
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(12),
        ),
        fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
        filled: true,
      ),
      dropdownMenuEntries: teams
          .map(
            (team) => DropdownMenuEntry(
              value: team,
              label: team.name,
            ),
          )
          .toList(),
      label: const Text('Select team'),
      // menuStyle: MenuStyle(
      //   // Remove borders by setting the side to BorderSide.none
      //   shape: WidgetStateProperty.all<RoundedRectangleBorder>(
      //     RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(8.0),
      //       side: BorderSide.none, // This removes the border
      //     ),
      //   ),
      //   // Change background color
      //   backgroundColor: WidgetStateProperty.all<Color>(Colors.lightBlue),
      // ),
      onSelected: onSelected,
      width: MediaQuery.of(context).size.width * 0.25,
    );
  }
}
