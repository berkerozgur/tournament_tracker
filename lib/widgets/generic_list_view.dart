// ignore_for_file: type_literal_in_constant_pattern

import 'package:flutter/material.dart';

import '../models/displayable.dart';
import '../models/person.dart';
import '../models/prize.dart';
import '../models/team.dart';
import 'custom_button.dart';

class GenericListView<T extends Displayable> extends StatelessWidget {
  final VoidCallback? headlineButtonOnPressed;
  final void Function(T model)? iconButtonOnPressed;
  final List<T> models;
  // final T? selectedT;

  const GenericListView({
    super.key,
    this.headlineButtonOnPressed,
    required this.iconButtonOnPressed,
    required this.models,
    // required this.selectedT,
  });

  @override
  Widget build(BuildContext context) {
    final uiConfig = switch (T) {
      Person => (
          buttonText: null,
          emptyListText: 'No members selected',
          headlineText: 'Selected team members',
        ),
      Prize => (
          buttonText: 'Create prize',
          emptyListText: 'No prizes added',
          headlineText: 'Selected prizes',
        ),
      Team => (
          buttonText: 'Create new team',
          emptyListText: 'No teams selected',
          headlineText: 'Selected teams',
        ),
      _ => throw Exception('Unsupported type: ${T.toString()}'),
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.primaryContainer,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                HeadlineSmallText(text: uiConfig.headlineText),
                if (uiConfig.buttonText != null)
                  CustomButton(
                    buttonType: ButtonType.text,
                    onPressed: headlineButtonOnPressed,
                    text: uiConfig.buttonText!,
                  ),
              ],
            ),
          ),
          models.isEmpty
              ? Expanded(
                  child: Center(
                    child: Text(uiConfig.emptyListText),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: models.length,
                    itemBuilder: (context, index) {
                      final model = models[index];
                      final titleText = switch (model) {
                        Person p => p.fullName,
                        Prize p => p.placeName,
                        Team t => t.name,
                        _ => throw Exception(
                            'Unsupported item type: ${model.runtimeType}',
                          ),
                      };
                      return ListTile(
                        // selected: selectedT == t,
                        title: Text(titleText),
                        trailing: IconButton(
                          onPressed: () => iconButtonOnPressed?.call(model),
                          icon: const Icon(Icons.remove_outlined),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}

class HeadlineSmallText extends StatelessWidget {
  final String text;

  const HeadlineSmallText({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.headlineSmall,
    );
  }
}
