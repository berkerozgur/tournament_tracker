import 'package:flutter/material.dart';

import '../global_config.dart';
import '../models/matchup.dart';
import '../models/tournament.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_text_form_field.dart';
import '../widgets/generic_dropdown.dart';
import '../widgets/generic_list_view.dart';

class TeamData {
  String name;
  final TextEditingController controller;

  TeamData({
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
  late final TextEditingController _teamOneController;
  late final TextEditingController _teamTwoController;
  final List<int> _rounds = [];
  final List<Matchup> _selectedMatchups = [];
  late Matchup _selectedMatchup;
  late TeamData _teamOne;
  late TeamData _teamTwo;
  var _isChecked = false;
  // final _selectedIdx = 0;
  int? _selectedRound;

  @override
  void initState() {
    super.initState();
    _teamOneController = TextEditingController();
    _teamTwoController = TextEditingController();
    _teamOne = TeamData(name: 'Not yet set', controller: _teamOneController);
    _teamTwo = TeamData(name: 'Not yet set', controller: _teamTwoController);
    _loadRounds();
    _selectedMatchup = _selectedMatchups.first;
  }

  @override
  void dispose() {
    _teamOneController.dispose();
    _teamTwoController.dispose();
    super.dispose();
  }

  void _checkboxChanged(bool value) {
    setState(() {
      _isChecked = value;
    });
    _loadMatchups(_selectedRound);
  }

  void _loadMatchup(Matchup matchup) {
    _updateSelectedMatchup(matchup);

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
    // TODO: fix this
    // There is a problem on updating Matchups. Matchups file breaks after
    // during this process
    for (var round in widget.tournament.rounds) {
      for (var matchup in round) {
        for (var entry in matchup.entries) {
          if (entry.parent != null) {
            if (entry.parent!.id == _selectedMatchup.id) {
              entry.teamCompeting = _selectedMatchup.winner;
              GlobalConfig.connection.updateMatchup(matchup);
            }
          }
        }
      }
    }
    // TODO: this doesn't work as expected
    _loadMatchups(_selectedRound);

    GlobalConfig.connection.updateMatchup(_selectedMatchup);
  }

  void _updateSelectedMatchup(Matchup matchup) {
    setState(() {
      _selectedMatchup = matchup;
    });
  }

  void _updateSelectedRound(int? selectedRound) {
    setState(() {
      _selectedRound = selectedRound;
    });
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
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TODO: selected index in listview should reset to 1 when rounds changed
                // Rounds dropdown
                GenericDropdown<int>(
                  listOfInstances: _rounds,
                  onSelected: _loadMatchups,
                  width: MediaQuery.of(context).size.width * 0.48,
                ),
              ],
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
                        value: _isChecked,
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
                    child: Visibility(
                      visible: _selectedMatchups.isNotEmpty,
                      child: CustomCard(
                        headingText: 'Scores',
                        child: MatchupInfo(
                          scoreOnPressed: _scoreOnPressed,
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

class MatchupInfo extends StatelessWidget {
  final VoidCallback scoreOnPressed;
  final TeamData teamOne;
  final TeamData teamTwo;

  const MatchupInfo({
    super.key,
    required this.scoreOnPressed,
    required this.teamOne,
    required this.teamTwo,
  });

  String? _validateTeamOneScore(String? value) {
    return null;
  }

  String? _validateTeamTwoScore(String? value) {
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
      child: Column(
        children: [
          SizedBox(
            width: double.maxFinite,
            child: CustomTextFormField(
              controller: teamOne.controller,
              fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
              label: teamOneLabel,
              validator: _validateTeamOneScore,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.maxFinite,
            child: CustomTextFormField(
              controller: teamTwo.controller,
              fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
              label: teamTwoLabel,
              validator: _validateTeamTwoScore,
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
