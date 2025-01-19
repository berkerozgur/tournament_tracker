import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TournamentViewer extends StatefulWidget {
  const TournamentViewer({super.key});

  @override
  State<TournamentViewer> createState() => _TournamentViewerState();
}

class _TournamentViewerState extends State<TournamentViewer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Tournament name will be shown here'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownMenu(
                  dropdownMenuEntries: [
                    DropdownMenuEntry<String>(
                      value: 'foo',
                      label: 'foo',
                    ),
                  ],
                  label: Text('Round'),
                  width: 136.6,
                ),
                SizedBox(height: 13.6),
                LabeledCheckbox(label: 'Unplayed only'),
                SizedBox(height: 13.6),
                Expanded(child: BorderedListView()),
              ],
            ),
            Expanded(
              child: Column(
                children: [
                  const SizedBox(
                    width: 136.6 * 2,
                    child: ScoreField(label: 'Team one score'),
                  ),
                  const SizedBox(height: 13.6),
                  const SizedBox(
                    width: 136.6 * 2,
                    child: ScoreField(label: 'Team two score'),
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

class ScoreField extends StatelessWidget {
  final String label;

  const ScoreField({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        label: Text(label),
        border: const OutlineInputBorder(),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
      ],
      keyboardType: TextInputType.number,
    );
  }
}

class BorderedListView extends StatelessWidget {
  const BorderedListView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.3,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
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
