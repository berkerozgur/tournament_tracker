import 'package:flutter/material.dart';
import '../models/person.dart';

// TODO: somehow i should be able to pass List<T>
class BorderedListView extends StatefulWidget {
  final List<Person>? selectedMembers;
  final Person? selectedMember;
  final void Function(Person member)? onMemberSelected;

  const BorderedListView({
    super.key,
    this.selectedMembers,
    this.selectedMember,
    this.onMemberSelected,
  });

  @override
  State<BorderedListView> createState() => _BorderedListViewState();
}

class _BorderedListViewState extends State<BorderedListView> {
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
          itemCount: widget.selectedMembers!.length,
          itemBuilder: (context, index) {
            final member = widget.selectedMembers![index];
            return ListTile(
              onTap: () {
                if (widget.onMemberSelected != null) {
                  widget.onMemberSelected!(member);
                }
              },
              selected: widget.selectedMember == member,
              title: Text(member.fullName),
            );
          },
        ),
      ),
    );
  }
}
