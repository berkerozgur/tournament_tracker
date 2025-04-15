import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart' as multi_window;
import 'package:flutter/material.dart';

import '../global_config.dart';
import '../models/tournament.dart';

class TournamentDashboard extends StatefulWidget {
  const TournamentDashboard({super.key});

  @override
  State<TournamentDashboard> createState() => _TournamentDashboardState();
}

class _TournamentDashboardState extends State<TournamentDashboard> {
  var _tournaments = <Tournament>[];
  Tournament? _selectedTournament;

  Future<void> _getAllTournaments() async {
    final tournaments = await GlobalConfig.connection!.getAllTournaments();
    setState(() {
      _tournaments = tournaments;
    });
  }

  @override
  void initState() {
    super.initState();
    _getAllTournaments();
  }

  void _openCreateTournamentView() async {
    final window = await multi_window.DesktopMultiWindow.createWindow(
      jsonEncode(
        {'view': 'create_tournament'},
      ),
    );
    window
      ..setFrame(const Offset(0, 0) & const Size(1366, 768))
      ..center()
      ..setTitle('Create Tournament')
      ..show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Tournament Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tournaments Dropdown
            DropdownMenu(
              dropdownMenuEntries: _tournaments
                  .map(
                    (tournament) => DropdownMenuEntry(
                      value: tournament,
                      label: tournament.name,
                    ),
                  )
                  .toList(),
              initialSelection:
                  _tournaments.isNotEmpty ? _tournaments.first : null,
              label: const Text('Load existing tournament'),
              onSelected: (value) {
                setState(() {
                  if (value != null) _selectedTournament = value;
                });
              },
              width: 80 * 4,
            ),
            // Load tournament button
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () async {
                // final window =
                //     await multi_window.DesktopMultiWindow.createWindow(
                //   jsonEncode(
                //     {'view': 'create_tournament'},
                //   ),
                // );
                // window
                //   ..setFrame(const Offset(0, 0) & const Size(1366, 768))
                //   ..center()
                //   ..setTitle('Tournament Viewer')
                //   ..show();
                // Navigator.pushNamed(
                //   context,
                //   AppRoutes.tournamentViewer,
                //   arguments: _selectedTournament,
                // );
              },
              child: const Text('Load tournament'),
            ),
            const SizedBox(height: 8),
            // Create tournament button
            FilledButton(
              onPressed: _openCreateTournamentView,
              child: const Text('Create tournament'),
            ),
          ],
        ),
      ),
    );
  }
}
