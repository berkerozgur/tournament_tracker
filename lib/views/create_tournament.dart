import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../global_config.dart';
import '../models/matchup.dart';
import '../models/prize.dart';
import '../models/team.dart';
import '../models/tournament.dart';
import '../tournament_logic.dart';
import '../widgets/shared/add_to_list_dropdown.dart';
import '../widgets/shared/selected_objects_list.dart';
import 'create_prize_container.dart';

class CreateTournament extends StatefulWidget {
  const CreateTournament({super.key});

  @override
  State<CreateTournament> createState() => _CreateTournamentState();
}

class _CreateTournamentState extends State<CreateTournament> {
  late final TextEditingController _tournamentName;
  late final TextEditingController _entryFee;
  final _formKey = GlobalKey<FormState>();
  var _availableTeams = <Team>[];
  final _selectedTeams = <Team>[];
  final _selectedPrizes = <Prize>[];
  Team? _selectedTeam;

  @override
  void initState() {
    super.initState();
    _tournamentName = TextEditingController();
    _entryFee = TextEditingController();
    _getAllTeams();
  }

  Future<void> _getAllTeams() async {
    final availableTeams = await GlobalConfig.connection.getAllTeams();
    setState(() {
      _availableTeams = availableTeams;
    });
  }

  void _selectTeam(Team? team) {
    setState(() {
      _selectedTeam = team;
    });
  }

  // TODO: adding and removing from lists, can they be generic as well?
  void _addPrizeToSelectedList(Prize prize) {
    setState(() {
      _selectedPrizes.add(prize);
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

  void _removePrizeFromSelectedList(Prize prize) {
    setState(() {
      _selectedPrizes.remove(prize);
    });
  }

  void _removeTeamFromSelectedList(Team team) {
    setState(() {
      _selectedTeams.remove(team);
      _availableTeams.add(team);
      _selectedTeam = null;
    });
  }

  @override
  void dispose() {
    _entryFee.dispose();
    _tournamentName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Create Tournament'),
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
                            controller: _tournamentName,
                            decoration: const InputDecoration(
                              label: Text('Tournament name'),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value != null) {
                                if (_tournamentName.text.isEmpty) {
                                  return 'Please enter a tournament name';
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 13.6),
                          TextFormField(
                            controller: _entryFee,
                            decoration: const InputDecoration(
                              label: Text('Entry fee'),
                              border: OutlineInputBorder(),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*$'),
                              ),
                            ],
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value != null) {
                                var fee =
                                    Decimal.tryParse(value) ?? Decimal.zero;
                                if (fee < Decimal.zero) {
                                  return 'Please enter a positive number or '
                                      'leave it empty';
                                }
                              }
                              return null;
                            },
                          ),
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
                                // TODO: Navigator is used here and showDialog is used elsewhere.
                                // I will decide on a consistent approach after completing all views.
                                onPressed: () async {
                                  final team = await Navigator.pushNamed<Team>(
                                    context,
                                    '/create-team',
                                  );
                                  if (team != null) {
                                    setState(() {
                                      _selectedTeams.add(team);
                                    });
                                  }
                                },
                                child: const Text('Create new team'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 136),
                        ],
                      ),
                    ),
                    const SizedBox(width: 13.6),
                    Expanded(
                      child: Column(
                        children: [
                          // TODO: these lists should expand right half of the screen
                          Expanded(
                            child: SelectedObjectsList<Team>(
                              selectedObjects: _selectedTeams,
                              listTitle: 'Selected teams',
                              listTileTitleBuilder: (team) => team.name,
                              onObjectRemoved: _removeTeamFromSelectedList,
                            ),
                          ),
                          const SizedBox(height: 13.6),
                          Expanded(
                            child: SelectedObjectsList<Prize>(
                              selectedObjects: _selectedPrizes,
                              listTitle: 'Prizes',
                              listTitleTrailing: TextButton(
                                onPressed: () async {
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
                                    _addPrizeToSelectedList(prize);
                                  }
                                },
                                child: const Text('Create prize'),
                              ),
                              listTileTitleBuilder: (prize) => prize.placeName,
                              onObjectRemoved: _removePrizeFromSelectedList,
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
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    if (_selectedTeams.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Please select teams before creating the '
                                  'tournament'),
                        ),
                      );
                      return;
                    }
                    // Create tournament model
                    final tournament = Tournament(
                      id: -1,
                      enteredTeams: _selectedTeams,
                      entryFee:
                          Decimal.tryParse(_entryFee.text) ?? Decimal.zero,
                      name: _tournamentName.text,
                      prizes: _selectedPrizes,
                      // An empty list is passed for testing purposes to simulate the
                      // functionality of pretend rounds.
                      rounds: <List<Matchup>>[],
                    );

                    // Wire matchups
                    TournamentLogic.createRounds(tournament);

                    // Create tournament entry
                    // Create all of the prizes entries
                    // Create all of the teams entries
                    await GlobalConfig.connection.createTournament(tournament);
                  }
                },
                child: const Text('Create tournament'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
