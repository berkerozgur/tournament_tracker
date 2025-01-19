import 'package:flutter/material.dart';

class CreatePrize extends StatelessWidget {
  const CreatePrize({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Create prize'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                label: Text('Place number'),
              ),
            ),
            const SizedBox(
              height: 13.6,
            ),
            const TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                label: Text('Place name'),
              ),
            ),
            const SizedBox(
              height: 13.6,
            ),
            const TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                label: Text('Prize amount'),
              ),
            ),
            const SizedBox(
              height: 13.6,
            ),
            const Text('or'),
            const SizedBox(
              height: 13.6,
            ),
            const TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                label: Text('Prize percentage'),
              ),
            ),
            const SizedBox(
              height: 13.6,
            ),
            FilledButton(
              onPressed: () {},
              child: const Text('Create prize'),
            ),
          ],
        ),
      ),
    );
  }
}
