// ignore_for_file: type_literal_in_constant_pattern

import 'package:flutter/material.dart';

import '../models/person.dart';
import '../models/team.dart';
import '../models/tournament.dart';

class GenericDropdown<T> extends StatelessWidget {
  final List<T> models;
  final void Function(T? model)? onSelected;
  final double? width;

  const GenericDropdown({
    super.key,
    required this.models,
    required this.onSelected,
    this.width,
  });

  String _createLabel(T model) {
    final entryLabel = switch (model) {
      Person p => p.fullName,
      Team t => t.name,
      Tournament t => t.name,
      _ => throw Exception(
          'Unsupported item type: ${model.runtimeType}',
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
      _ => 'Unsupported type: ${T.toString()}',
    };

    return DropdownMenu(
      key: ValueKey(models.length),
      initialSelection: models.isNotEmpty ? models.first : null,
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
      dropdownMenuEntries: models
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
