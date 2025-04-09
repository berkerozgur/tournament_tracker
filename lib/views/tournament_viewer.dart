import 'package:flutter/material.dart';

import '../models/matchup.dart';
import '../models/tournament.dart';

class TournamentViewer extends StatefulWidget {
  final Tournament tournament;

  const TournamentViewer({super.key, required this.tournament});

  @override
  State<TournamentViewer> createState() => _TournamentViewerState();
}

class _TournamentViewerState extends State<TournamentViewer> {
  final _rounds = <int>[];
  final _selectedMatchups = <Matchup>[];
  late final TextEditingController _teamOneController;
  late final TextEditingController _teamTwoController;
  var _isChecked = false;
  var _selectedIdx = 0;
  late Matchup _selectedMatchup;
  var _selectedRound = 1;
  var _teamOneName = '';
  var _teamTwoName = '';

  void _loadMatchup(Matchup matchup) {
    for (var i = 0; i < matchup.entries.length; i++) {
      if (i == 0) {
        if (matchup.entries[0].teamCompeting != null) {
          setState(() {
            _teamOneName = matchup.entries[0].teamCompeting!.name;
            _teamOneController.text = matchup.entries[0].score == null
                ? '0'
                : matchup.entries[0].score.toString();

            _teamTwoName = '<bye>';
            _teamTwoController.text = '0';
          });
        } else {
          setState(() {
            _teamOneName = 'Not yet set';
          });
        }
      }
      if (i == 1) {
        if (matchup.entries[1].teamCompeting != null) {
          setState(() {
            _teamTwoName = matchup.entries[1].teamCompeting!.name;
            _teamTwoController.text = matchup.entries[1].score == null
                ? '0'
                : matchup.entries[1].score.toString();
          });
        } else {
          setState(() {
            _teamTwoName = 'Not yet set';
          });
        }
      }
    }
  }

  void _loadMatchups(int? selectedRound) {
    for (var matchups in widget.tournament.rounds) {
      if (matchups.first.round == selectedRound) {
        setState(() {
          _selectedMatchups.clear();
        });
        for (var matchup in matchups) {
          if (matchup.winner == null || !_isChecked) {
            setState(() {
              _selectedMatchups.add(matchup);
            });
          }
        }
      }
    }
    if (_selectedMatchups.isNotEmpty) _loadMatchup(_selectedMatchups.first);
  }

  void _loadRounds() {
    // _rounds.clear();
    _rounds.add(1);
    var currRound = 1;

    for (var matchups in widget.tournament.rounds) {
      if (matchups.first.round > currRound) {
        currRound = matchups.first.round;
        _rounds.add(currRound);
      }
    }

    _loadMatchups(1);
  }

  @override
  void initState() {
    super.initState();
    _teamOneController = TextEditingController();
    _teamTwoController = TextEditingController();
    _loadRounds();
    _selectedMatchup = _selectedMatchups.first;
  }

  @override
  void dispose() {
    _teamOneController.dispose();
    _teamTwoController.dispose();
    super.dispose();
  }

  void _scoreOnPressed() {
    final entries = _selectedMatchup.entries;
    double? teamOneScore;
    double? teamTwoScore;
    for (var i = 0; i < entries.length; i++) {
      if (i == 0) {
        if (entries[0].teamCompeting != null) {
          teamOneScore = double.tryParse(_teamOneController.text);
          if (teamOneScore == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please enter a valid score'),
              ),
            );
            return;
          }
          setState(() {
            entries[0].score = teamOneScore;
          });
        }
      }
      if (i == 1) {
        if (entries[1].teamCompeting != null) {
          teamTwoScore = double.tryParse(_teamTwoController.text);
          if (teamTwoScore == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please enter a valid score'),
              ),
            );
            return;
          }
          setState(() {
            entries[1].score = teamTwoScore;
          });
        }
      }
    }
    // High score wins
    if (teamOneScore! > teamTwoScore!) {
      // Team one wins
      setState(() {
        _selectedMatchup.winner = entries[0].teamCompeting;
      });
    } else if (teamTwoScore > teamOneScore) {
      setState(() {
        _selectedMatchup.winner = entries[1].teamCompeting;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Single-elimination does not handle ties'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.tournament.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TODO: selected index in listview should reset to 1 when rounds changed
                  // Rounds dropdown
                  DropdownMenu(
                    initialSelection: _rounds.first,
                    dropdownMenuEntries: _rounds
                        .map(
                          (round) => DropdownMenuEntry(
                            value: round,
                            label: round.toString(),
                          ),
                        )
                        .toList(),
                    label: const Text('Round'),
                    onSelected: (value) {
                      setState(() {
                        _selectedRound = value!;
                      });
                      _loadMatchups(value);
                    },
                    width: 136.6,
                  ),
                  const SizedBox(height: 13.6),
                  // Unplayed only checkbox
                  LabeledCheckbox(
                    label: 'Unplayed only',
                    onChanged: (value) {
                      setState(() {
                        _isChecked = value;
                      });
                      _loadMatchups(_selectedRound);
                    },
                    value: _isChecked,
                  ),
                  const SizedBox(height: 13.6),
                  // Matchups ListView
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          final matchup = _selectedMatchups[index];
                          return ListTile(
                            onTap: () {
                              setState(() {
                                _selectedIdx = index;
                                _selectedMatchup = matchup;
                              });
                              _loadMatchup(matchup);
                            },
                            selected: index == _selectedIdx,
                            title: Text(matchup.displayName),
                          );
                        },
                        itemCount: _selectedMatchups.length,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  SizedBox(
                    width: 136.6 * 2,
                    child: TextFormField(
                      controller: _teamOneController,
                      decoration: InputDecoration(
                        label: Text('$_teamOneName score'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13.6),
                  SizedBox(
                    width: 136.6 * 2,
                    child: TextFormField(
                      controller: _teamTwoController,
                      decoration: InputDecoration(
                        label: Text('$_teamTwoName score'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13.6),
                  SizedBox(
                    width: 136.6,
                    child: FilledButton(
                      onPressed: _scoreOnPressed,
                      child: const Text('Score'),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class LabeledCheckbox extends StatelessWidget {
  const LabeledCheckbox({
    super.key,
    required this.label,
    required this.onChanged,
    required this.value,
  });

  final String label;
  final ValueChanged<bool> onChanged;
  final bool value;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onChanged(!value);
      },
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: (value) {
              onChanged(value!);
            },
          ),
          const SizedBox(width: 13.6 / 2),
          Text(label),
        ],
      ),
    );
  }
}
