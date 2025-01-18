import 'package:flutter/material.dart';

class TournamentViewer extends StatefulWidget {
  const TournamentViewer({super.key});

  @override
  State<TournamentViewer> createState() => _TournamentViewerState();
}

class _TournamentViewerState extends State<TournamentViewer> {
  bool _isChecked = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Tournament name will be shown here'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DropdownMenu(
              dropdownMenuEntries: [
                DropdownMenuEntry<String>(
                  value: 'foo',
                  label: 'foo',
                ),
              ],
              label: Text('Round'),
              width: 136.6,
            ),
            const SizedBox(height: 13.6),
            Row(
              children: [
                Checkbox(
                  value: _isChecked,
                  onChanged: (value) {
                    setState(() {
                      _isChecked = value ?? false;
                    });
                  },
                ),
                const Text('Unplayed only'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
