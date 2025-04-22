import 'package:flutter/material.dart';

import 'headline_small_text.dart';

class CustomCard extends StatelessWidget {
  final String? headingText;
  final Widget? headingTrailing;
  final Widget child;

  const CustomCard({
    super.key,
    this.headingText,
    this.headingTrailing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 48,
            color: Theme.of(context).colorScheme.inversePrimary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (headingText != null) HeadlineSmallText(text: headingText!),
                if (headingTrailing != null) headingTrailing!,
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
