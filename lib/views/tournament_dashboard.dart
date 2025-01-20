import 'package:flutter/material.dart';

class TournamentDashboard extends StatelessWidget {
  const TournamentDashboard({super.key});

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
            const DropdownMenu(
              dropdownMenuEntries: [
                DropdownMenuEntry<String>(
                  value: 'foo',
                  label: 'foo',
                ),
              ],
              label: Text('Load existing tournament'),
              width: 136.6 * 2,
            ),
            const SizedBox(height: 13.6),
            FilledButton(
              onPressed: () {},
              child: const Text('Load tournament'),
            ),
            const SizedBox(height: 13.6),
            FilledButton(
              onPressed: () {},
              child: const Text('Create tournament'),
            ),
          ],
        ),
      ),
    );
  }
}
