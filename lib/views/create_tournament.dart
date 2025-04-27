import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../global_config.dart';
import '../models/prize.dart';
import '../models/team.dart';
import '../models/tournament.dart';
import '../tournament_logic.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_text_form_field.dart';
import '../widgets/generic_dropdown.dart';
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
    setState(() {
      _selectedTeam ??= _availableTeams.first;
      _availableTeams.remove(_selectedTeam);
      _selectedTeams.add(_selectedTeam!);
      _selectedTeam = null;
    });
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
      final createdTournament =
          await GlobalConfig.connection.createTournament(tournament);

      if (!mounted) return;
      Navigator.pop(context, createdTournament);
    }
  }

  Tournament _createTournamentModel() {
    final tournament = Tournament(
      id: -1,
      enteredTeams: _selectedTeams,
      entryFee: Decimal.tryParse(_entryFeeController.text) ?? Decimal.zero,
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
      final fee = Decimal.tryParse(value);
      if (fee == null) return 'Please enter a valid number';
      if (fee < Decimal.zero) {
        return 'Please enter a positive number or leave it empty';
      }
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
      body: Padding(
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
                  child: Row(
                    children: [
                      GenericDropdown<Team>(
                        onSelected: _selectTeam,
                        listOfInstances: _availableTeams,
                      ),
                      const SizedBox(width: 16),
                      CustomButton(
                        buttonType: ButtonType.filled,
                        enabled: _availableTeams.isNotEmpty,
                        onPressed: _addTeam,
                        text: 'Add team',
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
                children: [
                  // Selected prizes section
                  Expanded(
                    child: CustomCard(
                      headingText: 'Prizes',
                      headingTrailing: CustomButton(
                        buttonType: ButtonType.text,
                        onPressed: _showCreatePrizeDialog,
                        text: 'Create prize',
                      ),
                      child: GenericListView<Prize>(
                        iconButtonOnPressed: _removePrize,
                        models: _selectedPrizes,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Selected teams section
                  Expanded(
                    child: CustomCard(
                      headingText: 'Selected teams',
                      headingTrailing: CustomButton(
                        buttonType: ButtonType.text,
                        onPressed: _showCreateTeamDialog,
                        text: 'Create new team',
                      ),
                      child: GenericListView<Team>(
                        iconButtonOnPressed: _removeTeam,
                        models: _selectedTeams,
                      ),
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
    );
  }
}
