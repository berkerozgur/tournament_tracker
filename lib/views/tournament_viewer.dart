import 'package:flutter/material.dart';

import '../widgets/custom_text_form_field.dart';

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
                // SelectedObjectsList will take this ones place
                // Expanded(child: BorderedListView()),
              ],
            ),
            Expanded(
              child: Column(
                children: [
                  const SizedBox(
                    width: 136.6 * 2,
                    child: CustomTextFormField(label: 'Team one score'),
                  ),
                  const SizedBox(height: 13.6),
                  const SizedBox(
                    width: 136.6 * 2,
                    child: CustomTextFormField(label: 'Team two score'),
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
