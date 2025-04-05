import 'package:flutter/material.dart';

import '../models/tournament.dart';

class TournamentViewer extends StatefulWidget {
  final Tournament tournament;

  const TournamentViewer({super.key, required this.tournament});

  @override
  State<TournamentViewer> createState() => _TournamentViewerState();
}

class _TournamentViewerState extends State<TournamentViewer> {
  var rounds = <int>[];

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
            Column(
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
                  width: 136.6,
                ),
                const SizedBox(height: 13.6),
                const LabeledCheckbox(label: 'Unplayed only'),
                const SizedBox(height: 13.6),
                // SelectedObjectsList will take this ones place
                // Expanded(child: BorderedListView()),
              ],
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
