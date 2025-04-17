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
    final team = await Navigator.pushNamed<Team>(
      context,
      '/create-team',
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
      body: Padding(
        padding: const EdgeInsets.all(13.6),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              CustomTextFormField(
                                controller: _tournamentNameController,
                                label: 'Tournament name',
                                validator: _validateTournamentName,
                              ),
                              const SizedBox(height: 7.68 * 2),
                              CustomTextFormField(
                                controller: _entryFeeController,
                                label: 'Entry fee',
                                validator: _validateEntryFee,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 7.68 * 2),
                        Row(
                          children: [
                            Row(
                              children: [
                                TeamsDropdown(
                                  onSelected: _selectTeam,
                                  teams: _availableTeams,
                                ),
                                const SizedBox(width: 13.6),
                                CustomButton(
                                  buttonType: ButtonType.filled,
                                  onPressed: _addTeam,
                                  text: 'Add team',
                                ),
                              ],
                            ),
                            const SizedBox(width: 13.6),
                            const Text('or'),
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
                  const SizedBox(width: 13.6),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const HeadlineSmallText(text: 'Selected teams'),
                              Expanded(
                                child: SelectedTeams(
                                  onPressed: _removeTeam,
                                  teams: _selectedTeams,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 7.68 * 2),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const HeadlineSmallText(
                                    text: 'Selected prizes',
                                  ),
                                  CustomButton(
                                    buttonType: ButtonType.text,
                                    onPressed: _createPrizeOnPressed,
                                    text: 'Create prize',
                                  ),
                                ],
                              ),
                              Expanded(
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
                  )
                ],
              ),
            ),
            const SizedBox(height: 7.68 * 3),
            CustomButton(
              buttonType: ButtonType.filled,
              onPressed: _createTournamentOnPressed,
              text: 'Create tournament',
            ),
          ],
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
      child: ListView.builder(
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
      child: ListView.builder(
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
