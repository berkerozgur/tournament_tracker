import 'package:flutter/material.dart';

import '../widgets/bordered_list_view.dart';

class CreateTeam extends StatelessWidget {
  const CreateTeam({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Create Team'),
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
                            label: Text('Team name'),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 13.6),
                        const DropdownMenu(
                          dropdownMenuEntries: [
                            DropdownMenuEntry<String>(
                              value: 'foo',
                              label: 'foo',
                            ),
                          ],
                          label: Text('Select team member'),
                          width: 136.6,
                        ),
                        const SizedBox(height: 13.6),
                        FilledButton(
                          onPressed: () {},
                          child: const Text('Add member'),
                        ),
                        const SizedBox(height: 13.6),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Add new member',
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                                const TextField(
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    label: Text('First name'),
                                  ),
                                ),
                                const SizedBox(height: 13.6),
                                const TextField(
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    label: Text('Last name'),
                                  ),
                                ),
                                const SizedBox(height: 13.6),
                                const TextField(
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    label: Text('Email'),
                                  ),
                                ),
                                const SizedBox(height: 13.6),
                                const TextField(
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    label: Text('Phone number'),
                                  ),
                                ),
                                const SizedBox(height: 13.6),
                                Align(
                                  alignment: Alignment.center,
                                  child: FilledButton(
                                    onPressed: () {},
                                    child: const Text('Create member'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 13.6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Team members',
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
              child: const Text('Create team'),
            ),
          ],
        ),
      ),
    );
  }
}
