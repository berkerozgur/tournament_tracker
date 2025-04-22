import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../global_config.dart';
import '../models/tournament.dart';
import '../widgets/custom_button.dart';
import '../widgets/generic_dropdown.dart';

class TournamentDashboard extends StatefulWidget {
  const TournamentDashboard({super.key});

  @override
  State<TournamentDashboard> createState() => _TournamentDashboardState();
}

class _TournamentDashboardState extends State<TournamentDashboard> {
  bool _isLoadTournamentEnabled = true;
  Tournament? _selectedTournament;
  List<Tournament> _tournaments = [];

  @override
  void initState() {
    super.initState();
    _getAllTournaments();
  }

  void _createTournament() async {
    final tournament = await Navigator.pushNamed(
      context,
      AppRoutes.createTournament,
    );
    setState(() {
      _selectedTournament = tournament as Tournament?;
      if (_selectedTournament != null) {
        _tournaments.add(_selectedTournament!);
        _isLoadTournamentEnabled = true;
      }
    });
  }

  Future<void> _getAllTournaments() async {
    final tournaments = await GlobalConfig.connection.getAllTournaments();
    setState(() {
      _tournaments = tournaments;
      if (_tournaments.isEmpty) _isLoadTournamentEnabled = false;
    });
  }

  void _loadTournament() {
    setState(() {
      _selectedTournament ??= _tournaments.first;
    });
    Navigator.pushNamed(
      context,
      AppRoutes.tournamentViewer,
      arguments: _selectedTournament,
    );
  }

  void _selectTournament(Tournament? tournament) {
    setState(() {
      _selectedTournament = tournament;
    });
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
            GenericDropdown(
              onSelected: _selectTournament,
              listOfInstances: _tournaments,
              width: MediaQuery.of(context).size.width * 0.5,
            ),
            const SizedBox(height: 32),
            CustomButton(
              buttonType: ButtonType.filled,
              enabled: _isLoadTournamentEnabled,
              onPressed: _loadTournament,
              text: 'Load tournament',
              width: MediaQuery.of(context).size.width * 0.3,
            ),
            const SizedBox(height: 16),
            CustomButton(
              buttonType: ButtonType.outlined,
              onPressed: _createTournament,
              text: 'Create tournament',
              width: MediaQuery.of(context).size.width * 0.3,
            ),
          ],
        ),
      ),
    );
  }
}
