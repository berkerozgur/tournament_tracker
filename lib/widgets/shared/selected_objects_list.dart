import 'package:flutter/material.dart';

class SelectedObjectsList<T> extends StatelessWidget {
  final List<T> selectedObjects;
  // final T selectedObject;
  final String listTitle;
  final String Function(T object) listTileTitleBuilder;
  final void Function(T object) onObjectRemoved;

  const SelectedObjectsList({
    super.key,
    required this.selectedObjects,
    // required this.selectedObject,
    required this.listTitle,
    required this.listTileTitleBuilder,
    required this.onObjectRemoved,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          listTitle,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Expanded(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
            child: Container(
              decoration: BoxDecoration(
                border:
                    Border.all(color: Theme.of(context).colorScheme.outline),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ListView.builder(
                itemCount: selectedObjects.length,
                itemBuilder: (context, index) {
                  final object = selectedObjects[index];
                  return ListTile(
                    title: Text(listTileTitleBuilder(object)),
                    trailing: IconButton(
                      onPressed: () {
                        onObjectRemoved(object);
                      },
                      icon: const Icon(Icons.remove_outlined),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
