import 'package:flutter/material.dart';

import '../global_config.dart';
import '../models/matchup.dart';
import '../models/tournament.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_text_form_field.dart';
import '../widgets/generic_dropdown.dart';
import '../widgets/generic_list_view.dart';

class _TeamData {
  String name;
  final TextEditingController controller;

  _TeamData({
    required this.name,
    required this.controller,
  });
}

class TournamentViewer extends StatefulWidget {
  final Tournament tournament;

  const TournamentViewer({super.key, required this.tournament});

  @override
  State<TournamentViewer> createState() => _TournamentViewerState();
}

class _TournamentViewerState extends State<TournamentViewer> {
  final _formKey = GlobalKey<FormState>();
  final List<int> _rounds = [];
  final List<Matchup> _selectedMatchups = [];
  late _TeamData _teamOne;
  late _TeamData _teamTwo;
  bool _isUnplayedOnlyChecked = false;
  Matchup? _selectedMatchup;
  int? _selectedRound;

  @override
  void initState() {
    super.initState();
    _teamOne = _TeamData(
      name: 'Not yet set',
      controller: TextEditingController(),
    );
    _teamTwo = _TeamData(
      name: 'Not yet set',
      controller: TextEditingController(),
    );
    _loadRounds();
  }

  @override
  void dispose() {
    _teamOne.controller.dispose();
    _teamTwo.controller.dispose();
    super.dispose();
  }

  void _checkboxChanged(bool value) {
    setState(() {
      _isUnplayedOnlyChecked = value;
    });
    _loadMatchups(_selectedRound);
  }

  void _loadMatchup(Matchup matchup) {
    setState(() {
      _selectedMatchup = matchup;
    });

    for (var i = 0; i < matchup.entries.length; i++) {
      if (i == 0) {
        if (matchup.entries[0].teamCompeting != null) {
          setState(() {
            _teamOne.name = matchup.entries[0].teamCompeting!.name;
            _teamOne.controller.text =
                matchup.entries[0].score?.toString() ?? '0';

            _teamTwo.name = '<bye>';
            _teamTwo.controller.text = '0';
          });
        } else {
          setState(() {
            _teamOne.name = 'Not yet set';
            _teamOne.controller.text = '';
          });
        }
      }
      if (i == 1) {
        if (matchup.entries[1].teamCompeting != null) {
          setState(() {
            _teamTwo.name = matchup.entries[1].teamCompeting!.name;
            _teamTwo.controller.text =
                matchup.entries[1].score?.toString() ?? '0';
          });
        } else {
          setState(() {
            _teamTwo.name = 'Not yet set';
            _teamTwo.controller.text = '';
          });
        }
      }
    }
  }

  void _loadMatchups(int? selectedRound) {
    setState(() {
      _selectedRound = selectedRound;
    });

    for (var matchups in widget.tournament.rounds) {
      if (matchups.first.round == selectedRound) {
        setState(() {
          _selectedMatchups.clear();
        });
        for (var matchup in matchups) {
          if (matchup.winner == null || !_isUnplayedOnlyChecked) {
            setState(() {
              _selectedMatchups.add(matchup);
            });
          }
        }
      }
    }

    if (_selectedMatchups.isEmpty) return;
    if (_isUnplayedOnlyChecked) _selectedMatchup = _selectedMatchups.first;
    _loadMatchup(_selectedMatchup ??= _selectedMatchups.first);
  }

  void _loadRounds() {
    // Make sure to clear _rounds if you call this function more than one for
    // some reason
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

  void _roundOnSelected(int? selectedRound) {
    setState(() {
      _selectedMatchup = null;
    });
    _loadMatchups(selectedRound);
  }

  void _scoreMatchup() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final entries = _selectedMatchup!.entries;
    double teamOneScore = 0;
    double teamTwoScore = 0;

    for (var i = 0; i < entries.length; i++) {
      if (i == 0) {
        if (entries[0].teamCompeting != null) {
          teamOneScore = double.parse(_teamOne.controller.text);
          setState(() {
            entries[0].score = teamOneScore;
          });
        }
      }
      if (i == 1) {
        if (entries[1].teamCompeting != null) {
          teamTwoScore = double.parse(_teamTwo.controller.text);
          setState(() {
            entries[1].score = teamTwoScore;
          });
        }
      }
    }

    // High score wins
    if (teamOneScore > teamTwoScore) {
      // Team one wins
      setState(() {
        _selectedMatchup!.winner = entries[0].teamCompeting;
      });
    } else if (teamTwoScore > teamOneScore) {
      setState(() {
        _selectedMatchup!.winner = entries[1].teamCompeting;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Single-elimination does not handle ties'),
        ),
      );
    }

    for (var round in widget.tournament.rounds) {
      for (var matchup in round) {
        for (var entry in matchup.entries) {
          if (entry.parent != null) {
            if (entry.parent!.id == _selectedMatchup!.id) {
              entry.teamCompeting = _selectedMatchup!.winner;
              GlobalConfig.connection.updateMatchup(matchup);
            }
          }
        }
      }
    }

    _loadMatchups(_selectedRound);

    await GlobalConfig.connection.updateMatchup(_selectedMatchup!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.tournament.name),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rounds dropdown
            GenericDropdown<int>(
              listOfInstances: _rounds,
              onSelected: _roundOnSelected,
              width: MediaQuery.of(context).size.width * 0.48,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  // Matchups ListView
                  Flexible(
                    child: CustomCard(
                      headingText: 'Matchups',
                      headingTrailing: LabeledCheckbox(
                        label: 'Unplayed only',
                        onChanged: _checkboxChanged,
                        value: _isUnplayedOnlyChecked,
                      ),
                      child: GenericListView<Matchup>(
                        hasIconButton: false,
                        isSelected: (matchup) => matchup == _selectedMatchup,
                        listTileOnTap: _loadMatchup,
                        models: _selectedMatchups,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Matchup info
                  Flexible(
                    child: CustomCard(
                      headingText: 'Scores',
                      child: Visibility(
                        visible: _selectedMatchups.isNotEmpty,
                        replacement: const Center(
                          child: Text('No matchup selected to score'),
                        ),
                        child: _MatchupInfo(
                          formKey: _formKey,
                          scoreOnPressed: _scoreMatchup,
                          teamOne: _teamOne,
                          teamTwo: _teamTwo,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchupInfo extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final VoidCallback scoreOnPressed;
  final _TeamData teamOne;
  final _TeamData teamTwo;

  const _MatchupInfo({
    required this.formKey,
    required this.scoreOnPressed,
    required this.teamOne,
    required this.teamTwo,
  });

  String? _validateScore(String? value) {
    if (value != null) {
      if (value.isEmpty) return 'Please enter a score';
      final score = double.tryParse(value);
      if (score == null) return 'Please enter a valid score';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final teamOneLabel =
        teamOne.name == 'Not yet set' ? 'Not yet set' : '${teamOne.name} score';
    final teamTwoLabel =
        teamTwo.name == 'Not yet set' ? 'Not yet set' : '${teamTwo.name} score';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            SizedBox(
              width: double.maxFinite,
              child: CustomTextFormField(
                controller: teamOne.controller,
                fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
                label: teamOneLabel,
                validator: _validateScore,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.maxFinite,
              child: CustomTextFormField(
                controller: teamTwo.controller,
                fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
                label: teamTwoLabel,
                validator: _validateScore,
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              buttonType: ButtonType.filled,
              onPressed: scoreOnPressed,
              text: 'Score',
              width: MediaQuery.of(context).size.width * 0.3,
            ),
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
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
    );
  }
}
