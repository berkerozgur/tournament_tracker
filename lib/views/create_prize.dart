import 'package:flutter/material.dart';

class CreatePrize extends StatelessWidget {
  CreatePrize({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Create prize'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text('Place number'),
                ),
                validator: (value) {
                  if (value != null) {
                    final placeNumber = int.tryParse(value);
                    if (placeNumber == null) {
                      return 'Please enter an integer number';
                    } else if (placeNumber < 1) {
                      return 'Place number can\'t be smaller than 1';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 13.6,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text('Place name'),
                ),
                validator: (value) {
                  if (value != null) {
                    if (value.isEmpty) {
                      return 'This field is required';
                    }
                  }
                  return null;
                },
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
      ),
    );
  }
}
