import 'package:flutter/material.dart';

class AddToListDropdown<T> extends StatelessWidget {
  final List<T> availableObjects;
  final T? selectedObject;
  final void Function(T? object) onObjectSelected;
  final void Function(T? object) onObjectAdded;
  final String Function(T object) entryLabelBuilder;
  final String dropdownLabelText;
  final String buttonText;

  const AddToListDropdown({
    super.key,
    required this.availableObjects,
    required this.selectedObject,
    required this.onObjectSelected,
    required this.onObjectAdded,
    required this.entryLabelBuilder,
    required this.dropdownLabelText,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DropdownMenu<T>(
          key: ValueKey(availableObjects.length),
          dropdownMenuEntries: availableObjects
              .map(
                (e) => DropdownMenuEntry<T>(
                  value: e,
                  label: entryLabelBuilder(e),
                ),
              )
              .toList(),
          label: Text(dropdownLabelText),
          onSelected: onObjectSelected,
          width: 136.6 * 2,
        ),
        const SizedBox(width: 13.6),
        FilledButton(
          onPressed: () {
            if (selectedObject != null) {
              onObjectAdded(selectedObject);
            }
          },
          child: Text(buttonText),
        ),
      ],
    );
  }
}
