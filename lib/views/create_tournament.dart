import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart' as multi_window;
import 'package:flutter/material.dart';

import '../global_config.dart';
import '../models/prize.dart';
import '../models/team.dart';
import '../models/tournament.dart';
import '../tournament_logic.dart';
import '../widgets/custom_text_form_field.dart';

class CreateTournament extends StatefulWidget {
  const CreateTournament({super.key});

  @override
  State<CreateTournament> createState() => _CreateTournamentState();
}

class _CreateTournamentState extends State<CreateTournament> {
  late final TextEditingController _entryFee;
  late final TextEditingController _tournamentName;
  final _formKey = GlobalKey<FormState>();
  final _selectedPrizes = <Prize>[];
  final _selectedTeams = <Team>[];
  var _availableTeams = <Team>[];
  Prize? _selectedPrize;
  Team? _selectedTeam;

  @override
  void initState() {
    super.initState();
    _entryFee = TextEditingController();
    _tournamentName = TextEditingController();
    _getAllTeams();
  }

  @override
  void dispose() {
    _entryFee.dispose();
    _tournamentName.dispose();
    super.dispose();
  }

  Future<void> _getAllTeams() async {
    final availableTeams = await GlobalConfig.connection?.getAllTeams();
    setState(() {
      _availableTeams = availableTeams!;
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
                          // Tournament name
                          CustomTextFormField(
                            controller: _tournamentName,
                            label: 'Tournament name',
                            validator: (value) {
                              if (value != null && value.isEmpty) {
                                return 'Please enter a tournament name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 13.6),
                          // TODO: Users should only enter numbers
                          // Entry fee
                          CustomTextFormField(
                            controller: _entryFee,
                            label: 'Entry fee',
                            validator: (value) {
                              if (value != null) {
                                final fee =
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
                              // Available teams dropdown
                              DropdownMenu(
                                key: ValueKey(_availableTeams.length),
                                dropdownMenuEntries: _availableTeams
                                    .map(
                                      (team) => DropdownMenuEntry(
                                        value: team,
                                        label: team.name,
                                      ),
                                    )
                                    .toList(),
                                label: const Text('Select team'),
                                onSelected: (value) {
                                  setState(() {
                                    _selectedTeam = value;
                                  });
                                },
                                width: 136.6 * 2,
                              ),
                              const SizedBox(width: 13.6),
                              // Add team button
                              FilledButton(
                                onPressed: () {
                                  if (_selectedTeam != null) {
                                    setState(() {
                                      _availableTeams.remove(_selectedTeam);
                                      _selectedTeams.add(_selectedTeam!);
                                      _selectedTeam = null;
                                    });
                                  }
                                },
                                child: const Text('Add team'),
                              ),
                              const SizedBox(width: 13.6),
                              const Text('or'),
                              // Create new team button
                              TextButton(
                                onPressed: () async {
                                  final window = await multi_window
                                      .DesktopMultiWindow.createWindow(
                                    jsonEncode(
                                      {'view': 'create_team'},
                                    ),
                                  );
                                  window
                                    ..setFrame(const Offset(0, 0) &
                                        const Size(1366, 768))
                                    ..center()
                                    ..setTitle('Create Team')
                                    ..show();
                                  // if (team != null) {
                                  //   setState(() {
                                  //     _selectedTeams.add(team);
                                  //   });
                                  // }
                                },
                                child: const Text('Create new team'),
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
                          // Selected teams container
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Selected teams',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall,
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: ListView.builder(
                                      itemCount: _selectedTeams.length,
                                      itemBuilder: (context, index) {
                                        final team = _selectedTeams[index];
                                        return ListTile(
                                          title: Text(
                                            team.name,
                                          ),
                                          // TODO: Display team members here
                                          // subtitle: ,
                                          trailing: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _selectedTeam = team;
                                                _selectedTeams
                                                    .remove(_selectedTeam);
                                                _availableTeams
                                                    .add(_selectedTeam!);
                                                _selectedTeam = null;
                                              });
                                            },
                                            icon: const Icon(
                                              Icons.remove_outlined,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 13.6),
                          // Prizes container
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Prizes',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall,
                                    ),
                                    TextButton(
                                      onPressed: () {},
                                      child: const Text('Create prize'),
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: ListView.builder(
                                      itemCount: _selectedPrizes.length,
                                      itemBuilder: (context, index) {
                                        final prize = _selectedPrizes[index];
                                        return ListTile(
                                          title: Text(prize.placeName),
                                          trailing: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _selectedPrize = prize;
                                                _selectedPrizes
                                                    .remove(_selectedPrize);
                                                _selectedPrize = null;
                                              });
                                            },
                                            icon: const Icon(
                                                Icons.remove_outlined),
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
                    )
                  ],
                ),
              ),
              const SizedBox(height: 13.6 * 3),
              // Create tournament button
              FilledButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    if (_selectedTeams.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please select teams before creating a tournament',
                          ),
                        ),
                      );
                      return;
                    }
                    // Create tournament model
                    final tournament = Tournament(
                      id: -1,
                      enteredTeams: _selectedTeams,
                      entryFee: Decimal.parse(_entryFee.text),
                      name: _tournamentName.text,
                      prizes: _selectedPrizes,
                      rounds: [],
                    );

                    // Wire matchups
                    TournamentLogic.createRounds(tournament);

                    // Create tournament entry
                    // Create all of the prizes entries
                    // Create all of the teams entries
                    await GlobalConfig.connection?.createTournament(tournament);
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
