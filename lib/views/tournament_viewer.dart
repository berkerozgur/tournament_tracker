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
  var rounds = <int>[];
  var selectedMatchups = <Matchup>[];
  // int? selectedRound;

  void loadRounds() {
    rounds = [];
    rounds.add(1);
    var currRound = 1;

    for (var matchups in widget.tournament.rounds) {
      if (matchups.first.round > currRound) {
        currRound = matchups.first.round;
        rounds.add(currRound);
      }
    }
  }

  void loadMatchups(int? selectedRound) {
    for (var matchups in widget.tournament.rounds) {
      if (matchups.first.round == selectedRound) {
        setState(() {
          selectedMatchups = matchups;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadRounds();
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
                    dropdownMenuEntries: rounds
                        .map(
                          (round) => DropdownMenuEntry(
                            value: round,
                            label: round.toString(),
                          ),
                        )
                        .toList(),
                    label: const Text('Round'),
                    onSelected: (value) {
                      // setState(() {
                      //   selectedRound = value;
                      // });
                      loadMatchups(value);
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
                        itemCount: selectedMatchups.length,
                        itemBuilder: (context, index) {
                          final matchup = selectedMatchups[index];
                          return ListTile(
                            title: Text(matchup.displayName),
                          );
                        },
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
                      decoration: const InputDecoration(
                        label: Text('Team one score'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13.6),
                  SizedBox(
                    width: 136.6 * 2,
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text('Team two score'),
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
