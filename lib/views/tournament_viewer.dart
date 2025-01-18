import 'package:flutter/material.dart';

class TournamentViewer extends StatefulWidget {
  const TournamentViewer({super.key});

  @override
  State<TournamentViewer> createState() => _TournamentViewerState();
}

class _TournamentViewerState extends State<TournamentViewer> {
  final bool _isChecked = false;
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
            const LabeledCheckbox(label: 'Unplayed only'),
            const SizedBox(height: 13.6),
            Expanded(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ListView.builder(
                    itemCount: 1,
                    itemBuilder: (context, index) {
                      return const ListTile(
                        title: Text('title'),
                        subtitle: Text('subtitle'),
                      );
                    },
                  ),
                ),
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
