// ignore_for_file: type_literal_in_constant_pattern

import 'package:flutter/material.dart';

import '../models/person.dart';
import '../models/team.dart';
import '../models/tournament.dart';

class GenericDropdown<T> extends StatelessWidget {
  final List<T> listOfInstances;
  final void Function(T? instance)? onSelected;
  final double? width;

  const GenericDropdown({
    super.key,
    required this.listOfInstances,
    required this.onSelected,
    this.width,
  });

  String _createLabel(T instance) {
    final entryLabel = switch (instance) {
      Person p => p.fullName,
      Team t => t.name,
      Tournament t => t.name,
      int i => i.toString(),
      _ => throw Exception(
          'Unsupported item type: ${instance.runtimeType}',
        ),
    };
    return entryLabel;
  }

  @override
  Widget build(BuildContext context) {
    final dropdownLabel = switch (T) {
      Person => 'Select team members',
      Team => 'Select team',
      Tournament => 'Select tournament',
      int => 'Round',
      _ => 'Unsupported type: ${T.toString()}',
    };

    return DropdownMenu(
      key: ValueKey(listOfInstances.length),
      initialSelection:
          listOfInstances.isNotEmpty ? listOfInstances.first : null,
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(12),
        ),
        fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
        filled: true,
      ),
      dropdownMenuEntries: listOfInstances
          .map(
            (model) => DropdownMenuEntry(
              value: model,
              label: _createLabel(model),
            ),
          )
          .toList(),
      label: Text(dropdownLabel),
      // menuStyle: MenuStyle(
      //   // Remove borders by setting the side to BorderSide.none
      //   shape: WidgetStateProperty.all<RoundedRectangleBorder>(
      //     RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(8.0),
      //       side: BorderSide.none, // This removes the border
      //     ),
      //   ),
      //   // Change background color
      //   backgroundColor: WidgetStateProperty.all<Color>(Colors.lightBlue),
      // ),
      onSelected: onSelected,
      width: width ?? MediaQuery.of(context).size.width * 0.25,
    );
  }
}
