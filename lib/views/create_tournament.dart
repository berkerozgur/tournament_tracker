import 'package:flutter/material.dart';

import '../widgets/bordered_list_view.dart';
import '../widgets/custom_text_form_field.dart';

class CreateTournament extends StatelessWidget {
  const CreateTournament({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Create Tournament'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const TextField(
                          decoration: InputDecoration(
                            label: Text('Tournament name'),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 13.6),
                        const CustomTextFormField(label: 'Entry fee'),
                        const SizedBox(height: 13.6),
                        const DropdownMenu(
                          dropdownMenuEntries: [
                            DropdownMenuEntry<String>(
                              value: 'foo',
                              label: 'foo',
                            ),
                          ],
                          label: Text('Select team'),
                          width: 136.6,
                        ),
                        const SizedBox(height: 13.6),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Create new team'),
                        ),
                        const SizedBox(height: 13.6),
                        FilledButton(
                          onPressed: () {},
                          child: const Text('Add team'),
                        ),
                        const SizedBox(height: 13.6),
                        FilledButton(
                          onPressed: () {},
                          child: const Text('Create prize'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 13.6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Teams',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              const BorderedListView(),
                              const SizedBox(width: 13.6),
                              FilledButton(
                                onPressed: () {},
                                child: const Text('Delete selected'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 13.6),
                        Text(
                          'Prizes',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              const BorderedListView(),
                              const SizedBox(width: 13.6),
                              FilledButton(
                                onPressed: () {},
                                child: const Text('Delete selected'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 13.6 * 3),
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
