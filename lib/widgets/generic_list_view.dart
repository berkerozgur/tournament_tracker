// ignore_for_file: type_literal_in_constant_pattern

import 'package:flutter/material.dart';

import '../models/matchup.dart';
import '../models/person.dart';
import '../models/prize.dart';
import '../models/team.dart';

class GenericListView<T> extends StatelessWidget {
  final bool hasIconButton;
  final void Function(T model)? iconButtonOnPressed;
  final bool Function(T model)? isSelected;
  final void Function(T model)? listTileOnTap;
  final List<T> models;

  const GenericListView({
    super.key,
    this.iconButtonOnPressed,
    this.isSelected,
    required this.models,
    this.hasIconButton = true,
    this.listTileOnTap,
  }) : assert(
          hasIconButton || iconButtonOnPressed == null,
          'iconButtonOnPressed will not be used when hasIconButton is false',
        );

  @override
  Widget build(BuildContext context) {
    final emptyListText = switch (T) {
      Matchup => 'No matchups to show',
      Person => 'No members selected',
      Prize => 'No prizes added',
      Team => 'No teams selected',
      _ => throw Exception('Unsupported type: ${T.toString()}'),
    };

    return models.isEmpty
        ? Center(child: Text(emptyListText))
        : ListView.builder(
            itemCount: models.length,
            itemBuilder: (context, index) {
              final model = models[index];
              final titleText = switch (model) {
                Matchup m => m.displayName,
                Person p => p.fullName,
                Prize p => p.placeName,
                Team t => t.name,
                _ => throw Exception(
                    'Unsupported item type: ${model.runtimeType}',
                  ),
              };
              return ListTile(
                onTap: () => listTileOnTap?.call(model),
                selected: isSelected != null ? isSelected!(model) : false,
                title: Text(titleText),
                trailing: hasIconButton
                    ? IconButton(
                        onPressed: () => iconButtonOnPressed?.call(model),
                        icon: const Icon(Icons.remove_outlined),
                      )
                    : null,
              );
            },
          );
  }
}
