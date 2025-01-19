import 'package:flutter/material.dart';

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
