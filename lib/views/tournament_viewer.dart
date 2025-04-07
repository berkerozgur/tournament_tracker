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
  late final TextEditingController _teamOneController;
  late final TextEditingController _teamTwoController;
  final _rounds = <int>[];
  var _selectedIdx = 0;
  var _selectedMatchups = <Matchup>[];
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
          _selectedMatchups = matchups;
        });
      }
    }
  }

  void _loadRounds() {
    _rounds.clear();
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
  }

  @override
  void dispose() {
    _teamOneController.dispose();
    _teamTwoController.dispose();
    super.dispose();
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
                      _loadMatchups(value);
                    },
                    width: 136.6,
                  ),
                  const SizedBox(height: 13.6),
                  const LabeledCheckbox(label: 'Unplayed only'),
                  const SizedBox(height: 13.6),
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
                          // TODO: should load team names and scores when view first loaded without tapping tile but how?
                          return ListTile(
                            onTap: () {
                              setState(() {
                                _selectedIdx = index;
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
                      onPressed: () {},
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

class LabeledCheckbox extends StatefulWidget {
  final String label;
  const LabeledCheckbox({super.key, required this.label});

  @override
  State<LabeledCheckbox> createState() => _LabeledCheckboxState();
}

class _LabeledCheckboxState extends State<LabeledCheckbox> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: _isChecked,
          onChanged: (value) {
            setState(() {
              _isChecked = value ?? false;
            });
          },
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _isChecked = !_isChecked;
            });
          },
          child: Text(widget.label),
        ),
      ],
    );
  }
}
