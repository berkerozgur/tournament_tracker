import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../global_config.dart';
import '../models/tournament.dart';
import 'create_tournament.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Tournament Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            DropdownMenu(
              initialSelection:
                  _tournaments.isNotEmpty ? _tournaments.first : null,
              dropdownMenuEntries: _tournaments
                  .map(
                    (tournament) => DropdownMenuEntry(
                      value: tournament,
                      label: tournament.name,
                    ),
                  )
                  .toList(),
              label: const Text('Load existing tournament'),
              onSelected: (value) {
                setState(() {
                  if (value != null) _selectedTournament = value;
                });
              },
              width: 136.6 * 2,
            ),
            const SizedBox(height: 13.6),
            FilledButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.tournamentViewer,
                  arguments: _selectedTournament,
                );
              },
              child: const Text('Load tournament'),
            ),
            const SizedBox(height: 13.6),
            FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateTournament(),
                  ),
                );
              },
              child: const Text('Create tournament'),
            ),
          ],
        ),
      ),
    );
  }
}
