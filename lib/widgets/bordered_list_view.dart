import 'package:flutter/material.dart';
import '../models/person.dart';

// TODO: somehow i should be able to pass List<T>
class BorderedListView extends StatelessWidget {
  final List<Person>? selectedMembers;
  const BorderedListView({
    super.key,
    this.selectedMembers,
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
          itemCount: selectedMembers!.length,
          itemBuilder: (context, index) {
            final member = selectedMembers![index];
            return ListTile(
              title: Text(member.fullName),
            );
          },
        ),
      ),
    );
  }
}
