import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../global_config.dart';
import '../models/tournament.dart';

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

  void _createTournament() {
    Navigator.pushNamed(
      context,
      AppRoutes.createTournament,
    );
  }

  Future<void> _getAllTournaments() async {
    final tournaments = await GlobalConfig.connection.getAllTournaments();
    setState(() {
      _tournaments = tournaments;
      if (_tournaments.isEmpty) _isLoadTournamentEnabled = false;
    });
  }

  void _loadTournament() {
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
            TournamentsDropdown(
              onSelected: _selectTournament,
              tournaments: _tournaments,
            ),
            const SizedBox(height: 7.68 * 4),
            CustomButton(
              buttonType: ButtonType.filled,
              enabled: _isLoadTournamentEnabled,
              onPressed: _loadTournament,
              text: 'Load tournament',
            ),
            const SizedBox(height: 7.68 * 2),
            CustomButton(
              buttonType: ButtonType.outlined,
              onPressed: _createTournament,
              text: 'Create tournament',
            ),
          ],
        ),
      ),
    );
  }
}

enum ButtonType { filled, outlined }

class CustomButton extends StatelessWidget {
  final ButtonType buttonType;
  final bool enabled;
  final VoidCallback? onPressed;
  final String text;

  const CustomButton({
    super.key,
    required this.buttonType,
    this.enabled = true,
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width * 0.3,
      ),
      child: buttonType == ButtonType.filled
          ? FilledButton(
              onPressed: enabled ? onPressed : null,
              child: Text(text),
            )
          : OutlinedButton(
              onPressed: enabled ? onPressed : null,
              child: Text(text),
            ),
    );
  }
}

class TournamentsDropdown extends StatelessWidget {
  final void Function(Tournament? tournament)? onSelected;
  final List<Tournament> tournaments;

  const TournamentsDropdown({
    super.key,
    required this.onSelected,
    required this.tournaments,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownMenu(
      initialSelection: tournaments.isEmpty ? null : tournaments.first,
      dropdownMenuEntries: tournaments
          .map(
            (tournament) => DropdownMenuEntry(
              value: tournament,
              label: tournament.name,
            ),
          )
          .toList(),
      label: const Text('Load existing tournament'),
      onSelected: onSelected,
      width: MediaQuery.of(context).size.width * 0.5,
    );
  }
}
